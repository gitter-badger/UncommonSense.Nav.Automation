function Test-Stuff
{
    Param
    (
        [Parameter(ValueFromPipeLine,ValueFromPipelineByPropertyName)]
        [Org.Edgerunner.Dynamics.Nav.CSide.Client]$Client
    )

    Process
    {
        $Client.GetTable(2000000006).Name
    }
}

Write-Host Via pipeline, from list:
Get-NAVDevelopmentClient -List | Select-Object -First 1 | Test-Stuff

Write-Host As parameter:
Test-Stuff -Client (Get-NavDevelopmentClient -List | Select-Object -First 1 | Select-Object -ExpandProperty Client) 

Write-Host Assigned to a variable:
$Client = Get-NavDevelopmentClient -List | Select-Object -First 1 | Select-Object -ExpandProperty Client
Test-Stuff -Client $Client

Write-Host Via pipeline, with settings:
Get-NAVDevelopmentClient -DatabaseServerType SQL -DatabaseServerName 'MACMINI-I\NAVDEMO' -DatabaseName 'Demo Database NAV (8-0)' | Test-Stuff