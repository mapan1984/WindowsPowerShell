<#Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)#>

# Load PSColor
Import-Module PSColor

# Load posh-git module
Import-Module posh-git

# Load powershell tab
Import-Module PowerTab -ArgumentList "F:\Documents\WindowsPowerShell\PowerTabConfig.xml"

# Set up a simple prompt, adding the git prompt parts inside git repos
function global:prompt {

    #$path = Split-Path -leaf -path (Get-Location)
    $Date = Get-Date

    Write-Host
    Write-Host "# " -NoNewline -ForegroundColor Blue
    Write-Host $env:USERNAME -NoNewline -ForegroundColor Cyan
    Write-Host " in " -NoNewline -ForegroundColor Gray
    #Write-Host $path" " -NoNewline -ForegroundColor Green
    Write-Host ($pwd.ProviderPath)" " -NoNewline -ForegroundColor Green

    <# posh-git for git: show information if in git rep #>
    $realLASTEXITCODE = $LASTEXITCODE
    Write-VcsStatus
    $global:LASTEXITCODE = $realLASTEXITCODE
    <# posh-git for git: end #>

    Write-Host " "$Date -ForegroundColor Gray
    Write-Host ">" -NoNewline -ForegroundColor Magenta

    return " "
}

<#
Pop-Location

Start-SshAgent -Quiet
#>