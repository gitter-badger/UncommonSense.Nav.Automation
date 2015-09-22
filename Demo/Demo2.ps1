$SourceConfig = Get-NAVDatabaseConnectionConfig -Name CRONUSW12015
$SourceClient = $SourceConfig | Start-NAVDevelopmentClient -PassThru -WindowStyle Minimized
$SourceFolder = (New-Item (Join-Path $Home\Desktop Source) -ItemType Container -Force).FullName

$Objects = $SourceClient | Get-NAVApplicationObjectInfo -TypeFilter 'Table|Page' -IDFilter '1..10' # | Out-GridView -PassThru

if ($Objects)
{
    $TargetConfig = Get-NAVDatabaseConnectionConfig -Name CUSTOM
    $TargetClient = $TargetConfig | Start-NAVDevelopmentClient -PassThru -WindowStyle Minimized
    $TargetFolder = (New-Item (Join-Path $Home\Desktop Target) -ItemType Container -Force).FullName

    $Objects | Export-NAVApplicationObject -Client $SourceClient.Client -Path $SourceFolder
    $SourceClient.Client | Stop-NAVDevelopmentClient

    # Wait for breakpoint file to be released before closing second client
    Start-Sleep -Seconds 1

    $Objects | Export-NAVApplicationObject -Client $TargetClient.Client -Path $TargetFolder
    $TargetClient.Client | Stop-NAVDevelopmentClient

    Start-Process -FilePath 'C:\Program Files\Araxis\Araxis Merge\Compare.exe' -ArgumentList $SourceFolder, $TargetFolder -WindowStyle Maximized
}
