. .\FileListing.ps1
. .\FolderListing.ps1
. .\SizeFilter.ps1

<#
.SYNOPSIS
    Interactive menu to collect listing parameters.

.DESCRIPTION
    Root folder path
    Whether to list files or folders
    Optional filter:
        Minimum size (KB)
        Maximum last write date
        Maximum number of results

    Show results and parameters
    Exit
#>

#region Variables
$RootFolder       = $null
$ListType         = 'Files'      # Default: show files only
$ApplyFilter      = $false

# Filter defaults
$MinSizeKB        = 0
$MaxLastWrite     = $null
$MaxResults       = 0           # 0 = all
#endregion

#region Menu Display
function Show-Menu {
    Clear-Host
    Write-Host "=== Listing Parameters Menu ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Current selections:" -ForegroundColor Yellow
    Write-Host "  1. Root folder     : $RootFolder"
    Write-Host "  2. List type       : $ListType"
    Write-Host "  3. Apply filter    : $ApplyFilter"
    if ($ApplyFilter) {
        Write-Host "     Minimum size (KB)   : $MinSizeKB"
        Write-Host "     Max last write date : $MaxLastWrite"
        Write-Host "     Max results         : $MaxResults"
    }
    Write-Host ""
    Write-Host "Menu:" -ForegroundColor Green
    Write-Host "  1) Set root folder"
    Write-Host "  2) Choose list type (Files / Folders)"
    Write-Host "  3) Toggle filter (current: $ApplyFilter)"
        if ($ApplyFilter) { Write-Host "  4) Set filter values" }
    Write-Host "  5) Show result & display parameters"
    Write-Host "  0) Exit without saving"
}
#endregion

#region Main Loop
do {
    Show-Menu
    $choice = Read-Host "`nSelect an option"

    switch ($choice) {
        '1' {
            $RootFolder = Read-Host "Enter full path of the root folder"
            if (-not (Test-Path $RootFolder)) {
                Write-Warning "Path does not exist try again."
                $RootFolder = $null
            }
        }
        '2' {
            Write-Host "Choose what to list:" -ForegroundColor Yellow
            Write-Host "  1) Files"
            Write-Host "  2) Folders"
            $t = Read-Host "Choice"
            switch ($t) {
                '1' { $ListType = 'Files' }
                '2' { $ListType = 'Folders' }
                default { Write-Warning "Invalid choice keeping previous setting." }
            }
        }
        '3' {
            $ApplyFilter = -not $ApplyFilter
            if ($ApplyFilter) {
                Write-Host "Filter enabled."
            }
            else {
                # Reset filter values when disabling
                $MinSizeKB     = 0
                $MaxLastWrite = $null
                $MaxResults    = 0
                Write-Host "Filter disabled."
            }
        }
        '4' {
            if (-not $ApplyFilter) { break }
            $MinSizeKBStr = Read-Host "Enter minimum size in KB (0 for no minimum)"
            if ([int]::TryParse($MinSizeKBStr, [ref]$tmp)) { $MinSizeKB = $tmp } else { $MinSizeKB = 0 }
            $dateStr = Read-Host "Enter maximum last access date (MM/DD/YYYY) leave blank for no limit"
            if ($dateStr -ne '') {
                try { $MaxLastWrite = [datetime]::Parse($dateStr) } catch { Write-Warning "Invalid date format ignoring."; $MaxLastWrite = $null }
            } else { $MaxLastWrite = $null }
            $maxResStr = Read-Host "Enter maximum number of results to show (0 for all)"
            if ([int]::TryParse($maxResStr, [ref]$tmp)) { $MaxResults = $tmp } else { $MaxResults = 0 }
        }
        '5' {
            # Show result and exit loop
            Write-Host "`n=== Final Parameters ===" -ForegroundColor Cyan
            Write-Host "Root folder   : $RootFolder"
            Write-Host "List type     : $ListType"
            Write-Host "Apply filter  : $ApplyFilter"
            if ($ApplyFilter) {
                Write-Host "  Minimum size (KB)   : $MinSizeKB"
                Write-Host "  Max last access date: $MaxLastWrite"
                Write-Host "  Max results         : $MaxResults"
            }
            
            if ($ListType -eq 'Files') {
                Get-FileList -Path $RootFolder -Recurse | Filter-BySize -MinimumSize $MinSizeKB -Unit KB -SizeProperty 'SizeBytes' | Out-Host
            }
            
            if ($ListType -eq 'Folders') {
                Get-LeafFolderSizes -Path $RootFolder | Filter-BySize -MinimumSize $MinSizeKB -Unit KB -SizeProperty 'SizeBytes' | Out-Host
            }

            pause
            break
        }
        '0' {
            Write-Host "Exiting without saving."
            exit
        }
        default {
            Write-Warning "Unknown option. Please choose again."
        }
    }
} while ($true)
#endregion