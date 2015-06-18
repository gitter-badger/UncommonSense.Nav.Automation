function Test-DynamicParams
{
    [CmdletBinding()]
    Param
    (
    )

    DynamicParam
    {
        $ParameterDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary

        if ((-not $PSBoundParameters.Server))
        {
            $ParameterDictionary.Add('Server', (New-DynamicParameter -ParameterName Server))            
            $ParameterDictionary.Add('Database', (New-DynamicParameter -ParameterName Database))            
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
        [Parameter(Mandatory)]
        [string]$ParameterName
    )

    $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
    $ParameterAttribute.Mandatory = $True

    $AttributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
    $AttributeCollection.Add($ParameterAttribute)

    New-Object -Type System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
}

Test-DynamicParams