<#
.Synopsis
Retrieves a (list of) predefined NAV development client configuration(s).
#>
function Get-NAVDevelopmentClientConfig
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Position=0)]
        [string]$Name
    )

    $ConfigsFileName = Join-Path $PSScriptRoot 'devclients.txt'

    if (-not (Test-Path -Path $ConfigsFileName))
    {
        'Name,DevClientPath' | Out-File -FilePath $ConfigsFileName 
    }
    else
    {
        $Configs = Import-Csv -Path $ConfigsFileName -Delimiter ','

        if ($Name)
        {
            $Configs | Where-Object -Property Name -Eq -Value $Name
        }
        else
        {
            $Configs
        }
    }
}