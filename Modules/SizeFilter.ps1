<#
.SYNOPSIS
    Filters a stream of objects by a numeric size property.

.DESCRIPTION
    The function looks for a size property named either
    * `Length` (the default for file objects)
    * `SizeBytes` (the default for folder size objects)
    * or any custom property you specify with the -SizeProperty parameter.

    The threshold you supply can be expressed in Bytes, KB, MB, or GB.
    The comparison is inclusive objects whose size is *equal to* the threshold are kept.

.PARAMETER MinimumSize
    The minimum size that an object must have to pass through the filter.
    The value is interpreted according to the selected -Unit.

.PARAMETER Unit
    The unit of the MinimumSize value.  
    Valid values are Bytes, KB, MB, or GB (case insensitive).

.PARAMETER SizeProperty
    Name of the property that contains the size in bytes.  
    If omitted, the function tries `Length` first, then `SizeBytes`.

.EXAMPLE
    # Keep only files larger than 10MB
    Get-FileList -Path 'C:\Logs' | Filter-BySize -MinimumSize 10 -Unit MB

.EXAMPLE
    # Keep only leaf folders bigger than 500MB
    Get-LeafFolderSizes -Path 'C:\Logs' | Filter-BySize -MinimumSize 500 -Unit MB

.EXAMPLE
    # Keep objects where the custom property TotalSize is over 1GB
    Get-MyCustomOutput | Filter-BySize -MinimumSize 1 -Unit GB -SizeProperty TotalSize
#>
function Filter-BySize {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [object]$InputObject,

        [Parameter(Mandatory = $true)]
        [double]$MinimumSize,

        [Parameter()]
        [ValidateSet('Bytes','KB','MB','GB',IgnoreCase = $true)]
        [string]$Unit = 'Bytes',

        [Parameter()]
        [string]$SizeProperty
    )

    begin {
        # Convert the threshold to bytes once
        $bytesFactor = switch ($Unit.ToUpper()) {
            'BYTES' { 1 }
            'KB'    { 1KB }
            'MB'    { 1MB }
            'GB'    { 1GB }
            default { throw "Unsupported unit: $Unit" }
        }
        $thresholdBytes = [int64]($MinimumSize * $bytesFactor)
    }

    process {
        if ($null -eq $InputObject) { return }
        # Determine the size property to use
        if ($null -eq $SizeProperty) {
            if ($InputObject.PSObject.Properties.Match('Length').Count -gt 0) {
                $propName = 'Length'
            } elseif ($InputObject.PSObject.Properties.Match('SizeBytes').Count -gt 0) {
                $propName = 'SizeBytes'
            } else {
                Write-Verbose "No known size property found on object: $($InputObject.GetType().FullName)"
                return
            }
        } else {
            $propName = $SizeProperty
        }

        # Pull the size value
        $sizeVal = $InputObject | Select-Object -ExpandProperty $propName -ErrorAction SilentlyContinue

        # Skip objects that don't have a numeric size
        if (-not ($sizeVal -is [int] -or $sizeVal -is [long] -or $sizeVal -is [double])) {
            Write-Verbose "Object does not contain a numeric '$propName' property."
            return
        }

        # Compare and output if it meets the threshold
        if ($sizeVal -ge $thresholdBytes) {
            $InputObject
        }
    }
}
