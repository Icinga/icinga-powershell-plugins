function Get-IcingaHttpJsonStringThreshold()
{
    param (
        [string]$Threshold           = '',
        [switch]$NegateStringResults = $FALSE
    );

    [bool]$AlertIfLike = $TRUE;

    if ($Threshold.StartsWith('!')) {
        $AlertIfLike = $FALSE;
        $Threshold   = $Threshold.Substring(1);
    }

    if ($NegateStringResults) {
        $AlertIfLike = -not $AlertIfLike;
    }

    return @{
        'Pattern'     = $Threshold;
        'AlertIfLike' = $AlertIfLike;
    };
}
