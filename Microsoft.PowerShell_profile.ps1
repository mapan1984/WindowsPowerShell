<#
Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)
#>

### Load Module Plug
Import-Module PSColor
#$poshGitModule = Get-Module posh-git -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
#if ($poshGitModule) {
#    $poshGitModule | Import-Module
#}
#elseif (Test-Path -LiteralPath ($modulePath = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) (Join-Path src 'posh-git.psd1'))) {
#    Import-Module $modulePath
#}
#else {
#    throw "Failed to import posh-git."
#}
#Import-Module posh-git
#Import-Module PowerTab -ArgumentList ".\PowerTabConfig.xml"
#Import-Module PsGet

### All alias
Set-Alias -Name l -Value Get-ChildItem
Set-Alias -Name vi -Value Code

### Add user path
$currentDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$env:Path+=($currentDir)+"\Bin;"

### Set up prompt
# Get full name of user
$username = $env:UserName
$hostname = $env:ComputerName

# Am I an admin?
$wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$prp = new-object System.Security.Principal.WindowsPrincipal($wid)
$adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
$IsAdmin = $prp.IsInRole($adm)

# Here we go
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    # username@hostname
    if ($IsAdmin) {
        write-host $username -nonewline -ForegroundColor Red
    } else {
        write-host $username -nonewline -ForegroundColor Cyan
    }
    Write-Host ("@") -nonewline -foregroundcolor Gray
    Write-Host ($hostname) -nonewline -foregroundcolor DarkCyan

    # current path
    write-Host " Ω " -nonewline -ForegroundColor Gray
    Write-Host ($pwd.ProviderPath) -nonewline -ForegroundColor Green

    <# posh-git for git: show information if in git rep #>
    $realLASTEXITCODE = $LASTEXITCODE
    Write-VcsStatus
    $global:LASTEXITCODE = $realLASTEXITCODE
    <# posh-git for git: end #>

    # Rightmost time display
    $currentY = [console]::CursorTop        # Save cursor position first
    $columns = (Get-Host).UI.RawUI.windowsize.width    # Column quantity of console window
    [console]::SetCursorPosition($columns - 8, $currentY)
    write-host "{" -nonewline -ForegroundColor Yellow
    write-host (Get-Date -format "HH:mm") -nonewline -ForegroundColor Cyan
    write-host "}" -ForegroundColor Yellow

    Write-Host ">" -NoNewline -ForegroundColor Magenta

    $global:LASTEXITCODE = $realLASTEXITCODE

    return " "
}

<#
Pop-Location

Start-SshAgent -Quiet
#>