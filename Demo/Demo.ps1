. $(Join-Path $PSScriptRoot 'Compare-NAVApplication.ps1')

$SourceConfigName = 'SHIPIT2009R2NATIVE'
$TargetConfigName = 'SHIPIT2009R2'
$CompareToolFileName = 'C:\Program Files\Araxis\Araxis Merge\Compare.exe'

$BaseFolderName = [System.Environment]::GetFolderPath('Desktop')
$SourceFolderName = Join-Path $BaseFolderName $($SourceConfigName)
$TargetFolderName = Join-Path $BaseFolderName $($TargetConfigName)

if (Test-Path $SourceFolderName)
{
    Remove-Item $SourceFolderName -Force
}

if (Test-Path $TargetFolderName)
{
    Remove-Item $TargetFolderName -Force
}

Compare-NAVApplication `
    -SourceConfigName $SourceConfigName `
    -TargetConfigName $TargetConfigName `
    -SourceFolderName $SourceFolderName `
    -TargetFolderName $TargetFolderName `
    -TypeFilter '<>TableData' `
    -ModifiedFilter Yes 

Start-Process `
    -FilePath $CompareToolFileName `
    -ArgumentList $SourceFolderName, $TargetFolderName