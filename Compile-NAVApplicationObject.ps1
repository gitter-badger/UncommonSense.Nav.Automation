<#
.Synopsis
   Compiles a NAV application object
#>
function Compile-NAVApplicationObject
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,ValueFromPipeLine,ValueFromPipeLineByPropertyName)]
        [Org.Edgerunner.Dynamics.Nav.CSide.Client]$Client,

        # Specifies the type of the object to export
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('TableData','Table','Form','Report','Dataport','Codeunit','XMLport','MenuSuite','Page','Query')]
        [string]$Type,

        # Specifies the ID of the object to export
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [int]$ID
    )

    Process
    {
        $Client.CompileObject([Org.Edgerunner.Dynamics.Nav.CSide.NavObjectType]$Type, $ID)
    }
}
