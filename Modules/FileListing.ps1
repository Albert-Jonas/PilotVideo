<#
.SYNOPSIS
    Lists files in a folder with their last modification date and size.

.DESCRIPTION
    The function walks a specified directory (optionally recursing into sub‑directories)
    and produces objects that contain:
      - FullName: Full path to the file
      - LastWriteTime: Date and time the file was last modified
      - Length: Size of the file in bytes

.PARAMETER Path
    The path to the folder you want to scan.

.PARAMETER Recurse
    If present, the function will include files in subfolders.

.EXAMPLE
    # List files in C:\Logs
    Get-FileList -Path 'C:\Logs'

.EXAMPLE
    # List files recursively and output as a CSV
    Get-FileList -Path 'C:\Logs' -Recurse | Export-Csv -Path 'C:\logs_filelist.csv' -NoTypeInformation
#>
function Get-FileList {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
                   Position = 0,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [switch]$Recurse
    )

    begin {
        if (-not (Test-Path -Path $Path)) {
            throw "The path '$Path' does not exist."
        }
    }

    process {
        try {
            $items = Get-ChildItem -LiteralPath $Path `
                                   -File `
                                   -Recurse:$Recurse `
                                   -ErrorAction Stop

            $items | Select-Object `
                @{Name = 'FullName';      Expression = { $_.FullName }},
                @{Name = 'LastModified';  Expression = { $_.LastWriteTime }},
                @{Name = 'SizeBytes';     Expression = { $_.Length }}
        }
        catch {
            Write-Error "Failed to enumerate files in '$Path': $_"
        }
    }
}