<#
.Synopsis
Retrieves a (list of) predefined NAV database configuration(s).
#>
function Get-NAVDatabaseConnectionConfig
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Position=0)]
        [string]$Name
    )

    $DatabaseConfigsFileName = Join-Path $PSScriptRoot 'databases.txt'

    if (-not (Test-Path -Path $DatabaseConfigsFileName))
    {
        'Name,DatabaseServerType,DatabaseServerName,DatabaseName,DevClientName,ZupPath,NTAuthentication,NetType' | Out-File -FilePath $DatabaseConfigsFileName
    }
    else
    {
        $DatabaseConfigs = Import-Csv -Path $DatabaseConfigsFileName -Delimiter ','

        if ($Name)
        {
            $DatabaseConfig = $DatabaseConfigs | Where-Object -Property Name -Eq -Value $Name

            if ($DatabaseConfig)
            {
                $DevClientConfig = Get-NAVDevelopmentClientConfig -Name $DatabaseConfig.DevClientName
                $DatabaseConfig | Add-Member -MemberType NoteProperty -Name DevClientPath -Value $DevClientConfig.DevClientPath

                $DatabaseConfig
            }
        }
        else
        {
            $DatabaseConfigs
        }
    }
}