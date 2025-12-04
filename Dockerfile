# Multi-stage build for optimized production image
FROM node:18.19.0-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache \
    libc6-compat \
    python3 \
    make \
    g++ \
    git \
    openssh-client \
    ca-certificates
WORKDIR /app

# Copy package files
COPY package.json yarn.lock .yarnrc.yml ./

# Install dependencies with frozen lockfile
# The --ignore-scripts flag prevents the lavamoat preinstall hook from failing
# We'll run allow-scripts separately after installation
RUN yarn install --frozen-lockfile --network-concurrency 1 --ignore-scripts

# Run allow-scripts to enable only whitelisted scripts
RUN yarn allow-scripts

# Run the bigint-buffer rebuild that's needed
RUN cd node_modules/bigint-buffer && yarn rebuild && cd ../../ || true

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Set environment variables for build
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production
# Increase Node.js heap size to 4GB to prevent out of memory errors during build
ENV NODE_OPTIONS="--max-old-space-size=4096"

# Build the application
RUN yarn build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Create a non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy necessary files from builder
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# Set the correct permission for prerender cache
RUN mkdir .next
RUN chown nextjs:nodejs .next

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

# Expose port (Railway will set PORT env variable)
EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Start the application
CMD ["node", "server.js"]

