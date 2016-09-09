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
    $c_files = New-Object System.Text.RegularExpressions.Regex('\.(c|c++|h)', $regex_opts)
    $executable = New-Object System.Text.RegularExpressions.Regex('\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg|sh)', $regex_opts)
    $text_files = New-Object System.Text.RegularExpressions.Regex('\.(txt|cfg|conf|ini|csv|log)', $regex_opts)
    $image_files = New-Object System.Text.RegularExpressions.Regex('\.(bmp|jpg|png|gif|jpeg)', $regex_opts)

    Invoke-Expression ("Get-ChildItem $args") |
    %{
        if ($_.GetType().Name -eq 'DirectoryInfo') { $Host.UI.RawUI.ForegroundColor = 'Blue' }
        elseif ($compressed.IsMatch($_.Name)) { $Host.UI.RawUI.ForegroundColor = 'Red' }
        elseif ($c_files.IsMatch($_.Name)) { $Host.UI.RawUI.ForegroundColor = 'Gray' }
        elseif ($executable.IsMatch($_.Name)) { $Host.UI.RawUI.ForegroundColor = 'Green' }
        elseif ($text_files.IsMatch($_.Name)) { $Host.UI.RawUI.ForegroundColor = 'Gray' }
        elseif ($image_files.IsMatch($_.Name)) { $Host.UI.RawUI.ForegroundColor = 'Magenta' }
        else { $Host.UI.RawUI.ForegroundColor = 'Gray' }  
        echo $_ 
        $Host.UI.RawUI.ForegroundColor = $fore
    }
}

Set-Alias l Get-ChildItemColor