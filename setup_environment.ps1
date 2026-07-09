# HEY HOOD - AUTOMATED ENVIRONMENT SETUP SCRIPT
# This script installs Node.js, Java OpenJDK 17, and Flutter SDK silently.

Write-Host "======================================================================"
Write-Host "          HEY HOOD - AUTOMATED ENVIRONMENT SETUP SCRIPT"
Write-Host "======================================================================"

# Check Admin Privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "This script installs system software. Please run PowerShell as Administrator."
    Exit
}

# 1. Install Node.js via Winget
Write-Host "[1/3] Installing Node.js LTS..."
winget install --id OpenJS.NodeJS -e --silent --accept-source-agreements --accept-package-agreements
if ($LASTEXITCODE -eq 0) {
    Write-Host "Node.js installed successfully."
} else {
    Write-Warning "Node.js installation via Winget failed or was already installed."
}

# 2. Install OpenJDK 17 via Winget
Write-Host "[2/3] Installing OpenJDK 17..."
winget install --id EclipseAdoptium.Temurin.17.JDK -e --silent --accept-source-agreements --accept-package-agreements
if ($LASTEXITCODE -eq 0) {
    Write-Host "OpenJDK 17 installed successfully."
} else {
    Write-Warning "OpenJDK 17 installation failed or was already installed."
}

# 3. Install Flutter SDK
Write-Host "[3/3] Downloading and installing Flutter SDK..."
$flutterDir = "C:\src"
if (-not (Test-Path $flutterDir)) {
    New-Item -ItemType Directory -Path $flutterDir | Out-Null
}

$flutterZip = "$flutterDir\flutter.zip"
$flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.19.6-stable.zip"

if (-not (Test-Path "$flutterDir\flutter")) {
    Write-Host "Downloading Flutter zip (this may take a few minutes)..."
    Invoke-WebRequest -Uri $flutterUrl -OutFile $flutterZip
    Write-Host "Extracting Flutter SDK to $flutterDir\flutter..."
    Expand-Archive -Path $flutterZip -DestinationPath $flutterDir
    Remove-Item -Path $flutterZip
} else {
    Write-Host "Flutter is already installed in $flutterDir\flutter."
}

# Add Flutter to User Path
Write-Host "Configuring Environment PATH variables..."
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$flutterBin = "C:\src\flutter\bin"
if ($userPath -notlike "*$flutterBin*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$flutterBin", "User")
    $env:Path = "$env:Path;$flutterBin"
    Write-Host "Added $flutterBin to User Environment PATH."
} else {
    Write-Host "$flutterBin is already in environment PATH."
}

Write-Host "======================================================================"
Write-Host "Setup Completed! Please restart your terminal/IDE for PATH changes to take effect."
Write-Host "Verify by running: flutter doctor"
Write-Host "======================================================================"
