function Set-LastAccessDate {
    <#
    .SYNOPSIS
        Sets the LastWriteTime  of one or more files to a specified date.

    .PARAMETER Path
        Full path(s) of the files to update.  Supports wildcards.

    .PARAMETER Date
        The date (and time) you want to assign to the files’ LastWriteTime .

    .EXAMPLE
        # Set the last‑access time of a single file
        Set-LastAccessDate -Path 'C:\Temp\example.txt' -Date (Get-Date '2024-01-01 08:00')

    .EXAMPLE
        # Update a whole folder of files
        Set-LastAccessDate -Path 'C:\Temp\Logs\*.log' -Date (Get-Date '2024-01-15')
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [DateTime]$Date
    )

    # Resolve each path (expand wildcards, validate existence)
    $items = $Path | ForEach-Object {
        Get-Item -LiteralPath $_ -ErrorAction Stop
    }

    if ($PSCmdlet.ShouldProcess("$($items.Count) file(s)", "Set LastWriteTime  to $Date")) {
        foreach ($item in $items) {
            try {
                $item.LastWriteTime  = $Date
                Write-Verbose "[$($item.FullName)] → $Date"
            }
            catch {
                Write-Warning "Failed to set LastWriteTime  for $($item.FullName): $_"
            }
        }
    }
}

Set-LastAccessDate -Path '.\TestData\File1.txt' -Date (Get-Date '2024-04-01 09:00')
Set-LastAccessDate -Path '.\TestData\File2.txt' -Date (Get-Date '2025-05-10 23:00')
Set-LastAccessDate -Path '.\TestData\File3.txt' -Date (Get-Date '2021-06-15 13:00')
Set-LastAccessDate -Path '.\TestData\File4.txt' -Date (Get-Date '2022-03-20 11:00')
Set-LastAccessDate -Path '.\TestData\File5.txt' -Date (Get-Date '2025-10-25 12:00')

Set-LastAccessDate -Path '.\TestData\FolderB\FileB1.txt' -Date (Get-Date '2024-12-10 10:15')
Set-LastAccessDate -Path '.\TestData\FolderB\FileB2.txt' -Date (Get-Date '2025-07-15 12:30')

Set-LastAccessDate -Path '.\TestData\FolderA\FileA1.txt' -Date (Get-Date '2021-03-01 12:00')
Set-LastAccessDate -Path '.\TestData\FolderA\FileA2.txt' -Date (Get-Date '1994-04-11 15:00')
Set-LastAccessDate -Path '.\TestData\FolderA\FileA3.txt' -Date (Get-Date '2024-03-01 09:00')