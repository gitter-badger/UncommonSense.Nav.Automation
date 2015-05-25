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
        [string]$DatabaseServer,

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
        $Client = Get-NAVClient -DatabaseServerType $DatabaseServerType -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName
    }
    Process
    {
        $Client.CompileObject([Org.Edgerunner.Dynamics.Nav.CSide.NavObjectType]$Type, $ID)
    }
    End
    {
    }
}
