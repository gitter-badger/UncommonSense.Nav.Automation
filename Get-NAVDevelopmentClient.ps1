<#
.Synopsis
Retrieves a client object that represents a running Microsoft Dynamics NAV development client, 
or a list of all running Microsoft Dynamics NAV development clients.
#>
function Get-NAVDevelopmentClient
{
    [CmdletBinding(DefaultParameterSetName='Config')]
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

        # Opens the specified configuration if it is not running yet
        [Parameter(ParameterSetName='Config')]
        [Switch]$Force,

        # Controls how the development client window is displayed
        [Parameter(ParameterSetName='Config')]
        [ValidateSet('Hidden', 'Maximized', 'Minimized', 'Normal')]
        [string]$WindowStyle = 'Normal',

        # Return all running development clients, instead of only the first match
        [Parameter(ParameterSetName='Filters')]
        [Switch]$List
    )

    DynamicParam
    {
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $True
        $ParameterAttribute.ParameterSetName = 'Config'

        $ConfigListFileName = Join-Path $PSScriptRoot 'devclients.txt'
        $Header = 'Name','DevEnvPath','DatabaseServerType','DatabaseServerName','DatabaseName','ZupPath'
        $Configs = Import-Csv -Path $ConfigListFileName -Header $Header | ForEach-Object { $_.Name }
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($Configs)

        $AttributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)
        $AttributeCollection.Add($ValidateSetAttribute)

        $DynamicParameter = New-Object -Type System.Management.Automation.RuntimeDefinedParameter('ConfigName', [string], $AttributeCollection)
        $ParameterDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParameterDictionary.Add('ConfigName', $DynamicParameter)

        return $ParameterDictionary 
    }
    Process
    {
        Add-Type -Path (Join-Path $PSScriptRoot Org.Edgerunner.Dynamics.Nav.CSide.dll)

        # Find config
        if ($PSCmdlet.MyInvocation.BoundParameters.ConfigName)
        {
            $ConfigListFileName = Join-Path $PSScriptRoot 'devclients.txt'
            $Header = 'Name','DevEnvPath','DatabaseServerType','DatabaseServerName','DatabaseName','ZupPath'
            $Configs = Import-Csv -Path $ConfigListFileName -Header $Header
            $Config = $Configs | Where-Object Name -eq $PSCmdlet.MyInvocation.BoundParameters.ConfigName
        
            if (-not $Config) 
            {
                throw "Configuration '$($PSCmdlet.MyInvocation.BoundParameters.ConfigName)' could not be found in $ConfigListFileName."
            }

            $DatabaseServerType = $Config.DatabaseServerType
            $DatabaseServerName = $Config.DatabaseServerName 
            $DatabaseName = $Config.DatabaseName
            $ZupPath = $Config.ZupPath
        }

        $FilteredClients = Get-FilteredClients -DatabaseServerType $DatabaseServerType -DatabaseServerName $DatabaseServerName -DatabaseName $DatabaseName

        if ((-not $FilteredClients) -and ($PSCmdlet.MyInvocation.BoundParameters.ConfigName) -and ($Force))
        {
            $Arguments = @()
            $Arguments += ('servername={0}' -f $DatabaseServerName)
            $Arguments += ('database={0}' -f $DatabaseName)

            if ($ZupPath) 
            { 
                $Arguments += ('id={0}' -f $ZupPath)  
            }

            $Process = Start-Process -FilePath $Config.DevEnvPath -ArgumentList ($Arguments -join ',') -PassThru
            Start-Sleep -Seconds 1

            if ($WindowStyle -ne 'Normal')
            {
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

