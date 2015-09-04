. C:\users\jhoek\GitHub\Scripts\Get-HelpAsMarkDown.ps1
Set-Location C:\Users\jhoek\Documents\WindowsPowerShell\Modules\UncommonSense.Nav.Automation

Import-Module UncommonSense.Nav.Automation -Force
Get-Command `
    -Module UncommonSense.Nav.Automation | `
    Sort-Object -Property Noun,Verb | `
        Get-HelpAsMarkDown `
            -Title UncommonSense.Nav.Automation `
            -Description 'PowerShell utils for Microsoft Dynamics NAV' `
            -PrefacePath (Join-Path $Pwd PREFACE.md) `
            -PostfacePath (JOin-Path $Pwd POSTFACE.md) |`
                Out-File .\README.md #>

