<#
.Synopsis
   Retrieves information about NAV objects that match the optional filter criteria
#>
function Get-NAVApplicationObjectInfo
{
    [CmdletBinding()]
    Param
    (
        # Type of server to connect to (native or Microsoft SQL Server)
        [ValidateSet('SQL', 'Native')]
        [string]$DatabaseServerType = 'SQL',

        # Name of the server to connect to
        [Parameter(Mandatory)]
        [string]$DatabaseServer,

        # Name of the database to open
        [Parameter(Mandatory)]
        [string]$DatabaseName,

        # Filters
        [string]$TypeFilter,
        [string]$IDFilter,
        [string]$NameFilter, 
        [string]$ModifiedFilter,
        [string]$CompiledFilter,
        [string]$DateFilter,
        [string]$TimeFilter,
        [string]$VersionListFilter
    )

    $HelperLibraryFileName = Join-Path $PSScriptRoot Org.Edgerunner.Dynamics.Nav.CSide.dll
    Add-Type -Path $HelperLibraryFileName

    Set-Variable ObjectTableID -Option Constant -Value 2000000001
    Set-Variable TypeFieldNo -Option Constant -Value 1
    Set-Variable IDFieldNo -Option Constant -Value 3
    Set-Variable NameFieldNo -Option Constant -Value 4
    Set-Variable ModifiedFieldNo -Option Constant -Value 5
    Set-Variable CompiledFieldNo -Option Constant -Value 6
    Set-Variable DateFieldNo -Option Constant -Value 10
    Set-Variable TimeFieldNo -Option Constant -Value 11
    Set-Variable VersionListFieldNo -Option Constant -Value 12    
    $TypeNames = 'TableData','Table','Form','Report','Dataport','Codeunit','XMLport','MenuSuite','Page','Query','System','FieldNumber'

    $Client = Get-NAVClient -DatabaseServerType $DatabaseServerType -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName
    $ObjectTable = $Client.GetTable($ObjectTableID)

    if ($TypeFilter) { $ObjectTable.SetFilter($TypeFieldNo, $TypeFilter) }
    if ($IDFilter) { $ObjectTable.SetFilter($IDFieldNo, $IDFilter) }
    if ($NameFilter) { $ObjectTable.SetFilter($NameFieldNo, $NameFilter) }
    if ($ModifiedFilter) { $ObjectTable.SetFilter($ModifiedFieldNo, $ModifiedFilter) }
    if ($CompiledFilter) { $ObjectTable.SetFilter($CompiledFieldNo, $CompiledFilter) }
    if ($DateFilter) { $ObjectTable.SetFilter($DateFieldNo, $DateFilter) }
    if ($TimeFilter) { $ObjectTable.SetFilter($TimeFieldNo, $TimeFilter) }
    if ($VersionListFilter) { $ObjectTable.SetFilter($VersionListFieldNo, $VersionListFilter) }

    $ObjectRecords = $ObjectTable.FetchRecords()
    Write-Verbose "$($ObjectRecords.Count) records."

    foreach($ObjectRecord in $ObjectRecords)
    {
        $CustomObject = New-Object System.Object
        $CustomObject | Add-Member -Type NoteProperty -Name Type -Value $TypeNames[$ObjectRecord.FieldValues.Item($TypeFieldNo).Value]
        $CustomObject | Add-Member -Type NoteProperty -Name ID -Value $ObjectRecord.FieldValues.Item($IDFieldNo).Value
        $CustomObject | Add-Member -Type NoteProperty -Name Name -Value $ObjectRecord.FieldValues.Item($NameFieldNo).Value
        $CustomObject | Add-Member -Type NoteProperty -Name Modified -Value ($ObjectRecord.FieldValues.Item($ModifiedFieldNo).Value -eq '1')
        $CustomObject | Add-Member -Type NoteProperty -Name Compiled -Value ($ObjectRecord.FieldValues.Item($CompiledFieldNo).Value -eq '1')
        $CustomObject | Add-Member -Type NoteProperty -Name DateTime -Value ([DateTime]"$($ObjectRecord.FieldValues.Item($DateFieldNo).Value) $($ObjectRecord.FieldValues.Item($TimeFieldNo).Value)")
        $CustomObject | Add-Member -Type NoteProperty -Name VersionList -Value $ObjectRecord.FieldValues.Item($VersionListFieldNo).Value

        $CustomObject
    }
}
