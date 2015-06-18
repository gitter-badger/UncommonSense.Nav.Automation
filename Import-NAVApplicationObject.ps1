<#
.Synopsis
   Imports NAV objects from a disk file.
#>
function Import-NAVApplicationObject
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,ValueFromPipeLine,ValueFromPipeLineByPropertyName)]
        [Org.Edgerunner.Dynamics.Nav.CSide.Client]$Client,

        # Specifies the file name to import
        [Parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ -PathType Leaf } )]
        [string]$Path
    )

    $Bytes = [System.IO.File]::ReadAllBytes($Path)
    $MemoryStream = New-Object -TypeName System.IO.MemoryStream -ArgumentList @(,$Bytes)
    $Client.WriteObjectFromStream($MemoryStream)       
}