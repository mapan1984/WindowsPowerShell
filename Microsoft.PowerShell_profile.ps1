Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Load posh-git module
Import-Module posh-git


# Set up a simple prompt, adding the git prompt parts inside git repos
function global:prompt {
  
    #$path = Split-Path -leaf -path (Get-Location)
    $Date = Get-Date
        
    Write-Host
    Write-Host "# " -NoNewline -ForegroundColor Blue
    Write-Host $env:USERNAME -NoNewline -ForegroundColor Cyan
    Write-Host " in " -NoNewline
    #Write-Host $path" " -NoNewline -ForegroundColor Green
    Write-Host ($pwd.ProviderPath)" " -NoNewline -ForegroundColor Green
    
    # for git
    $realLASTEXITCODE = $LASTEXITCODE
    Write-VcsStatus
    $global:LASTEXITCODE = $realLASTEXITCODE
    
    Write-Host $Date 
    Write-Host ">" -NoNewline -ForegroundColor Magenta

    return " " 
}

Pop-Location

Start-SshAgent -Quiet
