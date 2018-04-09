# Get full name of user
$username = $env:UserName
$hostname = $env:ComputerName

# Am I an admin?
$wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$prp = new-object System.Security.Principal.WindowsPrincipal($wid)
$adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
$IsAdmin = $prp.IsInRole($adm)

# Function to write git repository status on prompt
function Write-Git-Prompt($status) {
    if ($status) {
         write-host ' (' -nonewline
         write-host ($status.Branch) -nonewline
         write-host ' ' -nonewline
         if($status.HasWorking) {
             write-host "$([char]0x25CF)" -nonewline -ForegroundColor @{$true='Green';$false='DarkGray'}[$status.Working.Added -and $status.Working.Added.Count -ge 0]
             write-host "$([char]0x25CF)" -nonewline -ForegroundColor @{$true=(@{$true='Red';$false='Yellow'}[$status.Working.Unmerged -and $status.Working.Unmerged.Count -ge 0]);$false=(@{$true='Red';$false='DarkGray'}[$status.Working.Unmerged -and $status.Working.Unmerged.Count -ge 0])}[$status.Working.Modified -and $status.Working.Modified.Count -ge 0]
             write-host "$([char]0x25CF)" -nonewline -ForegroundColor @{$true='Red';$false='DarkGray'}[$status.Working.Deleted -and $status.Working.Deleted.Count -ge 0]
         } else {
             write-host "$([char]0x25CF)$([char]0x25CF)$([char]0x25CF)" -nonewline -ForegroundColor DarkGray
         }
         if($status.HasIndex) {
             write-host "|" -nonewline
             write-host "$([char]0x25CF)" -nonewline -ForegroundColor @{$true='Green';$false='DarkGray'}[$status.Index.Added -and $status.Index.Added.Count -ge 0]
             write-host "$([char]0x25CF)" -nonewline -ForegroundColor @{$true=(@{$true='Red';$false='Yellow'}[$status.Index.Unmerged -and $status.Index.Unmerged.Count -ge 0]);false=(@{$true='Red';$false='DarkGray'}[$status.Working.Unmerged -and $status.Working.Unmerged.Count -ge 0])}[$status.Index.Modified -and $status.Index.Modified.Count -ge 0]
             write-host "$([char]0x25CF)" -nonewline -ForegroundColor @{$true='Red';$false='DarkGray'}[$status.Index.Deleted -and $status.Index.Deleted.Count -ge 0]
         }
         write-host ')' -nonewline
    }
}

# Here we go
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    # username@hostname
    if($IsAdmin){
        write-host $username -nonewline -ForegroundColor Red
    } else {
        write-host $username -nonewline -ForegroundColor Yellow
    }
    Write-Host ("@") -nonewline -foregroundcolor Yellow
    Write-Host ($hostname) -nonewline -foregroundcolor Gray

    # current path
    write-Host " $([char]0x3C9) " -nonewline -ForegroundColor Gray
    Write-Host ($pwd.ProviderPath) -nonewline -ForegroundColor Green

    # git prompt
    Write-Git-Prompt(Get-GitStatus)

    # Rightmost time display
    $saveY = [console]::CursorTop        # Save cursor position first
    $saveX = [console]::CursorLeft
    $columns = (Get-Host).UI.RawUI.windowsize.width    # Column quantity of console window
    [console]::SetCursorPosition($columns - 8, $saveY)
    write-host "[" -nonewline
    write-host (Get-Date -format "HH:mm") -nonewline -ForegroundColor Cyan
    write-host "]" -nonewline
    [console]::setcursorposition($saveX, $saveY)        # Move cursor back

    $global:LASTEXITCODE = $realLASTEXITCODE

    return " $([char]0x3BB) "
}