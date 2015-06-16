<#
.Synopsis
   Outputs a list of running NAV Development clients
#>
function Get-NAVDevelopmentClient
{
    [CmdletBinding()]

    $Clients = [Org.Edgerunner.Dynamics.Nav.CSide.Client]::GetClients($true) 
    
    foreach($Client in $Clients)
    {
        # Build a custom object with the relevant properties, so that what we output to the 
        # pipeline has no dependency on Org.Edgerunner.Dynamics.Nav.CSide.dll.
        # 

        $CustomObject = New-Object System.Object
        $CustomObject | Add-Member -Type NoteProperty -Name CSideVersion -Value $Client.CSideVersion
        $CustomObject | Add-Member -Type NoteProperty -Name DatabaseServerType -Value $Client.ServerType.ToString()
        $CustomObject | Add-Member -Type NoteProperty -name DatabaseServer -Value $Client.Server
        $CustomObject | Add-Member -Type NoteProperty -name DatabaseName -Value $Client.Database
        $CustomObject | Add-Member -Type NoteProperty -name CompanyName -Value $Client.Company

        $CustomObject
    }
}
