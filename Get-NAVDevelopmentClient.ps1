<#
.Synopsis
Retrieves a client object that represents a running Microsoft Dynamics NAV development client, 
or a list of all running Microsoft Dynamics NAV development clients.
#>
function Get-NAVDevelopmentClient
{
    Param
    (
        # Type of server to connect to (native or Microsoft SQL Server)
        [Parameter(ParameterSetName="FromSettings")]
        [ValidateSet('SQL', 'Native')]
        [string]$DatabaseServerType = 'SQL',

        # Name of the server to connect to
        [Parameter(Mandatory, ParameterSetName="FromSettings")]
        [string]$DatabaseServerName,

        # Name of the database to open
        [Parameter(Mandatory, ParameterSetName="FromSettings")]
        [string]$DatabaseName,

        # List the running development clients
        [Parameter(Mandatory,ParameterSetName="List")]
        [Switch]$List
    )

    Add-Type -Path (Join-Path $PSScriptRoot Org.Edgerunner.Dynamics.Nav.CSide.dll)
    $Clients = [Org.Edgerunner.Dynamics.Nav.CSide.Client]::GetClients() | ForEach-Object { $_ | Get-NAVDevelopmentClientInfo }

    if ($List)
    {
        return $Clients
    }

    $Client = 
        $Clients | `
        Where-Object -Property DatabaseServerType -EQ $DatabaseServerType | `
        Where-Object -Property DatabaseServerName -EQ $DatabaseServerName | `
        Where-Object -Property DatabaseName -EQ $DatabaseName | `
        Select-Object -First 1

    if (-not $Client)
    {
        throw "A client connected to $DatabaseServerType server $DatabaseServerName with database $DatabaseName is not running."
    }

    $Client
}

function Get-NAVDevelopmentClientInfo
{
    Param
    (
        [Parameter(Mandatory,ValueFromPipeLine)]
        [Org.EdgeRunner.Dynamics.Nav.CSide.Client]$Client   
    )

    <#
    Returning Org.EdgeRunner.Dynamics.Nav.CSide.Clients directly from GetNAVDevelopmentClient 
    causes PowerShell to resolve all properties, including Tables and Objects, which are very
    expensive performance-wise. Instead, we now return a custom object with a Client *property*,
    which can be used directly by functions that accept values from the pipeline *by property
    name*. Expand the Client property using Select-Object when not passing the client via the 
    pipeline. All the other client information is readily available from the custom object.
    #>

    [PSCustomObject]@{
        DatabaseServerType = $Client.ServerType
        DatabaseServerName = $Client.Server
        DatabaseName = $Client.Database
        Company = $Client.Company
        CSideVersion = $Client.CSideVersion
        ApplicationVersion = $Client.ApplicationVersion
        Client = $Client
    }
}