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

Get-NAVDevelopmentClient -List | Select-Object -First 1 | Test-Stuff
Write-Host Foo
Test-Stuff -Client (Get-NavDevelopmentClient -List | Select-Object -First 1 | Select-Object -ExpandProperty Client) 
Write-Host Baz
$Client = Get-NavDevelopmentClient -List | Select-Object -First 1 | Select-Object -ExpandProperty Client
Test-Stuff -Client $Client
Write-Host MyDatabase
Get-NAVDevelopmentClient -DatabaseServerType SQL -DatabaseServerName 'JANHOEK1FC5\NAVDEMO' -DatabaseName 'Demo Database NAV (8-0)' | Test-Stuff