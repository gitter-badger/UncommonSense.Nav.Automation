<#
.Synopsis
   Exports the same set of NAV objects from two databases, to two folders.
#>
function Compare-NAVApplication
{
    [CmdletBinding()]
    Param
    (
        # Name for the source configuration
        [Parameter(Mandatory=$true)]
        [string]$SourceConfigName,

        # Name for the target configuration
        [Parameter(Mandatory=$true)]
        [string]$TargetConfigName,

        # Name of the folder to which the source objects are to be exported
        [Parameter(Mandatory=$true)]
        [string]$SourceFolderName,

        # Name of the folder to which the target objects are to be exported
        [Parameter(Mandatory=$true)]
        [string]$TargetFolderName,

        # Name of the configurations file. Defaults to configs.txt in the same 
        # folder as the script file.
        [string]$ConfigListFileName = $(Join-Path $PSScriptRoot 'configs.txt'),

        # Filter string for the Type field. Uses NAV filter syntax for option fields.
        [string]$TypeFilter,

        # Filter string for the ID field. Uses NAV filter syntax for integer fields.
        [string]$IDFilter,

        # Filter string for the Name field. Uses NAV filter syntax for text fields.
        [string]$NameFilter, 

        # Filter string for the Modified field. Uses NAV filter syntax for boolean fields.
        [string]$ModifiedFilter,

        # Filter string for the Compiled field. Uses NAV filter syntax for boolean fields.
        [string]$CompiledFilter,

        # Filter string for the Date field. Uses NAV filter syntax for date fields.
        [string]$DateFilter,

        # Filter string for the Time field. Uses NAV filter syntax for time fields.
        [string]$TimeFilter,

        # Filter string for the Version List field. Uses NAV filter syntax for text fields.
        [string]$VersionListFilter
    )

    $ErrorActionPreference = 'Stop'
    $ConfigList = Import-Csv -Path $ConfigListFileName -Header Name,DevEnvPath,DatabaseServerInstance,DatabaseName,ZupID

    $SourceConfig = $ConfigList | Where-Object Name -eq $SourceConfigName 
    $TargetConfig = $ConfigList | Where-Object Name -eq $TargetConfigName

    if (-not $SourceConfig) 
    {
        throw "Configuration '$SourceConfigName' could not be found in $ConfigListFileName."
    }

    if (-not $TargetConfig)
    {
        throw "Configuration '$TargetConfigName' could not be found in $ConfigListFileName."
    }

    Write-Verbose "Source configuration: $SourceConfig"
    Write-Verbose "Target configuration: $TargetConfig"

    # Open source and target databases
    $SourceProcess = Start-Process -FilePath $($SourceConfig.DevEnvPath) -ArgumentList "servername=$($SourceConfig.DatabaseServerInstance),database=$($SourceConfig.DatabaseName.ToUpperInvariant()),id=$($SourceConfig.ZupID)" -PassThru
    $TargetProcess = Start-Process -FilePath $($TargetConfig.DevEnvPath) -ArgumentList "servername=$($TargetConfig.DatabaseServerInstance),database=$($TargetConfig.DatabaseName.ToUpperInvariant()),id=$($TargetConfig.ZupID)" -PassThru

    # Determine server type from DevEnvPath
    switch ($SourceConfig.DevEnvPath.EndsWith('finsql.exe', [System.StringComparison]::InvariantCultureIgnoreCase))
    {
        $true { $SourceServerType = 'SQL' }
        $false { $SourceServerType = 'Native' }
    }

    switch($TargetConfig.DevEnvPath.EndsWith('finsql.exe', [System.StringComparison]::InvariantCultureIgnoreCase))
    {
        $true { $TargetServerType = 'SQL' }
        $false { $TargetServerType = 'Native' }
    }

    try
    {
        # Wait for NAV clients to start
        Start-Sleep -Seconds 5

        $ChangedObjects = Get-NAVApplicationObjectInfo `
            -DatabaseServerType $SourceServerType `
            -DatabaseServer $($SourceConfig.DatabaseServerInstance) `
            -DatabaseName $($SourceConfig.DatabaseName) `
            -TypeFilter $TypeFilter `
            -IDFilter $IDFilter `
            -NameFilter $NameFilter `
            -ModifiedFilter $ModifiedFilter `
            -CompiledFilter $CompiledFilter `
            -DateFilter $DateFilter `
            -TimeFilter $TimeFilter `
            -VersionListFilter $VersionListFilter `
            | Out-GridView -PassThru -Title 'Select Objects'

        if ($ChangedObjects.Length -ne 0)
        {
            if (-not (Test-Path $SourceFolderName))
            {
                New-Item -Path $SourceFolderName -ItemType Container | Out-Null
            }

            if (-not (Test-Path $TargetFolderName))
            {
                New-Item -Path $TargetFolderName -ItemType Container | Out-Null
            }

            $ChangedObjects | Export-NAVApplicationObject -DatabaseServerType $SourceServerType -DatabaseServer $($SourceConfig.DatabaseServerInstance) -DatabaseName $($SourceConfig.DatabaseName) -Path $SourceFolderName | Write-Verbose
            $ChangedObjects | Export-NAVApplicationObject -DatabaseServerType $TargetServerType -DatabaseServer $($TargetConfig.DatabaseServerInstance) -DatabaseName $($TargetConfig.DatabaseName) -Path $TargetFolderName | Write-Verbose
        }
    }
    finally
    {
        if ($SourceProcess) 
        {
            $SourceProcess.CloseMainWindow() | Out-Null
        }

        # Wait for breakpoint file to be released before 
        # closing second client
        Start-Sleep -Seconds 3

        if ($TargetProcess) 
        {
            $TargetProcess.CloseMainWindow() | Out-Null
        }
    }
}