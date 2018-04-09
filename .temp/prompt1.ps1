# Load posh-git module from current directory
Import-Module posh-git

# Get full name of user
$username = $env:UserName
$hostname = $env:ComputerName

function global:prompt
{
    # 得到路径信息
    $my_path = $(get-location).toString()
    $my_pos = ($my_path).LastIndexOf("\") + 1
    if ( $my_pos -eq ($my_path).Length ) {
        $my_path_tail = $my_path
    } else {
        $my_path_tail = ($my_path).SubString( $my_pos, ($my_path).Length - $my_pos )
    }

    Write-Host ($username) -nonewline -foregroundcolor 'Red'
    Write-Host ("@") -nonewline -foregroundcolor 'Yellow'
    Write-Host ($hostname) -nonewline -foregroundcolor 'Gray'
    Write-Host (" ") -nonewline
    Write-Host ($my_path_tail) -nonewline -foregroundcolor 'Blue'

    # for git
    $realLASTEXITCODE = $LASTEXITCODE
    Write-VcsStatus
    $global:LASTEXITCODE = $realLASTEXITCODE

    Write-Host (" >>>") -nonewline -foregroundcolor 'Green'
    return " "
}