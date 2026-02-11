#Requires -Version 5.1
<#
.SYNOPSIS
    WordPress Full-Stack Linter for Windows.

.DESCRIPTION
    Runs PHPCS, ESLint, and Stylelint against a project directory.

.PARAMETER ProjectDir
    Path to the project directory. Required.

.PARAMETER Fix
    Attempt auto-fixing before reporting.

.PARAMETER PhpOnly
    Only run PHP linting.

.PARAMETER JsOnly
    Only run JavaScript linting.

.PARAMETER CssOnly
    Only run CSS linting.

.EXAMPLE
    .\lint-all.ps1 -ProjectDir C:\Users\dev\my-plugin
    .\lint-all.ps1 -ProjectDir C:\Users\dev\my-plugin -Fix
    .\lint-all.ps1 -ProjectDir C:\Users\dev\my-plugin -Fix -PhpOnly
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectDir,

    [switch]$Fix,
    [switch]$PhpOnly,
    [switch]$JsOnly,
    [switch]$CssOnly
)

$RunPhp = $true
$RunJs = $true
$RunCss = $true

if ($PhpOnly) { $RunJs = $false; $RunCss = $false }
if ($JsOnly) { $RunPhp = $false; $RunCss = $false }
if ($CssOnly) { $RunPhp = $false; $RunJs = $false }

# Resolve tool paths.
$phpcs = Join-Path $ProjectDir "vendor\bin\phpcs.bat"
$phpcbf = Join-Path $ProjectDir "vendor\bin\phpcbf.bat"
$eslint = Join-Path $ProjectDir "node_modules\.bin\eslint.cmd"
$stylelint = Join-Path $ProjectDir "node_modules\.bin\stylelint.cmd"

# Fallback to non-.bat versions (Git Bash / WSL tools).
if (-not (Test-Path $phpcs)) { $phpcs = Join-Path $ProjectDir "vendor\bin\phpcs" }
if (-not (Test-Path $phpcbf)) { $phpcbf = Join-Path $ProjectDir "vendor\bin\phpcbf" }
if (-not (Test-Path $eslint)) { $eslint = Join-Path $ProjectDir "node_modules\.bin\eslint" }
if (-not (Test-Path $stylelint)) { $stylelint = Join-Path $ProjectDir "node_modules\.bin\stylelint" }

$totalErrors = 0

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " WordPress Full-Stack Linter"
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Project:  $ProjectDir"
Write-Host "Auto-fix: $Fix"
Write-Host ""

# --- PHP ---
if ($RunPhp) {
    Write-Host "--- PHP (PHPCS) ---" -ForegroundColor Yellow

    if (Test-Path $phpcs) {
        $standard = "WordPress"
        foreach ($candidate in @("phpcs.xml.dist", "phpcs.xml", ".phpcs.xml.dist", ".phpcs.xml")) {
            $configPath = Join-Path $ProjectDir $candidate
            if (Test-Path $configPath) {
                $standard = $configPath
                Write-Host "Config: $candidate"
                break
            }
        }

        if ($Fix -and (Test-Path $phpcbf)) {
            Write-Host "[PHPCBF] Auto-fixing..."
            & $phpcbf --standard="$standard" --extensions=php `
                --ignore="*/vendor/*,*/node_modules/*,*/build/*" `
                $ProjectDir 2>&1 | Write-Host
        }

        & $phpcs --standard="$standard" --extensions=php --colors -s `
            --ignore="*/vendor/*,*/node_modules/*,*/build/*" `
            --report-full --report-summary `
            $ProjectDir 2>&1 | Write-Host
        $result = $LASTEXITCODE

        if ($result -eq 0) {
            Write-Host "PHP: PASSED" -ForegroundColor Green
        }
        elseif ($result -eq 2) {
            Write-Host "PHP: WARNINGS ONLY (acceptable)" -ForegroundColor Yellow
        }
        else {
            Write-Host "PHP: ERRORS FOUND" -ForegroundColor Red
            $totalErrors++
        }
    }
    else {
        Write-Host "PHPCS not installed. Skipping."
    }
    Write-Host ""
}

# --- JavaScript ---
if ($RunJs) {
    Write-Host "--- JavaScript (ESLint) ---" -ForegroundColor Yellow

    if (Test-Path $eslint) {
        $jsFiles = Get-ChildItem -Path $ProjectDir -Recurse -Include "*.js", "*.jsx" -File |
            Where-Object { $_.FullName -notmatch '(node_modules|vendor|build|\.git)' } |
            Select-Object -First 100 -ExpandProperty FullName

        if ($jsFiles) {
            $fixFlag = @()
            if ($Fix) { $fixFlag = @("--fix") }

            & $eslint @fixFlag --no-error-on-unmatched-pattern @jsFiles 2>&1 | Write-Host
            $result = $LASTEXITCODE

            if ($result -eq 0) {
                Write-Host "JS: PASSED" -ForegroundColor Green
            }
            else {
                Write-Host "JS: ERRORS FOUND" -ForegroundColor Red
                $totalErrors++
            }
        }
        else {
            Write-Host "No JS files found. Skipping."
        }
    }
    else {
        Write-Host "ESLint not installed. Skipping."
    }
    Write-Host ""
}

# --- CSS ---
if ($RunCss) {
    Write-Host "--- CSS (Stylelint) ---" -ForegroundColor Yellow

    if (Test-Path $stylelint) {
        $cssFiles = Get-ChildItem -Path $ProjectDir -Recurse -Include "*.css", "*.scss" -File |
            Where-Object { $_.FullName -notmatch '(node_modules|vendor|build|\.git)' } |
            Select-Object -First 100 -ExpandProperty FullName

        if ($cssFiles) {
            $fixFlag = @()
            if ($Fix) { $fixFlag = @("--fix") }

            & $stylelint @fixFlag @cssFiles 2>&1 | Write-Host
            $result = $LASTEXITCODE

            if ($result -eq 0) {
                Write-Host "CSS: PASSED" -ForegroundColor Green
            }
            else {
                Write-Host "CSS: ERRORS FOUND" -ForegroundColor Red
                $totalErrors++
            }
        }
        else {
            Write-Host "No CSS/SCSS files found. Skipping."
        }
    }
    else {
        Write-Host "Stylelint not installed. Skipping."
    }
    Write-Host ""
}

# --- Summary ---
Write-Host "==========================================" -ForegroundColor Cyan
if ($totalErrors -eq 0) {
    Write-Host " RESULT: ALL CHECKS PASSED" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Cyan
    exit 0
}
else {
    Write-Host " RESULT: $totalErrors LINTER(S) REPORTED ERRORS" -ForegroundColor Red
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Fix the errors and re-run:"
    Write-Host "  .\lint-all.ps1 -ProjectDir $ProjectDir -Fix"
    exit 1
}
