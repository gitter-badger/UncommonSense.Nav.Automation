function Get-NAVDevelopmentClientConfig
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Native','Sql')]
        [string]$Type,

        [Parameter(Mandatory,ParameterSetName='List')]
        [Switch]$List,

        [Parameter(Mandatory,ParameterSetName='Name',Position=0)]
        [string]$Name
    )

    switch($Type)
    {
        'Native' { $ConfigsFileName = Join-Path $PSScriptRoot "fin.txt" } 
        'Sql'    { $ConfigsFileName = Join-Path $PSScriptRoot "finsql.txt" }
    }
    
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