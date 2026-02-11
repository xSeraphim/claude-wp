# Claude WP Installer for Windows
# PowerShell installation script

$ErrorActionPreference = "Stop"

Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "║   Claude WP - Installer              ║" -ForegroundColor Cyan
Write-Host "║   WordPress Development Skill        ║" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
try {
    git --version | Out-Null
    Write-Host "✓ Git detected" -ForegroundColor Green
}
catch {
    Write-Host "✗ Git is required but not installed." -ForegroundColor Red
    exit 1
}

# Optional checks
try { php --version | Out-Null; Write-Host "✓ PHP detected" -ForegroundColor Green }
catch { Write-Host "⚠  PHP not found (optional - needed for PHPCS linting)" -ForegroundColor Yellow }

try { composer --version 2>$null | Out-Null; Write-Host "✓ Composer detected" -ForegroundColor Green }
catch { Write-Host "⚠  Composer not found (optional - needed for PHPCS linting)" -ForegroundColor Yellow }

try { npm --version | Out-Null; Write-Host "✓ npm detected" -ForegroundColor Green }
catch { Write-Host "⚠  npm not found (optional - needed for ESLint/Stylelint)" -ForegroundColor Yellow }

Write-Host ""

# Set paths
$SkillDir = "$env:USERPROFILE\.claude\skills\wordpress-dev"
$RepoUrl = "https://github.com/xSeraphim/claude-wp"

# Create skill directory
New-Item -ItemType Directory -Force -Path $SkillDir | Out-Null

# Clone to temp directory
$TempDir = Join-Path $env:TEMP "claude-wp-install"
if (Test-Path $TempDir) {
    Remove-Item -Recurse -Force $TempDir
}

Write-Host "↓ Downloading Claude WP..." -ForegroundColor Yellow
git clone --depth 1 $RepoUrl $TempDir 2>$null

$Src = $TempDir

# Copy core skill files
Write-Host "→ Installing skill files..." -ForegroundColor Yellow
Copy-Item -Force "$Src\SKILL.md" $SkillDir
Copy-Item -Force "$Src\CLAUDE.md" $SkillDir

# Copy references
$RefsPath = "$Src\references"
if (Test-Path $RefsPath) {
    $SkillRefs = "$SkillDir\references"
    New-Item -ItemType Directory -Force -Path $SkillRefs | Out-Null
    Copy-Item -Recurse -Force "$RefsPath\*" $SkillRefs
    Write-Host "  ✓ References: php-standards, js-standards, css-standards, security-checklist, woocommerce" -ForegroundColor Green
}

# Copy templates
$TplPath = "$Src\templates"
if (Test-Path $TplPath) {
    $SkillTpl = "$SkillDir\templates"
    New-Item -ItemType Directory -Force -Path $SkillTpl | Out-Null
    Copy-Item -Recurse -Force "$TplPath\*" $SkillTpl
    # Copy dotfiles explicitly
    Get-ChildItem -Path $TplPath -Filter ".*" -Force | Copy-Item -Destination $SkillTpl -Force
    Write-Host "  ✓ Templates: phpcs.xml.dist, .eslintrc.json, .stylelintrc.json, composer.json, package.json" -ForegroundColor Green
}

# Copy scripts
$ScriptsPath = "$Src\scripts"
if (Test-Path $ScriptsPath) {
    $SkillScripts = "$SkillDir\scripts"
    New-Item -ItemType Directory -Force -Path $SkillScripts | Out-Null
    Copy-Item -Recurse -Force "$ScriptsPath\*" $SkillScripts
    Write-Host "  ✓ Scripts: setup-environment.sh/.ps1, lint-all.sh/.ps1" -ForegroundColor Green
}

# Cleanup
Remove-Item -Recurse -Force $TempDir

Write-Host ""
Write-Host "✓ Claude WP installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Installed to: $SkillDir"
Write-Host ""
Write-Host "Usage:" -ForegroundColor Cyan
Write-Host "  1. Start Claude Code:  claude"
Write-Host '  2. Ask for WP code:    "Create a WordPress plugin that..."'
Write-Host "  3. Claude will automatically follow WordPress coding standards"
Write-Host ""
Write-Host "Optional - set up linting in a project:" -ForegroundColor Cyan
Write-Host "  & $SkillDir\scripts\setup-environment.ps1 -ProjectDir C:\path\to\your\wp-project"
