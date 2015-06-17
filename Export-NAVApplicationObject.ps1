<#
.Synopsis
   Exports a NAV object to a disk file.
#>
function Export-NAVApplicationObject
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,ValueFromPipeLine,ValueFromPipeLineByPropertyName)]
        [Org.Edgerunner.Dynamics.Nav.CSide.Client]$Client,
    
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

        [System.IO.File]::WriteAllBytes($FilePath, $Bytes)
        Get-ChildItem -Path $FilePath
    }
    End
    {
    }
}
