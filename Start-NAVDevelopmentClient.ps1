<#
.Synopsis
   Starts a NAV Development client
#>
function Start-NAVDevelopmentClient
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$DevEnvFilePath,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ServerName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Database,

        [string]$ID,

        [Switch]$PassThru
    )

    $Arguments = @()
    $Arguments += ('servername={0}' -f $ServerName)
    $Arguments += ('database={0}' -f $Database)
    if ($ID) { $Arguments.Add('id={0}' -f $ID)  }

    $ArgumentList = $Arguments -join ','
    $Process = Start-Process -FilePath $DevEnvFilePath -ArgumentList $ArgumentList -PassThru

    if ($PassThru)
    {
        $Process
    }
}