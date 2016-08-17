Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

set-alias l Get-ChildItemColor
#set-alias share "python -m http.server"
 
# Load posh-git module
Import-Module posh-git

# Get name
$username = [Environment]::UserName
$hostname = $env:COMPUTERNAME

<#
function prompt  
{  
    $my_path = $(get-location).toString()  
    $my_pos = ($my_path).LastIndexOf("\") + 1  
    
    if( $my_pos -eq ($my_path).Length ) { $my_path_tail = $my_path }  
    else { $my_path_tail = ($my_path).SubString( $my_pos, ($my_path).Length - $my_pos ) }  
    
    Write-Host ($username) -nonewline -foregroundcolor 'Red'  
    Write-Host ("@") -nonewline -foregroundcolor 'Yellow'  
    Write-Host ($hostname) -nonewline -foregroundcolor 'Gray'  
    Write-Host ($my_path_tail) -nonewline -foregroundcolor 'Blue'  
    
    # for git
    $realLASTEXITCODE = $LASTEXITCODE
    Write-VcsStatus
    $global:LASTEXITCODE = $realLASTEXITCODE
    
    Write-Host (" >>>") -nonewline -foregroundcolor 'Green'  
    return " "  
} 
#>

# Am I an admin?
$wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$prp = new-object System.Security.Principal.WindowsPrincipal($wid)
$adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
$IsAdmin = $prp.IsInRole($adm)

#Function to write git repository status on prompt
function writegitprompt($status){
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
    if($IsAdmin){
        write-host $username -nonewline -ForegroundColor Red
    } else {
        write-host $username -nonewline -ForegroundColor Yellow
    }
    
    write-host " $([char]0x3C9) " -nonewline -ForegroundColor Gray
    Write-Host($pwd.ProviderPath) -nonewline -ForegroundColor Green
    
    writegitprompt (Get-GitStatus)
    
    # Rightmost time display
    # Save cursor position first
    $saveY = [console]::CursorTop
    $saveX = [console]::CursorLeft
    $columns = (Get-Host).UI.RawUI.windowsize.width    # Column quantity of console window
    [console]::SetCursorPosition($columns - 8, $saveY)
    write-host "[" -nonewline
    write-host (Get-Date -format "HH:mm") -nonewline -ForegroundColor Cyan
    write-host "]" -nonewline
    [console]::setcursorposition($saveX,$saveY)        # Move cursor back

    $global:LASTEXITCODE = $realLASTEXITCODE
    return " $([char]0x3BB) "
}

function Get-ChildItemColor
{  
<#  
.Synopsis  
  Returns childitems with colors by type.  
.Description  
  This function wraps Get-ChildItem and tries to output the results  
  color-coded by type:  
  Directories - Cyan  
  Compressed - Red  
  Executables - Green  
  Text Files - Gray  
  Image Files - Magenta  
  Others - Gray  
.ReturnValue  
  All objects returned by Get-ChildItem are passed down the pipeline  
  unmodified.   
#>  


    $regex_opts = ([System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Compiled)

    $fore = $Host.UI.RawUI.ForegroundColor
    $compressed = New-Object System.Text.RegularExpressions.Regex('\.(zip|tar|gz|rar|7z|tgz|bz2)', $regex_opts)
    $executable = New-Object System.Text.RegularExpressions.Regex('\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg|sh)', $regex_opts)
    $text_files = New-Object System.Text.RegularExpressions.Regex('\.(txt|cfg|conf|ini|csv|log)', $regex_opts)
    $image_files = New-Object System.Text.RegularExpressions.Regex('\.(bmp|jpg|png|gif|jpeg)', $regex_opts)

    Invoke-Expression ("Get-ChildItem $args") |
    %{
        if ($_.GetType().Name -eq 'DirectoryInfo') { $Host.UI.RawUI.ForegroundColor = 'Cyan' }
        elseif ($compressed.IsMatch($_.Name)) { $Host.UI.RawUI.ForegroundColor = 'Red' }
        elseif ($executable.IsMatch($_.Name)) { $Host.UI.RawUI.ForegroundColor = 'Green' }
        elseif ($text_files.IsMatch($_.Name)) { $Host.UI.RawUI.ForegroundColor = 'Gray' }
        elseif ($image_files.IsMatch($_.Name)) { $Host.UI.RawUI.ForegroundColor = 'Magenta' }
        else { $Host.UI.RawUI.ForegroundColor = 'Gray' }  
        echo $_ 
        $Host.UI.RawUI.ForegroundColor = $fore
    }
}


<#
function Show-Color( [System.ConsoleColor] $color )
{
    $fore = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $color
    echo ($color).toString()
    $Host.UI.RawUI.ForegroundColor = $fore
}

function Show-AllColor
{
    Show-Color('Black')
    Show-Color('DarkBlue')
    Show-Color('DarkGreen')
    Show-Color('DarkCyan')
    Show-Color('DarkRed')
    Show-Color('DarkMagenta')
    Show-Color('DarkYellow')
    Show-Color('Gray')
    Show-Color('DarkGray')
    Show-Color('Blue')
    Show-Color('Green')
    Show-Color('Cyan')
    Show-Color('Red')
    Show-Color('Magenta')
    Show-Color('Yellow')
    Show-Color('White')
}
#>
