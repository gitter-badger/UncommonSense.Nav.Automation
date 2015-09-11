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
        [Parameter(ParameterSetName='Filters')]
        [Parameter(Mandatory,ParameterSetName='Settings')]
        [ValidateSet('Native','Sql')]
        [string]$DatabaseServerType,

        # Filters running clients by server name
        [Parameter(ParameterSetName='Filters')]
        [string]$DatabaseServerName,

        # Filters running clients by database name
        [Parameter(ParameterSetName='Filters')]
        [string]$DatabaseName,

        # Return all running development clients, instead of only the first match
        [Parameter(ParameterSetName='Filters')]
        [Switch]$List,

        # Opens the specified configuration if it is not running yet
        [Parameter(ParameterSetName='Settings')]
        [Switch]$Force,

        [Parameter(ParameterSetName='Settings')]
        [ValidateScript( { Test-Path $_ } )]
        [string]$DevClientPath,

        [Parameter(ParameterSetName='Settings')]
        [string]$LiteralDatabaseServerName,

        [Parameter(ParameterSetName='Settings')]
        [string]$LiteralDatabaseName,

        # Controls how the development client window is displayed
        [Parameter(ParameterSetName='Settings')]
        [ValidateSet('Hidden', 'Maximized', 'Minimized', 'Normal')]
        [string]$WindowStyle = 'Normal'
    )

    Process
    {
        $FilteredClients = Get-FilteredClients -DatabaseServerType $DatabaseServerType -DatabaseServerName $DatabaseServerName -DatabaseName $DatabaseName

        if (-not $FilteredClients) 
        {
            if ($Force)
            {
                if (-not $LiteralDatabaseServerName)
                {
                    $LiteralDatabaseServerName = $DatabaseServerName
                }

                if (-not $LiteralDatabaseName)
                {
                    $LiteralDatabaseName = $DatabaseName
                }

                Start-NavDevelopmentClient -DevClientPath $DevClientPath -DatabaseServerType $DatabaseServerType -DatabaseServerName $LiteralDatabaseServerName -DatabaseName $LiteralDatabaseName -WindowStyle $WindowStyle
            }
        }
        
        $FilteredClients = Get-FilteredClients -DatabaseServerType $DatabaseServerType -DatabaseServerName $DatabaseServerName -DatabaseName $DatabaseName

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

