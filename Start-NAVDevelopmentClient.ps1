<#
.Synopsis
   Starts a NAV Development client
#>
function Start-NAVDevelopmentClient
{
    Param
    (
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string]$DevEnvFilePath,

        [Parameter(Mandatory)]
        [string]$DatabaseServerName,

        [Parameter(Mandatory)]
        [string]$DatabaseName,

        [ValidateSet('Hidden', 'Maximized', 'Minimized', 'Normal')]
        [string]$WindowStyle = 'Normal',

        [string]$ID,

        [Switch]$PassThru
    )

    $Arguments = @()
    $Arguments += ('servername={0}' -f $DatabaseServerName)
    $Arguments += ('database={0}' -f $DatabaseName)
    if ($ID) { $Arguments.Add('id={0}' -f $ID)  }

    $ArgumentList = $Arguments -join ','
    $Process = Start-Process -FilePath $DevEnvFilePath -ArgumentList $ArgumentList -PassThru 

    if ($WindowStyle -ne 'Normal')
    {
        Start-Sleep -Seconds 1
        Set-WindowStyle -MainWindowHandle $Process.MainWindowHandle -WindowStyle $WindowStyle
    }

    if ($PassThru)
    {
        $Process
    }
}