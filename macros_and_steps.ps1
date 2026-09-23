# Weekly fitness export:
#   1. Pull the last 7 days of macros from MyFitnessPal (Python)
#   2. Append steps + sleep from Google Health to the same CSV (Go)
$ErrorActionPreference = "Stop"

$mfpDir    = Join-Path $PSScriptRoot "Mfp-Scraper"
$healthDir = Join-Path $PSScriptRoot "GoogleHealthDataRetriever"

$python  = Join-Path $mfpDir "venv\Scripts\python.exe"
$csvPath = Join-Path $mfpDir "week_macros.csv"
$targetPath = Join-Path $PSScriptRoot "weekly-checkin.csv"

# Fail early with a clear message if anything's missing
foreach ($path in @($mfpDir, $healthDir, $python)) {
    if (-not (Test-Path $path)) { throw "Not found: $path" }
}

# --- Step 1: MFP macros (creates/overwrites the CSV) ---
Write-Host "`n=== MyFitnessPal macros ===" -ForegroundColor Cyan
Push-Location $mfpDir
try {
    & $python get_macros.py
    if ($LASTEXITCODE -ne 0) { throw "MFP script failed (exit code $LASTEXITCODE)" }
}
finally {
    Pop-Location
}

if (-not (Test-Path $csvPath)) {
    throw "MFP script finished but $csvPath wasn't created"
}

# --- Step 2: Google Health steps + sleep (appends to the CSV) ---
Write-Host "`n=== Google Health steps & sleep ===" -ForegroundColor Cyan
Push-Location $healthDir
try {
    if (Test-Path .\health-fetch.exe) {
        .\health-fetch.exe -csv $csvPath
    }
    elseif (Get-Command go -ErrorAction SilentlyContinue) {
        Write-Host "health-fetch.exe not found, running from source with 'go run'..."
        go run . -csv $csvPath
    }
    else {
        throw "Neither health-fetch.exe nor Go was found. Install Go from go.dev, or build with 'go build -o health-fetch.exe' in $healthDir."
    }
    if ($LASTEXITCODE -ne 0) { throw "Google Health program failed (exit code $LASTEXITCODE)" }
}
finally {
    Pop-Location
}

try {
    Move-Item $csvPath $targetPath -Force
}
catch {
    throw "Couldn't move the CSV to $targetPath. Is it open in Excel? ($_)"
}

Write-Host "`n=== Combined CSV: $targetPath ===" -ForegroundColor Green
Get-Content $targetPath