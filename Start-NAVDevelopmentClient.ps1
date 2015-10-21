<#
.Synopsis
Starts a NAV development client.
#>
function Start-NAVDevelopmentClient
{
    [CmdletBinding()]
    [OutputType([Org.Edgerunner.Dynamics.Nav.CSide.Client])]
    Param
    (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateScript( { Test-Path $_ } )]
        [string]$DevClientPath,

        [Parameter(Mandatory,ValueFromPipeLineByPropertyName)]
        [ValidateSet('Native','Sql')]
        [string]$DatabaseServerType,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$DatabaseServerName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$DatabaseName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ZupPath,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$NTAuthentication,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('tcp','tcps','netb')]
        [string]$NetType,

        # Controls how the development client window is displayed
        [ValidateSet('Hidden','Maximized','Minimized','Normal')]
        [string]$WindowStyle = 'Normal',

        [Switch]$PassThru
    )

    $Arguments = @()

    if (-not ([string]::IsNullOrEmpty($DatabaseServerName)))
    {
        $Arguments += ('servername={0}' -f $DatabaseServerName)
    }

    if (-not ([string]::IsNullOrEmpty($DatabaseName)))
    {
        $Arguments += ('database={0}' -f $DatabaseName)
    }

    if (-not ([string]::IsNullOrEmpty($ZupPath)))
    { 
        $Arguments += ('id={0}' -f $ZupPath)  
    }

    if (-not ([string]::IsNullOrEmpty($NTAuthentication)))
    { 
        $Arguments += ('ntauthentication={0}' -f $NTAuthentication)  
    }

    if (-not ([string]::IsNullOrEmpty($NetType)))
    { 
        $Arguments += ('nettype={0}' -f $NetType)  
    }

    $ProcessStartInfo = New-Object -TypeName System.Diagnostics.ProcessStartInfo
    $ProcessStartInfo.FileName = $DevClientPath
    $ProcessStartInfo.WindowStyle = $WindowStyle
    $ProcessStartInfo.Arguments = $Arguments -join ','

    $Process = [System.Diagnostics.Process]::Start($ProcessStartInfo)

    Start-Sleep -Seconds 3

    $Client = Get-NAVDevelopmentClient -List | Where-Object -Property WindowHandle -Eq -Value $Process.MainWindowHandle | Select-Object -First 1

    if ($PassThru)
    {
        $Client
    }
}