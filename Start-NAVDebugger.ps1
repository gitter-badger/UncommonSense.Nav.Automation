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