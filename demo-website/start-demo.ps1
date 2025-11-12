# PowerShell script to start the demo website

Write-Host "=== Starting E-Commerce Demo Website ===" -ForegroundColor Green
Write-Host ""

# Check if Python is available
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    Write-Host "Error: Python not found!" -ForegroundColor Red
    Write-Host "Please install Python 3.11+ and try again." -ForegroundColor Yellow
    exit 1
}

# Navigate to demo-website directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$demoPath = Join-Path $scriptPath "demo-website"

if (-not (Test-Path $demoPath)) {
    Write-Host "Error: demo-website directory not found!" -ForegroundColor Red
    exit 1
}

Set-Location $demoPath

Write-Host "Starting HTTP server on port 8000..." -ForegroundColor Cyan
Write-Host ""
Write-Host "Open your browser and go to: http://localhost:8000" -ForegroundColor Yellow
Write-Host ""
Write-Host "Make sure the API server is running on port 60000!" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""

# Start Python HTTP server
python -m http.server 8000

