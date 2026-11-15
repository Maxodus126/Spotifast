$ErrorActionPreference = 'Continue'
# Spotifast uninstaller — restores Spotify to stock state, then removes Spotifast.

$spotifastFolder = "$env:LOCALAPPDATA\spotifast"
$userDataFolder  = "$env:APPDATA\spotifast"
$exeName         = 'spotifast.exe'

Write-Host "`n=== Spotifast Uninstall ===" -ForegroundColor 'Cyan'

# 1. Find the executable
$exe = Join-Path $spotifastFolder $exeName
if (-not (Test-Path -LiteralPath $exe)) {
  $cmd = Get-Command -Name 'spotifast' -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($cmd) { $exe = $cmd.Source } else { $exe = $null }
}

# 2. Restore Spotify BEFORE deleting anything (needs the backup it holds)
if ($exe) {
  Write-Host 'Restoring Spotify to its original state...' -NoNewline
  & $exe restore
  if ($LASTEXITCODE -eq 0) { Write-Host ' > OK' -ForegroundColor Green }
  else { Write-Host ' > FAILED (Spotify may need reinstall)' -ForegroundColor Yellow }
}
else {
  Write-Host 'Spotifast executable not found; skipping restore.' -ForegroundColor Yellow
}

# 3. Remove install folder
if (Test-Path -LiteralPath $spotifastFolder) {
  Remove-Item -LiteralPath $spotifastFolder -Recurse -Force -ErrorAction SilentlyContinue
  Write-Host 'Removed install folder.' -ForegroundColor Green
}

# 4. Remove user data (config, backup, themes, extensions)
if (Test-Path -LiteralPath $userDataFolder) {
  $Host.UI.RawUI.FlushInputbuffer()
  $c = [System.Management.Automation.Host.ChoiceDescription[]] @(
    (New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Delete config, backups, themes and extensions.'),
    (New-Object System.Management.Automation.Host.ChoiceDescription '&No',  'Keep my user data.')
  )
  if ($Host.UI.PromptForChoice('', "Delete user data in $userDataFolder ?", $c, 1) -eq 0) {
    Remove-Item -LiteralPath $userDataFolder -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host 'Removed user data.' -ForegroundColor Green
  }
}

# 5. Remove from PATH
$userPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
if ($userPath -and $userPath -like "*$spotifastFolder*") {
  $newPath = ($userPath -split ';' | Where-Object { $_ -and $_ -ne $spotifastFolder }) -join ';'
  [Environment]::SetEnvironmentVariable('PATH', $newPath, 'User')
  Write-Host 'Removed from PATH.' -ForegroundColor Green
}

Write-Host "`nDone. Restart your terminal." -ForegroundColor Cyan
Write-Host 'If Spotify shows errors, reinstall Spotify from spotify.com.'
