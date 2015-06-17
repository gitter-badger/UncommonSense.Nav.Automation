<#
.Synopsis
Starts the NAV Debugger
.Description
This function opens the session list window in the selected NAV client. From the session list, you can select a session to debug.
Configurations are taken from a comma-separated (csv) file called `clients.txt` in the module folder. Each line in the file represents a single configuration, and
consists of the following values:

- ID: a unique ID for each configuration; this is the value you specify for the -Config parameter.
- ClientExePath: the full path (including the file name) to the Microsoft Dynamics NAV Role Tailored Client.
- ServerName: the name of the computer on which the Microsoft Dynamics NAV Service Tier is running.
- PortNo: the port number that the Microsoft Dynamics NAV Service Tier is listening to.
- ServiceInstanceName: the name of the Microsoft Dynamics NAV Service Tier instance.
- CompanyName: the name of the company to use during debugging.

#>
function Start-NAVDebugger
{
    [CmdletBinding()]
    Param
    (
    )

    DynamicParam
    {
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $True

        $ConfigsPath = Join-Path $PSScriptRoot 'clients.txt'
        $Configs = Import-Csv -Path $ConfigsPath -Header ID,ClientExePath,ServerName,PortNo,ServiceInstanceName,CompanyName | ForEach-Object { $_.ID }
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($Configs)

        $AttributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)
        $AttributeCollection.Add($ValidateSetAttribute)

        $DynamicParameter = New-Object -Type System.Management.Automation.RuntimeDefinedParameter('Config', [string], $AttributeCollection)
        $ParameterDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParameterDictionary.Add('Config', $DynamicParameter)

        return $ParameterDictionary 
    }

    Process
    {
        $ConfigsPath = Join-Path $PSScriptRoot 'clients.txt'
        $Configs = Import-Csv -Path $ConfigsPath -Header ID,ClientExePath,ServerName,PortNo,ServiceInstanceName,CompanyName
        $Config = $Configs | Where-Object { $_.ID -eq $PSBoundParameters.Config } | Select-Object -First 1
        $Arguments = [uri]::EscapeUriString("DynamicsNAV://$($Config.ServerName):$($Config.PortNo)/$($Config.ServiceInstanceName)/$($Config.CompanyName)/debug")

        Write-Debug "Starting $($Config.ClientExePath) with $Arguments"
        Start-Process -FilePath $Config.ClientExePath -ArgumentList $Arguments 
    }
}