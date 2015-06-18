function Test-DynamicParams
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [ValidateSet('Native','Sql')]
        [string]$DatabaseServerType = 'Sql'
    )

    DynamicParam
    {
        $ParameterDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary

        switch($PSBoundParameters.DatabaseServerType)
        {
            'Native'
            {
                $ParameterDictionary.Add('DatabaseServerName', (New-DynamicParameter -ParameterName DatabaseServerName -ParameterSetName NativeServer))            
                $ParameterDictionary.Add('DatabaseName', (New-DynamicParameter -ParameterName DatabaseName -ParameterSetName NativeStandAlone))                            
            }
            
            'SQL'
            {
                $ParameterDictionary.Add('DatabaseServerName', (New-DynamicParameter -ParameterName DatabaseServerName -ParameterSetName SQL))            
                $ParameterDictionary.Add('DatabaseName', (New-DynamicParameter -ParameterName DatabaseName -ParameterSetName SQL))            
            }
        }

        return $ParameterDictionary 
    }

    Process
    {
        $PSBoundParameters
    }
}

function New-DynamicParameter
{
    Param
    (
        [string]$ParameterName,
        [string]$ParameterSetName
    )

    $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
    $ParameterAttribute.Mandatory = $True
    $ParameterAttribute.ParameterSetName = $ParameterSetName

    $AttributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
    $AttributeCollection.Add($ParameterAttribute)

    New-Object -Type System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
}