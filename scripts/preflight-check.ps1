#Requires -Version 5.1
<#
.SYNOPSIS
    WordPress skill preflight checker.

.DESCRIPTION
    Validates a project for recommended config files and unresolved template placeholders.

.PARAMETER ProjectDir
    Path to the project directory.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectDir
)

if (-not (Test-Path -Path $ProjectDir -PathType Container)) {
    Write-Host "ERROR: Project directory does not exist: $ProjectDir" -ForegroundColor Red
    exit 1
}

$warnings = 0
$errors = 0

function Test-RecommendedFile {
    param([string]$RelativePath)

    $fullPath = Join-Path $ProjectDir $RelativePath
    if (-not (Test-Path $fullPath)) {
        Write-Host "WARN: Missing recommended file: $RelativePath" -ForegroundColor Yellow
        $script:warnings++
    }
}

function Test-Placeholder {
    param([string]$RelativePath)

    $fullPath = Join-Path $ProjectDir $RelativePath
    if (Test-Path $fullPath) {
        $matches = Select-String -Path $fullPath -Pattern 'CHANGE-ME|change_me|my-project'
        if ($matches) {
            Write-Host "ERROR: Placeholder value found in $RelativePath" -ForegroundColor Red
            $matches | ForEach-Object { Write-Host "  $($_.LineNumber): $($_.Line.Trim())" }
            $script:errors++
        }
    }
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " WordPress Skill Preflight Check"
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Project: $ProjectDir"
Write-Host ""

Write-Host "--- Recommended Config Files ---" -ForegroundColor Yellow
Test-RecommendedFile "phpcs.xml.dist"
Test-RecommendedFile ".eslintrc.json"
Test-RecommendedFile ".stylelintrc.json"
Test-RecommendedFile "composer.json"
Test-RecommendedFile "package.json"
Write-Host ""

Write-Host "--- Placeholder Scan ---" -ForegroundColor Yellow
Test-Placeholder "phpcs.xml.dist"
Test-Placeholder "composer.json"
Test-Placeholder "package.json"
Test-Placeholder ".eslintrc.json"
Test-Placeholder ".stylelintrc.json"
Write-Host ""

Write-Host "--- Plugin Header Check ---" -ForegroundColor Yellow
$pluginHeaders = Get-ChildItem -Path $ProjectDir -Recurse -Filter "*.php" -File |
    Select-String -Pattern 'Plugin Name:' -List

if ($pluginHeaders) {
    Write-Host "PASS: Found at least one plugin header (Plugin Name:)" -ForegroundColor Green
}
else {
    Write-Host "WARN: No plugin header found. If this is a plugin, add a main file header." -ForegroundColor Yellow
    $warnings++
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
if ($errors -gt 0) {
    Write-Host " RESULT: FAILED ($errors error(s), $warnings warning(s))" -ForegroundColor Red
    Write-Host "==========================================" -ForegroundColor Cyan
    exit 1
}

Write-Host " RESULT: PASS ($warnings warning(s))" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
exit 0
