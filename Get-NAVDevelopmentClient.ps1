<#
.Synopsis
Retrieves a client object that represents a running Microsoft Dynamics NAV development client, 
or a list of all running Microsoft Dynamics NAV development clients.
#>
function Get-NAVDevelopmentClient
{
    [CmdletBinding()]
    Param
    (
        # Filters running clients by server type
        [Parameter(ValueFromPipeLineByPropertyName)]
        [ValidateSet('Native','Sql')]
        [Alias('DatabaseServerType')]
        [string]$DatabaseServerTypeFilter,

        # Filters running clients by server name
        [Alias('DatabaseServerName')]
        [string]$DatabaseServerNameFilter,

        # Filters running clients by database name
        [Alias('DatabaseName')]
        [string]$DatabaseNameFilter,

        # Return all running development clients, instead of only the first match
        [Switch]$List
    )

    Process
    {
        $FilteredClients = Get-FilteredClients -DatabaseServerType $DatabaseServerType -DatabaseServerName $DatabaseServerNameFilter -DatabaseName $DatabaseNameFilter

        # List mode
        if ($List)
        {
            return $FilteredClients
        }

        # Normal mode; return first match
        if ($FilteredClients)
        {
            return $FilteredClients | Select-Object -First 1
        }
    }
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
        WindowHandle = $Client.WindowHandle
        Client = $Client
    }
}

function Get-FilteredClients
{
    Param
    (
        [string]$DatabaseServerType,
        [string]$DatabaseServerName,
        [string]$DatabaseName
    )

     $Clients = [Org.Edgerunner.Dynamics.Nav.CSide.Client]::GetClients() | ForEach-Object { $_ | Get-NAVDevelopmentClientInfo }   

    if ($DatabaseServerType) 
    {
        $Clients = $Clients | Where-Object -Property DatabaseServerType -Eq $DatabaseServerType
    }
    if ($DatabaseServerName)
    {
        $Clients = $Clients | Where-Object -Property DatabaseServerName -Like $DatabaseServerName
    }
    if ($DatabaseName)
    {
        $Clients = $Clients | Where-Object -Property DatabaseName -Like $DatabaseName
    }

    $Clients
}

