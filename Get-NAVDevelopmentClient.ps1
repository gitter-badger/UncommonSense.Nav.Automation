<#
.Synopsis
Retrieves a client object that represents a running Microsoft Dynamics NAV development client, 
or a list of all running Microsoft Dynamics NAV development clients.
#>
function Get-NAVDevelopmentClient
{
    Param
    (
        # Connect to SQL Server
        [Parameter(Mandatory,ParameterSetName='Sql')]
        [Switch]$Sql,

        # Connect to a native database (either servered or stand-alone)
        [Parameter(Mandatory,ParameterSetName='NativeServer')]
        [Parameter(Mandatory,ParameterSetName='NativeStandAlone')]
        [Switch]$Native,

        # Name of the server to connect to
        [Parameter(Mandatory,ParameterSetName='Sql')]
        [Parameter(Mandatory,ParameterSetName='NativeServer')]
        [string]$DatabaseServerName,

        # Name of the database to open
        [Parameter(Mandatory,ParameterSetName='Sql')]
        [Parameter(Mandatory,ParameterSetName='NativeStandAlone')]
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

    switch($Sql)
    {
        ($true) { $DatabaseServerType = 'Sql' }
        ($false) { $DatabaseServerType = 'Native' }
    }

    $Clients = $Clients | Where-Object -Property DatabaseServerType -Eq $DatabaseServerType

    if ($DatabaseServerName)
    {
        # Using the -Like operator, so that we can support wildcards in database server name
        $Clients = $Clients | Where-Object -Property DatabaseServerName -Like $DatabaseServerName
    }

    if ($DatabaseName)
    {
        # Using the -Like operator, so that we can support wildcards in database name
        $Clients = $Clients | Where-Object -Property DatabaseName -Like $DatabaseName
    }

    $Client = $Clients | Select-Object -First 1

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