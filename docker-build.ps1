# PowerShell script to build and run the Docker container
# Usage: .\docker-build.ps1

Write-Host "Building Realms Governance UI Docker image..." -ForegroundColor Green

# Build the Docker image
docker build -t realms-governance-ui .

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nBuild successful!" -ForegroundColor Green
    Write-Host "`nTo run the container, use one of these commands:" -ForegroundColor Yellow
    Write-Host "  docker run -p 3000:3000 realms-governance-ui" -ForegroundColor Cyan
    Write-Host "  OR" -ForegroundColor Yellow
    Write-Host "  docker-compose up" -ForegroundColor Cyan
} else {
    Write-Host "`nBuild failed!" -ForegroundColor Red
    exit 1
}

