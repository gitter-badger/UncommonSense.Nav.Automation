# Couldn't get this to work with a DatabaseServerType with ValidateSet attribute. 
# DatabaseServerType should be mutually exclusive with List, and when 
# DatabaseServerType is SQL, both DatabaseServerName and DatabaseName are mandatory.
# If DatabaseServerType is Native, either DatabaseServerName *or* DatabaseName
# can be provided, but somehow my dynamic parameters did not show up. 

function Test-DynamicParams
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,ParameterSetName='Sql')]
        [Switch]$Sql,

        [Parameter(Mandatory,ParameterSetName='NativeServer')]
        [Parameter(Mandatory,ParameterSetName='NativeStandAlone')]
        [Switch]$Native,

        [Parameter(Mandatory,ParameterSetName='Sql')]
        [Parameter(Mandatory,ParameterSetName='NativeServer')]
        [string]$DatabaseServerName,

        [Parameter(Mandatory,ParameterSetName='Sql')]
        [Parameter(Mandatory,ParameterSetName='NativeStandAlone')]
        [string]$DatabaseName,

        [Parameter(Mandatory,ParameterSetName='List')]
        [Switch]$List
    )

    $PSBoundParameters
}