<#
.Synopsis
   Imports NAV objects from a disk file.
#>
function Import-NAVApplicationObject
{
    [CmdletBinding()]
    Param
    (
        # Specifies the type of server to connect to (native or Microsoft SQL Server)
        [ValidateSet('SQL', 'Native')]
        [string]$DatabaseServerType = 'SQL',

        # Specifies the name of the database from which you want to export.
        [string]$DatabaseName,

        # Specifies the name of the database server (instance) to which the database you want to import to is attached. 
        [string]$DatabaseServer,

        # Specifies the file name to import
        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ -PathType Leaf } )]
        [string]$Path
    )

    $Client = Get-NAVDevelopmentClient -DatabaseServerType $DatabaseServerType -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName
    $Bytes = [System.IO.File]::ReadAllBytes($Path)
    $MemoryStream = New-Object -TypeName System.IO.MemoryStream -ArgumentList @(,$Bytes)
    $Client.WriteObjectFromStream($MemoryStream)       
}