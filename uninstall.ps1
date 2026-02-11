# Claude WP Uninstaller for Windows

$SkillDir = "$env:USERPROFILE\.claude\skills\wordpress-dev"

Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "║   Claude WP - Uninstaller            ║" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if (Test-Path $SkillDir) {
    Remove-Item -Recurse -Force $SkillDir
    Write-Host "✓ Removed $SkillDir" -ForegroundColor Green
}
else {
    Write-Host "⚠  Skill directory not found at $SkillDir" -ForegroundColor Yellow
    Write-Host "  Nothing to uninstall."
}

Write-Host ""
Write-Host "✓ Claude WP uninstalled." -ForegroundColor Green
