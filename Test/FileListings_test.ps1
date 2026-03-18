. "$PSScriptRoot\..\Modules\FileListing.ps1"

# ------------------------------------------------------------------
# 1️⃣  ASSERTION HELPERS
# ------------------------------------------------------------------
function Assert-Equal {
    param([object]$Actual, [object]$Expected, [string]$Message = '')
    if ($Actual -ne $Expected) {
        Throw "❌  $Message`n   Actual:   $Actual`n   Expected: $Expected"
    }
}

function Get-PropertyValue {
    param(
        [object]$Obj,
        [string]$Prop
    )

    if ($Obj -is [hashtable]) {
        # Hashtable – use key lookup
        return $Obj[$Prop]
    } else {
        # PSCustomObject, FileInfo, etc. – use property access
        return $Obj.$Prop
    }
}

function Assert-ObjectEquals {
    param(
        [psobject]$Actual,
        [psobject]$Expected,
        [hashtable[]]$PropertyMap = @(
            @{ActualProp='FullName'    ; ExpectedProp='FullName'},
            @{ActualProp='LastModified'; ExpectedProp='LastWriteTime'},
            @{ActualProp='SizeBytes'      ; ExpectedProp='Length'}
        )
    )

    foreach ($map in $PropertyMap) {
        $a = Get-PropertyValue -Obj $Actual   -Prop $map.ActualProp
        $e = Get-PropertyValue -Obj $Expected -Prop $map.ExpectedProp

        Assert-Equal -Actual $a -Expected $e `
                     -Message "Property $($map.ActualProp)"
    }
}

function Assert-ListEquals {
    param(
        [psobject[]]$ActualList,
        [psobject[]]$ExpectedList
    )
    $act = $ActualList | Sort-Object FullName
    $exp = $ExpectedList | Sort-Object FullName

    Assert-Equal -Actual $act.Count -Expected $exp.Count -Message "List count"

    for ($i = 0; $i -lt $exp.Count; $i++) {
        Assert-ObjectEquals -Actual $act[$i] -Expected $exp[$i] -Message "Object #$($i+1)"
    }
}

# ------------------------------------------------------------------
# 2️⃣  TEST RUNNER
# ------------------------------------------------------------------
$script:TotalTests  = 0
$script:PassedTests = 0

function Run-TestCase {
    param(
        [string]$Name,
        [hashtable]$Parameters,
        [psobject[]]$ExpectedData   # <-- this is the *in‑script* test data
    )
    $script:TotalTests++
    Write-Host "`n=== [$Name] ===" -ForegroundColor Cyan

    try {
        # 1️⃣  Run the function
        $actual = Get-FileList @Parameters

        # 2️⃣  Compare
        Assert-ListEquals -ActualList $actual -ExpectedList $ExpectedData

        Write-Host "✅  PASS" -ForegroundColor Green
        $script:PassedTests++
    } catch {
        Write-Host "❌  FAIL: $_" -ForegroundColor Red
    }
}

# ------------------------------------------------------------------
# 3️⃣  DEFINE TEST CASES
# ------------------------------------------------------------------
$TestCases = @(
    @{
        Name   = 'Root folder'
        Params = @{ Path = "$PSScriptRoot\TestData" }
        Expected = @(
            @{
                FullName       = "$PSScriptRoot\TestData\file1.txt";
                LastWriteTime  = [datetime]::Parse('2024-04-01T09:00:00');
                Length           = 1271
            },
            @{
                FullName       = "$PSScriptRoot\TestData\File2.txt";
                LastWriteTime  = [datetime]::Parse('2025-05-10T23:00:00');
                Length           = 5096
            }
            @{
                FullName       = "$PSScriptRoot\TestData\File3.txt";
                LastWriteTime  = [datetime]::Parse('2021-06-15T13:00:00');
                Length           = 2611200
            }
            @{
                FullName       = "$PSScriptRoot\TestData\File4.txt";
                LastWriteTime  = [datetime]::Parse('2022-03-20T11:00:00');
                Length           = 652800
            }
            @{
                FullName       = "$PSScriptRoot\TestData\File5.txt";
                LastWriteTime  = [datetime]::Parse('2025-10-25T12:00:00');
                Length           = 40800
            }
        )
    },
    @{
        Name   = 'Folder B'
        Params = @{ Path = "$PSScriptRoot\TestData\FolderB" }
        Expected = @(
            @{
                FullName       = "$PSScriptRoot\TestData\FolderB\fileB1.txt";
                LastWriteTime  = [datetime]::Parse('2024-12-10T10:15:00');
                Length           = 652800
            }
            @{
                FullName       = "$PSScriptRoot\TestData\FolderB\fileB2.txt";
                LastWriteTime  = [datetime]::Parse('2025-07-15T12:30:00');
                Length           = 40800
            }
        )
    },
    @{
        Name   = 'Root folder recursive'
        Params = @{ Path = "$PSScriptRoot\TestData"; Recurse = $true }
        Expected = @(
            @{
                FullName       = "$PSScriptRoot\TestData\file1.txt";
                LastWriteTime  = [datetime]::Parse('2024-04-01T09:00:00');
                Length           = 1271
            },
            @{
                FullName       = "$PSScriptRoot\TestData\File2.txt";
                LastWriteTime  = [datetime]::Parse('2025-05-10T23:00:00');
                Length           = 5096
            }
            @{
                FullName       = "$PSScriptRoot\TestData\File3.txt";
                LastWriteTime  = [datetime]::Parse('2021-06-15T13:00:00');
                Length           = 2611200
            }
            @{
                FullName       = "$PSScriptRoot\TestData\File4.txt";
                LastWriteTime  = [datetime]::Parse('2022-03-20T11:00:00');
                Length           = 652800
            }
            @{
                FullName       = "$PSScriptRoot\TestData\File5.txt";
                LastWriteTime  = [datetime]::Parse('2025-10-25T12:00:00');
                Length           = 40800
            }
            @{
                FullName       = "$PSScriptRoot\TestData\FolderA\fileA1.txt";
                LastWriteTime  = [datetime]::Parse('2021-03-01T12:00:00');
                Length           = 1271
            }
            @{
                FullName       = "$PSScriptRoot\TestData\FolderA\fileA2.txt";
                LastWriteTime  = [datetime]::Parse('1994-04-11T15:00:00');
                Length           = 5096
            }
            @{
                FullName       = "$PSScriptRoot\TestData\FolderA\fileA3.txt";
                LastWriteTime  = [datetime]::Parse('2024-03-01T09:00:00');
                Length           = 40800
            }
            @{
                FullName       = "$PSScriptRoot\TestData\FolderB\fileB1.txt";
                LastWriteTime  = [datetime]::Parse('2024-12-10T10:15:00');
                Length           = 652800
            }
            @{
                FullName       = "$PSScriptRoot\TestData\FolderB\fileB2.txt";
                LastWriteTime  = [datetime]::Parse('2025-07-15T12:30:00');
                Length           = 40800
            }
        )
    }
)

# ------------------------------------------------------------------
# 4️⃣  EXECUTE THE TESTS
# ------------------------------------------------------------------
foreach ($tc in $TestCases) {
    Run-TestCase -Name $tc.Name -Parameters $tc.Params -ExpectedData $tc.Expected
}

# ------------------------------------------------------------------
# 5️⃣  SUMMARY
# ------------------------------------------------------------------
Write-Host "`n=== TEST SUMMARY ===" -ForegroundColor Yellow
Write-Host "Total: $TotalTests  |  Passed: $PassedTests  |  Failed: $( $TotalTests - $PassedTests )"
if ($PassedTests -ne $TotalTests) { exit 1 }   # non‑zero exit code signals failure