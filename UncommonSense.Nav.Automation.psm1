# Copyright (c) 2015 Jan Hoek
# https://github.com/jhoek/UncommonSense.Nav.Automation

# These functions use the CSide Integration Utilities library 
# written by Thaddeus Ryker, licensed under the Apache 2.0 License. 
# The source is obtainable at 
# http://code.edgerunner.org/dynamics-nav-client-interface-library. 

Add-Type -Path (Join-Path $PSScriptRoot Org.Edgerunner.Dynamics.Nav.CSide.dll)

. (Join-Path $PSScriptRoot Get-NAVDevelopmentClient.ps1)
. (Join-Path $PSScriptRoot Start-NAVDebugger.ps1)
. (Join-Path $PSScriptRoot Get-NAVApplicationObjectInfo.ps1)
. (Join-Path $PSScriptRoot Import-NAVApplicationObject.ps1)
. (Join-Path $PSScriptRoot Export-NAVApplicationObject.ps1)
. (Join-Path $PSScriptRoot Compile-NAVApplicationObject.ps1)
. (Join-Path $PSScriptRoot Set-WindowStyle.ps1)

Export-ModuleMember -Function Get-NAVDevelopmentClient
Export-ModuleMember -Function Start-NAVDebugger
Export-ModuleMember -Function Get-NAVApplicationObjectInfo
Export-ModuleMember -Function Import-NAVApplicationObject
Export-ModuleMember -Function Export-NAVApplicationObject
Export-ModuleMember -Function Compile-NAVApplicationObject