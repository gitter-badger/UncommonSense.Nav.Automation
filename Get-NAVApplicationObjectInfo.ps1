<#
.Synopsis
   Retrieves information about NAV objects that match the optional filter criteria
#>
function Get-NAVApplicationObjectInfo
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,ValueFromPipeLine,ValueFromPipeLineByPropertyName)]
        [Org.Edgerunner.Dynamics.Nav.CSide.Client]$Client,

        [string]$TypeFilter,
        [string]$IDFilter,
        [string]$NameFilter, 
        [string]$ModifiedFilter,
        [string]$CompiledFilter,
        [string]$DateFilter,
        [string]$TimeFilter,
        [string]$VersionListFilter
    )

    Set-Variable Activity -Option Constant -Value 'Getting NAV application object information'

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

    Write-Progress -Activity $Activity -CurrentOperation 'Opening table'
    $ObjectTable = $Client.GetTable($ObjectTableID)

    Write-Progress -Activity $Activity -CurrentOperation 'Setting filters'
    if ($TypeFilter) { $ObjectTable.SetFilter($TypeFieldNo, $TypeFilter) }
    if ($IDFilter) { $ObjectTable.SetFilter($IDFieldNo, $IDFilter) }
    if ($NameFilter) { $ObjectTable.SetFilter($NameFieldNo, $NameFilter) }
    if ($ModifiedFilter) { $ObjectTable.SetFilter($ModifiedFieldNo, $ModifiedFilter) }
    if ($CompiledFilter) { $ObjectTable.SetFilter($CompiledFieldNo, $CompiledFilter) }
    if ($DateFilter) { $ObjectTable.SetFilter($DateFieldNo, $DateFilter) }
    if ($TimeFilter) { $ObjectTable.SetFilter($TimeFieldNo, $TimeFilter) }
    if ($VersionListFilter) { $ObjectTable.SetFilter($VersionListFieldNo, $VersionListFilter) }

    Write-Progress -Activity $Activity -CurrentOperation 'Fetching records'
    $ObjectRecords = $ObjectTable.FetchRecords()
    Write-Verbose "$($ObjectRecords.Count) records."

    $NoOfRecords = $ObjectRecords.Count
    $CurrentRecord = 0

    foreach($ObjectRecord in $ObjectRecords)
    {
        Write-Progress -Activity $Activity -CurrentOperation 'Outputting records' -PercentComplete (($CurrentRecord / $NoOfRecords) * 100)
        $CustomObject = New-Object System.Object
        $CustomObject | Add-Member -Type NoteProperty -Name Type -Value $TypeNames[$ObjectRecord.FieldValues.Item($TypeFieldNo).Value]
        $CustomObject | Add-Member -Type NoteProperty -Name ID -Value ([int]$ObjectRecord.FieldValues.Item($IDFieldNo).Value)
        $CustomObject | Add-Member -Type NoteProperty -Name Name -Value $ObjectRecord.FieldValues.Item($NameFieldNo).Value
        $CustomObject | Add-Member -Type NoteProperty -Name Modified -Value ($ObjectRecord.FieldValues.Item($ModifiedFieldNo).Value -eq '1')
        $CustomObject | Add-Member -Type NoteProperty -Name Compiled -Value ($ObjectRecord.FieldValues.Item($CompiledFieldNo).Value -eq '1')
        $CustomObject | Add-Member -Type NoteProperty -Name DateTime -Value ([DateTime]"$($ObjectRecord.FieldValues.Item($DateFieldNo).Value) $($ObjectRecord.FieldValues.Item($TimeFieldNo).Value)")
        $CustomObject | Add-Member -Type NoteProperty -Name VersionList -Value $ObjectRecord.FieldValues.Item($VersionListFieldNo).Value
        $CustomObject.PSObject.TypeNames.Insert(0, 'UncommonSense.NAV.Automation.ObjectInfo')

        $CustomObject
        $CurrentRecord++
    }
}
