<#
.SYNOPSIS
    Lists all leaf directories under a given root folder with their size.

.DESCRIPTION
    A leaf directory is defined as a folder that contains **no other subfolders**.
    The size reported is the sum of all files that are directly inside that folder
    (and, if you want, any nested files – the function uses `-Recurse` to be safe).

.PARAMETER Path
    Path to the root folder you want to scan.

.EXAMPLE
    # List all leaf folders under C:\Logs
    Get-LeafFolderSizes -Path 'C:\Logs'

.EXAMPLE
    # Show the results in a nicely formatted table
    Get-LeafFolderSizes -Path 'C:\Logs' | Format-Table -AutoSize
#>

function Get-LeafFolderSizes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
                   Position = 0,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    begin {
        # Verify that the supplied path exists
        if (-not (Test-Path -LiteralPath $Path)) {
            throw "The path '$Path' does not exist."
        }
    }

    process {
        # 1. Get every folder in the tree
        $allDirs = Get-ChildItem -LiteralPath $Path -Directory -Recurse -Force

        # 2. Filter those that have *no* subfolders
        $leafDirs = $allDirs | Where-Object {
            $subCount = (Get-ChildItem -LiteralPath $_.FullName -Directory -Force -ErrorAction SilentlyContinue).Count
            $subCount -eq 0
        }

        # 3. For each leaf directory, calculate size
        $leafDirs | ForEach-Object {
            # Size of all files in this leaf (recursion is harmless there are no subfolders)
            $sizeInfo = Get-ChildItem -LiteralPath $_.FullName -File -Force -Recurse -ErrorAction SilentlyContinue |
                        Measure-Object -Property Length -Sum

            $bytes = $sizeInfo.Sum
            $fileCount = $sizeInfo.Count

            # Human friendly size
            $formatted = if ($bytes -ge 1GB) { "{0:N2} GB" -f ($bytes/1GB) }
                          elseif ($bytes -ge 1MB) { "{0:N2} MB" -f ($bytes/1MB) }
                          elseif ($bytes -ge 1KB) { "{0:N2} KB" -f ($bytes/1KB) }
                          else { "$bytes Bytes" }

            [pscustomobject]@{
                Folder          = $_.FullName
                SizeBytes       = $bytes
                SizeFormatted   = $formatted
                FileCount       = $fileCount
            }
        } | Sort-Object SizeBytes -Descending   # optional: order by size
    }
}