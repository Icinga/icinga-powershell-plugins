function Format-IcingaHttpJsonPerfData()
{
    param (
        [string]$PerfData = ''
    );

    $Metrics = New-Object System.Collections.Generic.List[System.String];

    foreach ($Match in [regex]::Matches($PerfData, "'[^']*'=\S*|`"[^`"]*`"=\S*|\S+")) {
        [string]$Metric    = $Match.Value;
        [int]$SeparatorPos = $Metric.IndexOf('=');

        if ($Metric.StartsWith("'") -or $Metric.StartsWith('"')) {
            $SeparatorPos = $Metric.IndexOf($Metric[0], 1) + 1;
        }

        if ($SeparatorPos -le 0 -or $SeparatorPos -ge $Metric.Length -or $Metric[$SeparatorPos] -ne '=') {
            $Metrics.Add(($Metric -replace '[''"]', ''));
            continue;
        }

        [string]$Label = (($Metric.Substring(0, $SeparatorPos) -replace '[''"]', '').Trim() -replace '[\s=]+', '_');
        [string]$Value = ($Metric.Substring($SeparatorPos + 1) -replace '[''"]', '');

        $Metrics.Add([string]::Format('{0}={1}', $Label, $Value));
    }

    return [string]::Join(' ', $Metrics);
}
