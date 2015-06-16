function Get-NAVDevelopmentClient
{
    param
    (
        # Type of server to connect to (native or Microsoft SQL Server)
        [Parameter(ParameterSetName="FromConfig")]
        [ValidateSet('SQL', 'Native')]
        [string]$DatabaseServerType = 'SQL',

        # Name of the server to connect to
        [Parameter(Mandatory, ParameterSetName="FromConfig")]
        [string]$DatabaseServer,

        # Name of the database to open
        [Parameter(Mandatory, ParameterSetName="FromConfig")]
        [string]$DatabaseName,

        # List the running development clients
        [Parameter(Mandatory,ParameterSetName="List")]
        [Switch]$List
    )

    if ($List)
    {
        [Org.Edgerunner.Dynamics.Nav.CSide.Client]::GetClients() | Select-Object -Property * -ExcludeProperty Tables, Objects
        return
    }

    Write-Verbose "Looking for a client connected to $DatabaseServerType server $DatabaseServer with database $DatabaseName."
    $Client = [Org.Edgerunner.Dynamics.Nav.CSide.Client]::GetClient($DatabaseServerType, $($DatabaseServer.ToUpperInvariant()), $DatabaseName, $Null)

    if (-not $Client)
    {
        throw "A client connected to $DatabaseServerType server $DatabaseServer with database $DatabaseName is not running."
    }

    $Client
}