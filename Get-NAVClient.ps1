function Get-NAVClient
{
    param
    (
        # Type of server to connect to (native or Microsoft SQL Server)
        [ValidateSet('SQL', 'Native')]
        [string]$DatabaseServerType = 'SQL',

        # Name of the server to connect to
        [string]$DatabaseServer,

        # Name of the database to open
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$DatabaseName
    )

    Write-Verbose "Looking for a client connected to $DatabaseServerType server $DatabaseServer with database $DatabaseName."
    $Client = [Org.Edgerunner.Dynamics.Nav.CSide.Client]::GetClient($DatabaseServerType, $($DatabaseServer.ToUpperInvariant()), $($DatabaseName.ToUpperInvariant()), $Null)

    if (-not $Client)
    {
        throw "A client connected to $DatabaseServerType server $DatabaseServer with database $DatabaseName is not running."
    }

    $Client
}