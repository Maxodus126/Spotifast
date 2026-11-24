param(
  [string]$v,
  [switch]$NoMarketplace
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#region Variables
$spotifastFolderPath = "$env:LOCALAPPDATA\spotifast"
$spotifastOldFolderPath = "$HOME\spotifast-cli"
#endregion Variables

#region Functions
function Write-Success {
  [CmdletBinding()]
  param ()
  process {
    Write-Host -Object ' > OK' -ForegroundColor 'Green'
  }
}

function Write-Unsuccess {
  [CmdletBinding()]
  param ()
  process {
    Write-Host -Object ' > ERROR' -ForegroundColor 'Red'
  }
}

function Test-Admin {
  [CmdletBinding()]
  param ()
  begin {
    Write-Host -Object "Checking if the script is not being run as administrator..." -NoNewline
  }
  process {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    -not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  }
}

function Test-PowerShellVersion {
  [CmdletBinding()]
  param ()
  begin {
    $PSMinVersion = [version]'5.1'
  }
  process {
    Write-Host -Object 'Checking if your PowerShell version is compatible...' -NoNewline
    $PSVersionTable.PSVersion -ge $PSMinVersion
  }
}

function Move-OldSpicetifyFolder {
  [CmdletBinding()]
  param ()
  process {
    if (Test-Path -Path $spotifastOldFolderPath) {
      Write-Host -Object 'Moving the old spotifast folder...' -NoNewline
      Copy-Item -Path "$spotifastOldFolderPath\*" -Destination $spotifastFolderPath -Recurse -Force
      Remove-Item -Path $spotifastOldFolderPath -Recurse -Force
      Write-Success
    }
  }
}

function Get-Spotifast {
  [CmdletBinding()]
  param ()
  begin {
    if ($env:PROCESSOR_ARCHITECTURE -eq 'AMD64') {
      $architecture = 'x64'
    }
    elseif ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') {
      $architecture = 'arm64'
    }
    else {
      $architecture = 'x32'
    }
    if ($v) {
      if ($v -match '^\d+\.\d+\.\d+$') {
        $targetVersion = $v
      }
      else {
        Write-Warning -Message "You have specified an invalid spotifast version: $v `nThe version must be in the following format: 1.2.3"
        Pause
        exit
      }
    }
    else {
      Write-Host -Object 'Fetching the latest spotifast version...' -NoNewline
      $latestRelease = Invoke-RestMethod -Uri 'https://api.github.com/repos/Maxodus126/Spotifast/releases/latest'
      $targetVersion = $latestRelease.tag_name -replace 'v', ''
      Write-Success
    }
    $archivePath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "spotifast.zip")
  }
  process {
    Write-Host -Object "Downloading spotifast v$targetVersion..." -NoNewline
    $Parameters = @{
      Uri            = "https://github.com/Maxodus126/Spotifast/releases/download/v$targetVersion/spotifast-$targetVersion-windows-$architecture.zip"
      UseBasicParsin = $true
      OutFile        = $archivePath
    }
    Invoke-WebRequest @Parameters
    Write-Success
  }
  end {
    $archivePath
  }
}

function Add-SpotifastToPath {
  [CmdletBinding()]
  param ()
  begin {
    Write-Host -Object 'Making spotifast available in the PATH...' -NoNewline
    $user = [EnvironmentVariableTarget]::User
    $path = [Environment]::GetEnvironmentVariable('PATH', $user)
  }
  process {
    $path = $path -replace "$([regex]::Escape($spotifastOldFolderPath))\\*;*", ''
    if ($path -notlike "*$spotifastFolderPath*") {
      $path = "$path;$spotifastFolderPath"
    }
  }
  end {
    [Environment]::SetEnvironmentVariable('PATH', $path, $user)
    if (($env:PATH -split ';') -notcontains $spotifastFolderPath) {
      $env:PATH = "$env:PATH;$spotifastFolderPath"
    }
    Write-Success
  }
}

function Install-Spotifast {
  [CmdletBinding()]
  param ()
  begin {
    Write-Host -Object 'Installing spotifast...'
  }
  process {
    $archivePath = Get-Spotifast
    Write-Host -Object 'Extracting spotifast...' -NoNewline
    Expand-Archive -Path $archivePath -DestinationPath $spotifastFolderPath -Force
    Write-Success
    Add-SpotifastToPath
  }
  end {
    Remove-Item -Path $archivePath -Force -ErrorAction 'SilentlyContinue'
    Write-Host -Object 'spotifast was successfully installed!' -ForegroundColor 'Green'
  }
}
#endregion Functions

