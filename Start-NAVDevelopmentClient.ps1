function Start-NAVDevelopmentClient
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,ValueFromPipeLine,ValueFromPipelineByPropertyName)]
        [ValidateScript( { Test-Path $_ } )]
        [string]$DevClientPath,

        [Parameter(Mandatory)]
        [ValidateSet('Native','Sql')]
        [string]$DatabaseServerType,

        [string]$DatabaseServerName,

        [string]$DatabaseName,

        # Controls how the development client window is displayed
        [ValidateSet('Hidden', 'Maximized', 'Minimized', 'Normal')]
        [string]$WindowStyle = 'Normal',

        [Switch]$PassThru
    )

    $Arguments = @()

    if ($DatabaseServerName)
    {
        $Arguments += ('servername={0}' -f $DatabaseServerName)
    }

    if ($DatabaseName)
    {
        $Arguments += ('database={0}' -f $DatabaseName)
    }

    if ($ZupPath) 
    { 
        $Arguments += ('id={0}' -f $ZupPath)  
    }

    $ProcessStartInfo = New-Object -TypeName System.Diagnostics.ProcessStartInfo
    $ProcessStartInfo.FileName = $DevClientPath
    $ProcessStartInfo.WindowStyle = $WindowStyle
    $ProcessStartInfo.Arguments = $Arguments -join ','

    $Process = [System.Diagnostics.Process]::Start($ProcessStartInfo)

    Start-Sleep -Seconds 1

    # FIXME: return client
}