<#
.Synopsis
Retrieves a client object that represents a running Microsoft Dynamics NAV development client, 
or a list of all running Microsoft Dynamics NAV development clients.
#>
function Get-NAVDevelopmentClient
{
    Param
    (
        # Filters running clients by server type
        [Parameter(ParameterSetName='Filters')]
        [ValidateSet('Native','Sql')]
        [string]$DatabaseServerType,

        # Filters running clients by server name
        [Parameter(ParameterSetName='Filters')]
        [string]$DatabaseServerName,

        # Filters running clients by database name
        [Parameter(ParameterSetName='Filters')]
        [string]$DatabaseName,

        # Name of the configuration list file to use
        [Parameter(ParameterSetName='Config')]
        [string]$ConfigListFileName = $(Join-Path $PSScriptRoot 'devclients.txt'),

        # Name of the configuration to open
        [Parameter(Mandatory,ParameterSetName='Config')]
        [string]$ConfigName,

        [Parameter(ParameterSetName='Config')]
        [Switch]$Force,

        [Parameter(ParameterSetName='Config')]
        [ValidateSet('Hidden', 'Maximized', 'Minimized', 'Normal')]
        [string]$WindowStyle = 'Normal',

        # Return all running development clients, instead of only the first match
        [Switch]$List
    )
    
    Add-Type -Path (Join-Path $PSScriptRoot Org.Edgerunner.Dynamics.Nav.CSide.dll)

    # Find config
    if ($ConfigName)
    {
        $Header = 'Name,DevEnvPath,DatabaseServerType,DatabaseServerName,DatabaseName,ZupID'
        $Config = Import-Csv -Path $ConfigListFileName -Header | Where-Object Name -eq $ConfigName
        
        if (-not $Config) 
        {
            throw "Configuration '$ConfigName' could not be found in $ConfigListFileName."
        }

        $DatabaseServerType = $Config.DatabaseServerType
        $DatabaseServerName = $Config.DatabaseServerName 
        $DatabaseName = $Config.DatabaseName
    }

    $FilteredClients = Get-FilteredClients -DatabaseServerType $DatabaseServerType -DatabaseServerName $DatabaseServerName -DatabaseName $DatabaseName

    if ((-not $FilteredClients) -and ($ConfigName) -and ($Force))
    {
        $Arguments = @()
        $Arguments += ('servername={0}' -f $DatabaseServerName)
        $Arguments += ('database={0}' -f $DatabaseName)
        if ($ID) { $Arguments.Add('id={0}' -f $ID)  }

        Start-Process -FilePath $Config.DevEnvPath -ArgumentList ($Arguments -join ',')

        if ($WindowStyle -ne 'Normal')
        {
            Start-Sleep -Seconds 1
            Set-WindowStyle -MainWindowHandle $Process.MainWindowHandle -WindowStyle $WindowStyle
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

