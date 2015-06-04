<#
.Synopsis
   Exports a NAV object to a disk file.
#>
function Export-NAVApplicationObject
{
    [CmdletBinding()]
    Param
    (
        # Specifies the type of server to connect to (native or Microsoft SQL Server)
        [ValidateSet('SQL', 'Native')]
        [string]$DatabaseServerType = 'SQL',

        # Specifies the name of the database from which you want to export.
        [Parameter(Mandatory)]
        [string]$DatabaseName,

        # Specifies the name of the SQL server instance to which the database
        # you want to export from is attached. 
        [Parameter(Mandatory)]
        [string]$DatabaseServer,

        # Specifies the folder to export to.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path = $Pwd,

        # Specifies the type of the object to export
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('TableData','Table','Form','Report','Dataport','Codeunit','XMLport','MenuSuite','Page','Query')]
        [string]$Type,

        # Specifies the ID of the object to export
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [int]$ID,

        [Switch]$Force
    )

    Begin
    {
        $HelperLibraryFileName = Join-Path $PSScriptRoot Org.Edgerunner.Dynamics.Nav.CSide.dll
        Add-Type -Path $HelperLibraryFileName
        $Client = Get-NAVClient -DatabaseServerType $DatabaseServerType -DatabaseServer $DatabaseServer -DatabaseName $DatabaseName

        if ($Force)
        {
            if (-not (Test-Path -Path $Path))
            {
                New-Item -Path $Path -ItemType Container
            }
        }
    }
    Process
    {
        $memoryStream = $Client.ReadObjectToStream($type, $id) 

        $bytes = New-Object Byte[]($memoryStream.Length)
        $memoryStream.Seek(0, [System.IO.SeekOrigin]::Begin) | Out-Null
        $memoryStream.Read($bytes, 0, $memoryStream.Length) | Out-Null
        $memoryStream.Close()

        $FileName = [String]::Format("{0}{1}.txt", $type.ToString().SubString(0, 3).ToLowerInvariant(), $id)
        $FilePath = Join-Path $Path $FileName

        $fileStream = New-Object -TypeName "System.IO.FileStream"("$FilePath", [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
        $fileStream.Write($bytes, 0, $bytes.Length) | Out-Null
        $fileStream.Close()

        Get-ChildItem -Path $FilePath
    }
    End
    {
    }
}
