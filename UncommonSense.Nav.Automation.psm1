# Copyright (c) 2015 Jan Hoek
# https://github.com/jhoek/UncommonSense.Nav.Automation

# These functions use the CSide Integration Utilities library 
# written by Thaddeus Ryker, licensed under the Apache 2.0 License. 
# The source is obtainable at 
# http://code.edgerunner.org/dynamics-nav-client-interface-library. 

<#
.Synopsis
   Outputs a list of running NAV Development clients
#>
function Get-NAVDevelopmentClient
{
    [CmdletBinding()]

    $HelperLibraryFileName = Join-Path $PSScriptRoot Org.Edgerunner.Dynamics.Nav.CSide.dll
    Add-Type -Path $HelperLibraryFileName

    $Clients = [Org.Edgerunner.Dynamics.Nav.CSide.Client]::GetClients($true) 
    
    foreach($Client in $Clients)
    {
        # Build a custom object with the relevant properties, so that what we output to the 
        # pipeline has no dependency on Org.Edgerunner.Dynamics.Nav.CSide.dll.
        # 

        $CustomObject = New-Object System.Object
        $CustomObject | Add-Member -Type NoteProperty -Name CSideVersion -Value $Client.CSideVersion
        $CustomObject | Add-Member -Type NoteProperty -Name DatabaseServerType -Value $Client.ServerType.ToString()
        $CustomObject | Add-Member -Type NoteProperty -name DatabaseServer -Value $Client.Server
        $CustomObject | Add-Member -Type NoteProperty -name DatabaseName -Value $Client.Database
        $CustomObject | Add-Member -Type NoteProperty -name CompanyName -Value $Client.Company

        $CustomObject
    }
}

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
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('SQL', 'Native')]
        [string]$DatabaseServerType = 'SQL',

        # Name of the server to connect to
        [Parameter(ValueFromPipeLineByPropertyName=$true)]
        [string]$DatabaseServer = '.',

        # Name of the database to open
        [Parameter(Mandatory=$true,ValueFromPipeLineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
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

    Begin
    {
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
        $TypeNames = 'TableData','Table','Form','Report','Dataport','Codeunit','XMLport','MenuSuite','Page',,'System','FieldNumber'
    }
    Process
    {
        Write-Verbose "Connecting to $DatabaseServerType server $DatabaseServer, database $DatabaseName"
        $Client = [Org.Edgerunner.Dynamics.Nav.CSide.Client]::GetClient($DatabaseServerType, $($DatabaseServer.ToUpperInvariant()), $($DatabaseName.ToUpperInvariant()), $Null)
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
}

<#
.Synopsis
   Exports a NAV object to a disk file.
#>
function Export-NAVApplicationObject
{
    [CmdletBinding()]
    Param
    (
        # Specifies the type of server to connect to (native or Microsoft SQL Server)
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('SQL', 'Native')]
        [string]$DatabaseServerType = 'SQL',

        # Specifies the name of the database from which you want to export.
        [Parameter(Mandatory=$true,ValueFromPipeLineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$DatabaseName,

        # Specifies the name of the SQL server instance to which the database
        # you want to export from is attached. The default value is the default
        # instance on the local host (.).
        [Parameter(ValueFromPipeLineByPropertyName=$true)]
        [string]$DatabaseServer = '.',

        # Specifies the file to export to.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path = $Pwd,

        # Specifies the type of the object to export
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('TableData','Table','Form','Report','Dataport','Codeunit','XMLport','MenuSuite','Page')]
        [string]$Type,

        # Specifies the ID of the object to export
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [int]$ID,

        [Switch]$Force
    )

    Begin
    {
        $HelperLibraryFileName = Join-Path $PSScriptRoot Org.Edgerunner.Dynamics.Nav.CSide.dll
        Add-Type -Path $HelperLibraryFileName
    }
    Process
    {
        # Through the pipeline, we may receive multiple NAV development clients, or multiple
        # object types/IDs. Because of the former, we are getting the client below, not in 
        # the Begin section.
        Write-Verbose "Connecting to $DatabaseServerType server $DatabaseServer, database $DatabaseName"
        $Client = [Org.Edgerunner.Dynamics.Nav.CSide.Client]::GetClient($DatabaseServerType, $($DatabaseServer.ToUpperInvariant()), $($DatabaseName.ToUpperInvariant()), $Null)

        $memoryStream = $client.ReadObjectToStream($type, $id) 

        $bytes = New-Object Byte[]($memoryStream.Length)
        $memoryStream.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null
        $memoryStream.Read($bytes, 0, $memoryStream.Length) | Out-Null
        $memoryStream.Close()

        $FileName = [String]::Format("{0}{1}.txt", $type.ToString().SubString(0, 3).ToLowerInvariant(), $id)
        $FilePath = Join-Path $Path $FileName

        $fileStream = New-Object -TypeName "System.IO.FileStream"("$FilePath", [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
        $fileStream.Write($bytes, 0, $bytes.Length) | Out-Null
        $fileStream.Close()

        Get-ChildItem -Path $FilePath
    }
    End
    {
    }
}

<#
.Synopsis
   Compiles a NAV application object
#>
function Compile-NAVApplicationObject
{
    [CmdletBinding()]
    Param
    (
        # Specifies the type of server to connect to (native or Microsoft SQL Server)
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('SQL', 'Native')]
        [string]$DatabaseServerType = 'SQL',

        # Specifies the name of the database from which you want to export.
        [Parameter(Mandatory=$true,ValueFromPipeLineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$DatabaseName,

        # Specifies the name of the SQL server instance to which the database
        # you want to export from is attached. The default value is the default
        # instance on the local host (.).
        [Parameter(ValueFromPipeLineByPropertyName=$true)]
        [string]$DatabaseServer = '.',

        # Specifies the type of the object to export
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('TableData','Table','Form','Report','Dataport','Codeunit','XMLport','MenuSuite','Page')]
        [string]$Type,

        # Specifies the ID of the object to export
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [int]$ID
    )

    Begin
    {
        $HelperLibraryFileName = Join-Path $PSScriptRoot Org.Edgerunner.Dynamics.Nav.CSide.dll
        Add-Type -Path $HelperLibraryFileName
    }
    Process
    {
        # Through the pipeline, we may receive multiple NAV development clients, or multiple
        # object types/IDs. Because of the former, we are getting the client below, not in 
        # the Begin section.
        Write-Verbose "Connecting to $DatabaseServerType server $DatabaseServer, database $DatabaseName"
        $Client = [Org.Edgerunner.Dynamics.Nav.CSide.Client]::GetClient($DatabaseServerType, $($DatabaseServer.ToUpperInvariant()), $($DatabaseName.ToUpperInvariant()), $Null)
        $Client.CompileObject([Org.Edgerunner.Dynamics.Nav.CSide.NavObjectType]$Type, $ID)
    }
    End
    {
    }
}