#region Main
#region Checks
if (-not (Test-PowerShellVersion)) {
  Write-Unsuccess
  Write-Warning -Message 'PowerShell 5.1 or higher is required to run this script'
  Write-Warning -Message "You are running PowerShell $($PSVersionTable.PSVersion)"
  Write-Host -Object 'PowerShell 5.1 install guide:'
  Write-Host -Object 'https://learn.microsoft.com/skypeforbusiness/set-up-your-computer-for-windows-powershell/download-and-install-windows-powershell-5-1'
  Write-Host -Object 'PowerShell 7 install guide:'
  Write-Host -Object 'https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows'
  Pause
  exit
}
else {
  Write-Success
}
if (-not (Test-Admin)) {
  Write-Unsuccess
  Write-Warning -Message "The script was run as administrator. This can result in problems with the installation process or unexpected behavior. Do not continue if you do not know what you are doing."
  $Host.UI.RawUI.Flushinputbuffer()
  $choices = [System.Management.Automation.Host.ChoiceDescription[]] @(
    (New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Abort installation.'),
    (New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Resume installation.')
  )
  $choice = $Host.UI.PromptForChoice('', 'Do you want to abort the installation process?', $choices, 0)
  if ($choice -eq 0) {
    Write-Host -Object 'spotifast installation aborted' -ForegroundColor 'Yellow'
    Pause
    exit
  }
}
else {
  Write-Success
}
#endregion Checks

#region Agreement
Write-Host -Object "`n===========================  AGREEMENT  ===========================" -ForegroundColor 'Cyan'
Write-Host @'
Spotifast modifies the official Spotify client. By installing you accept:

 1. Spotifast is a rebranded fork of Spicetify CLI (LGPL-2.1). No warranty.
 2. It patches Spotify's files. Spotify updates may break it at any time.
 3. Using it violates Spotify's Terms of Service and MAY result in a ban.
 4. It does NOT remove ads. Ad-free listening requires Spotify Premium.
 5. You use it entirely at your own risk.

Uninstall anytime with:  spotifast-uninstall
'@
$Host.UI.RawUI.Flushinputbuffer()
$agreeChoices = [System.Management.Automation.Host.ChoiceDescription[]] @(
  (New-Object System.Management.Automation.Host.ChoiceDescription '&Agree', 'Accept and continue.'),
  (New-Object System.Management.Automation.Host.ChoiceDescription '&Decline', 'Abort installation.')
)
$agree = $Host.UI.PromptForChoice('', 'Do you accept the agreement?', $agreeChoices, 1)
if ($agree -ne 0) {
  Write-Host -Object 'Installation aborted: agreement declined.' -ForegroundColor 'Yellow'
  exit 1
}
#endregion Agreement

#region Spotifast
$installedSpicetify = Join-Path -Path $spotifastFolderPath -ChildPath 'spotifast.exe'
if (-not (Test-Path -LiteralPath $installedSpicetify -PathType Leaf)) {
  $installedCommand = Get-Command -Name 'spotifast' -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($installedCommand) {
    $installedSpicetify = $installedCommand.Source
  }
  else {
    $installedSpicetify = $null
  }
}

if ($installedSpicetify) {
  $Host.UI.RawUI.Flushinputbuffer()
  $choices = [System.Management.Automation.Host.ChoiceDescription[]] @(
    (New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Run spotifast update.'),
    (New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Continue with installation.')
  )
  $choice = $Host.UI.PromptForChoice('', 'Spotifast is already installed. Do you want to fix your installation?', $choices, 0)
  if ($choice -eq 0) {
    & $installedSpicetify update
    if ($LASTEXITCODE -ne 0) {
      throw "Spotifast update failed with exit code $LASTEXITCODE."
    }
    return
  }
}

Move-OldSpicetifyFolder
Install-Spotifast
Write-Host -Object "`nRun" -NoNewline
Write-Host -Object ' spotifast -h ' -NoNewline -ForegroundColor 'Cyan'
Write-Host -Object 'to get started'
#endregion Spotifast

#region Marketplace
if ($NoMarketplace) {
  Write-Host -Object 'Skipping Marketplace installation (-NoMarketplace).' -ForegroundColor 'Yellow'
}
else {
  Write-Host -Object 'Installing Spotifast Marketplace (part of this setup)...' -ForegroundColor 'Cyan'
  try {
    $marketParams = @{
      Uri             = 'https://raw.githubusercontent.com/Maxodus126/spotifast-marketplace/main/resources/install.ps1'
      UseBasicParsing = $true
    }
    $marketScript = Invoke-WebRequest @marketParams
    Invoke-Expression $marketScript.Content
  }
  catch {
    Write-Host -Object "Marketplace installation encountered an error: $($_.Exception.Message)" -ForegroundColor 'Yellow'
    Write-Host -Object 'You can install it later with:' -ForegroundColor 'Yellow'
    Write-Host -Object '  iwr -useb https://raw.githubusercontent.com/Maxodus126/spotifast-marketplace/main/resources/install.ps1 | iex' -ForegroundColor 'Cyan'
  }
}
#endregion Marketplace
#endregion Main
