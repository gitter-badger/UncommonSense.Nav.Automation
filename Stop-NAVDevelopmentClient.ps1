<#
.Synopsis
Stops a running NAV development client.
#>
function Stop-NAVDevelopmentClient
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,ValueFromPipeLine,ValueFromPipeLineByPropertyName)]
        [Org.Edgerunner.Dynamics.Nav.CSide.Client]$Client
    )

    Process
    {
        foreach($Item in $Client)
        {
            $Process = Get-Process -Name *fin* | Where-Object -Property MainWindowHandle -Eq $Item.WindowHandle

            if ($Process)
            {
                Write-Verbose "NAV development client process ID is $($Process.Id)" 

                if (-not $Process.CloseMainWindow())
                {
                    Write-Error -Message "Failed to stop NAV development client process."
                }
                else
                {
                    Write-Verbose -Message "Successfully stopped NAV development client process."
                }
            }
            else
            {
                Write-Error -Message "Could not find process for NAV development client."
            }
        }
    }
}