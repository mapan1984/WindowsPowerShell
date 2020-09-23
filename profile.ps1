### Load Module Plug
Import-Module PSReadLine
# Import-Module PSColor
Import-Module posh-git
# Import-Module PowerTab -ArgumentList ".\PowerTabConfig.xml"
# Import-Module PsGet

### All alias
# Set-Alias -Name l -Value Get-ChildItem
# Set-Alias -Name vi -Value Code
#
# Function CATHIS {Get-Content (Get-PSReadlineOption).HistorySavePath}
# Set-Alias -Name his -Value CATHIS
#
# Function CD32 {Set-Location -Path C:\Windows\System32}
# Set-Alias -Name Go -Value CD32

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

    # posh-git status
    Write-VcsStatus

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


### PSReadLineOption
# 设置 EditMode
Set-PSReadLineOption -EditMode Emacs
#
Set-PSReadLineOption -Colors @{
    Command             = "#e5c07b"
    Number              = "#cdd4d4"
    Member              = "#e06c75"
    Operator            = "#e06c75"
    Type                = "#78b6e9"
    Variable            = "#78b6e9"
    Parameter           = "#e06c75"  #命令行参数颜色
    ContinuationPrompt  = "#e06c75"
    Default             = "#cdd4d4"
    Emphasis            = "#e06c75"
    #Error
    Selection           = "#cdd4d4"
    Comment             = "#cdd4d4"
    Keyword             = "#e06c75"
    String              = "#78b6e9"
}
# Clipboard interaction is bound by default in Windows mode, but not Emacs mode.
Set-PSReadLineKeyHandler -Key Ctrl+C -Function Copy
Set-PSReadLineKeyHandler -Key Ctrl+v -Function Paste
