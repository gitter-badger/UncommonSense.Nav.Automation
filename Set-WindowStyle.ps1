# https://gist.github.com/jakeballard/11240204

function Set-WindowStyle 
{
    param(
        [Parameter()]
        [ValidateSet('Hidden', 'Maximized', 'Minimized', 'Normal')]
        [string]$WindowStyle = 'Normal',
    
        [Parameter(ValueFromPipeLineByPropertyName)]
        $MainWindowHandle = (Get-Process -Id $pid).MainWindowHandle
    )

    $WindowStates = @{
        'Hidden'    = 0
        'Maximized' = 3
        'Minimized' = 6
        'Normal'    = 1
    }
    
    $Win32ShowWindowAsync = Add-Type `
        -MemberDefinition '[DllImport("user32.dll")]public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);' `
        -Name Win32ShowWindowAsync `
        -Namespace Win32Functions `
        -PassThru
    
    $Win32ShowWindowAsync::ShowWindowAsync($MainWindowHandle, $WindowStates[$WindowStyle]) | Out-Null
    Write-Verbose ("Set Window Style '{1} on '{0}'" -f $MainWindowHandle, $WindowStyle)
}
