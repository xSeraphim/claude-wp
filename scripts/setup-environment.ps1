#Requires -Version 5.1
<#
.SYNOPSIS
    WordPress Development Environment Setup for Windows.

.DESCRIPTION
    Installs PHPCS + WPCS, ESLint + WP config, Stylelint + WP config.

.PARAMETER ProjectDir
    Path to the project directory. Required.

.EXAMPLE
    .\setup-environment.ps1 -ProjectDir C:\Users\dev\my-wp-plugin
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectDir
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ProjectDir)) {
    Write-Host "Creating project directory: $ProjectDir"
    New-Item -ItemType Directory -Path $ProjectDir -Force | Out-Null
}

Write-Host "=== WordPress Dev Environment Setup ===" -ForegroundColor Cyan
Write-Host "Project directory: $ProjectDir"
Write-Host ""

Set-Location $ProjectDir

# --- PHP: PHPCS + WordPress Coding Standards ---

Write-Host "--- PHP Linting Setup ---" -ForegroundColor Yellow

$composerAvailable = $null -ne (Get-Command composer -ErrorAction SilentlyContinue)

if (-not $composerAvailable) {
    Write-Host "Composer not found."
    $phpAvailable = $null -ne (Get-Command php -ErrorAction SilentlyContinue)
    if ($phpAvailable) {
        Write-Host "Attempting to install Composer locally..."
        try {
            php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
            php composer-setup.php --install-dir=$ProjectDir --filename=composer.phar
            Remove-Item -Force composer-setup.php -ErrorAction SilentlyContinue
            $composerCmd = "php `"$ProjectDir\composer.phar`""
            Write-Host "Composer installed locally."
        }
        catch {
            Write-Warning "Could not install Composer. PHP linting will not be available."
        }
    }
    else {
        Write-Warning "PHP not found. Install PHP and Composer manually."
    }
}
else {
    $composerCmd = "composer"
}

if ($composerCmd) {
    # Initialize composer.json if not present.
    if (-not (Test-Path "$ProjectDir\composer.json")) {
        Invoke-Expression "$composerCmd init --no-interaction --name=`"project/wordpress-dev`" --description=`"WordPress development project`" --stability=`"stable`"" 2>$null
    }

    # Install WPCS.
    try {
        Invoke-Expression "$composerCmd require --dev wp-coding-standards/wpcs:^3.0 phpcompatibility/phpcompatibility-wp:* dealerdirect/phpcodesniffer-composer-installer:^1.0 --no-interaction"
        Write-Host "PHPCS + WPCS installed." -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to install PHPCS via Composer."
    }

    # Verify.
    $phpcsPath = Join-Path $ProjectDir "vendor\bin\phpcs.bat"
    if (-not (Test-Path $phpcsPath)) {
        $phpcsPath = Join-Path $ProjectDir "vendor\bin\phpcs"
    }
    if (Test-Path $phpcsPath) {
        & $phpcsPath --version
        & $phpcsPath -i
    }
}
else {
    Write-Host "SKIP: Composer unavailable. PHPCS not installed."
    Write-Host "Rely on reference files for standards compliance."
}

Write-Host ""

# --- JavaScript: ESLint + WordPress Config ---

Write-Host "--- JavaScript Linting Setup ---" -ForegroundColor Yellow

$npmAvailable = $null -ne (Get-Command npm -ErrorAction SilentlyContinue)

if ($npmAvailable) {
    # Initialize package.json if not present.
    if (-not (Test-Path "$ProjectDir\package.json")) {
        npm init -y 2>$null
    }

    try {
        npm install --save-dev @wordpress/eslint-plugin eslint
        Write-Host "ESLint + @wordpress/eslint-plugin installed." -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to install ESLint."
    }

    # Create .eslintrc.json if not present.
    if (-not (Test-Path "$ProjectDir\.eslintrc.json")) {
        @'
{
    "extends": ["plugin:@wordpress/eslint-plugin/recommended"],
    "env": {
        "browser": true,
        "jquery": true
    },
    "globals": {
        "wp": "readonly",
        "ajaxurl": "readonly"
    }
}
'@ | Set-Content -Path "$ProjectDir\.eslintrc.json" -Encoding UTF8
        Write-Host ".eslintrc.json created."
    }
}
else {
    Write-Host "SKIP: npm unavailable. ESLint not installed."
}

Write-Host ""

# --- CSS: Stylelint + WordPress Config ---

Write-Host "--- CSS Linting Setup ---" -ForegroundColor Yellow

if ($npmAvailable) {
    try {
        npm install --save-dev @wordpress/stylelint-config stylelint
        Write-Host "Stylelint + @wordpress/stylelint-config installed." -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to install Stylelint."
    }

    # Create .stylelintrc.json if not present.
    if (-not (Test-Path "$ProjectDir\.stylelintrc.json")) {
        @'
{
    "extends": "@wordpress/stylelint-config"
}
'@ | Set-Content -Path "$ProjectDir\.stylelintrc.json" -Encoding UTF8
        Write-Host ".stylelintrc.json created."
    }
}
else {
    Write-Host "SKIP: npm unavailable. Stylelint not installed."
}

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Available commands:"
if (Test-Path "$ProjectDir\vendor\bin\phpcs.bat") {
    Write-Host "  vendor\bin\phpcs --standard=WordPress <file.php>"
    Write-Host "  vendor\bin\phpcbf --standard=WordPress <file.php>"
}
if (Test-Path "$ProjectDir\node_modules\.bin") {
    Write-Host "  npx eslint <file.js>"
    Write-Host "  npx stylelint <file.css>"
}
