function Get-IcingaCheckHttpJsonResponseChecks()
{
    param (
        [hashtable]$ParameterDefinitionList = @{ },
        [PSCustomObject]$JsonObjectToCheck  = $null,
        [switch]$NegateStringResults        = $FALSE,
        [string]$MetricIndex                = ''
    );

    if ($ParameterDefinitionList.Count -eq 0) {
        Exit-IcingaThrowException -Force -CustomMessage 'Unset argument "-ParameterDefinitionList" for "Get-IcingaCheckHttpJsonResponseChecks"' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing;
    }

    if ($null -eq $JsonObjectToCheck) {
        Exit-IcingaThrowException -Force -CustomMessage 'Unset argument "-JsonObjectToCheck" for "Get-IcingaCheckHttpJsonResponseChecks"' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginArgumentMissing;
    }

    Write-IcingaDebugMessage -Message 'Creating checks to perform';

    $Checks   = New-Object System.Collections.Generic.List[System.Object];
    $PerfData = New-Object System.Collections.Generic.List[System.String];

    foreach ($parameterDefinition in $ParameterDefinitionList.Values) {
        Write-IcingaDebugMessage -Message 'Create check for: {0}' -Objects $parameterDefinition;

        $ValueToCheck = Get-ValueFromJsonObject -JsonObjectToCheck $JsonObjectToCheck -Path $parameterDefinition.Path;

        Write-IcingaDebugMessage -Message 'Checking parameter with alias {0} and value {1}' -Objects $($parameterDefinition.Alias), $ValueToCheck;

        $ParameterCheck = New-IcingaCheck -Name ([string]::Format('Check returned value for {0}', $parameterDefinition.Alias)) -MetricIndex $MetricIndex -MetricName $parameterDefinition.Alias -MetricTemplate 'httpjsonresponsecheckvalue';

        if ($null -ne $ValueToCheck) {
            if ($parameterDefinition.ValueType -eq "Numeric") {
                Write-IcingaDebugMessage -Message 'parameter {0} is Numeric. Check value: "{1}", Thresholds Warn: "{2}", Critical: "{3}"' -Objects $($parameterDefinition.Alias), $ValueToCheck, $parameterDefinition.Warning, $parameterDefinition.Critical;
                $ParameterCheck.Value = $ValueToCheck
                if ($null -ne $parameterDefinition.Warning) {
                    $ParameterCheck.WarnOutOfRange($parameterDefinition.Warning) | Out-Null;
                }
                if ($null -ne $parameterDefinition.critical) {
                    $ParameterCheck.CritOutOfRange($parameterDefinition.Critical) | Out-Null;
                }
            } elseif ($parameterDefinition.ValueType -eq "DateTime") {
                Write-IcingaDebugMessage -Message 'parameter {0} is DateTime. Check value: "{1}", Thresholds Warn: "{2}", Critical: "{3}"' -Objects $($parameterDefinition.Alias), $ValueToCheck, $parameterDefinition.Warning, $parameterDefinition.Critical;
                $ParameterCheck.Value = [DateTime]::Parse($ValueToCheck).ToFileTime();
                if ($null -ne $parameterDefinition.Warning) {
                    $ParameterCheck.WarnDateTime($parameterDefinition.Warning) | Out-Null;
                }
                if ($null -ne $parameterDefinition.Critical) {
                    $ParameterCheck.CritDateTime($parameterDefinition.Critical) | Out-Null;
                }
            } elseif ($parameterDefinition.ValueType -eq "Boolean") {
                Write-IcingaDebugMessage -Message 'parameter {0} is Boolean. Check value: "{1}", Thresholds Warn: "{2}", Critical: "{3}"' -Objects $($parameterDefinition.Alias), $ValueToCheck, $parameterDefinition.Warning, $parameterDefinition.Critical;
                $ParameterCheck.Value = [bool]::Parse($ValueToCheck);
                if ($null -ne $parameterDefinition.Warning) {
                    $ParameterCheck.WarnIfNotMatch($parameterDefinition.Warning) | Out-Null;
                }
                if ($null -ne $parameterDefinition.Critical) {
                    $ParameterCheck.CritIfNotMatch($parameterDefinition.Critical) | Out-Null;
                }
            } elseif ($parameterDefinition.ValueType -eq "String") {
                Write-IcingaDebugMessage -Message 'parameter {0} is String. Check value: "{1}", Thresholds Warn: "{2}", Critical: "{3}"' -Objects $($parameterDefinition.Alias), $ValueToCheck, $parameterDefinition.Warning, $parameterDefinition.Critical;
                $ParameterCheck.Value = $ValueToCheck;
                if ($null -ne $parameterDefinition.Warning) {
                    $WarningThreshold = Get-IcingaHttpJsonStringThreshold -Threshold $parameterDefinition.Warning -NegateStringResults:$NegateStringResults;
                    if ($WarningThreshold.AlertIfLike) {
                        $ParameterCheck.WarnIfLike($WarningThreshold.Pattern) | Out-Null;
                    } else {
                        $ParameterCheck.WarnIfNotLike($WarningThreshold.Pattern) | Out-Null;
                    }
                }
                if ($null -ne $parameterDefinition.Critical) {
                    $CriticalThreshold = Get-IcingaHttpJsonStringThreshold -Threshold $parameterDefinition.Critical -NegateStringResults:$NegateStringResults;
                    if ($CriticalThreshold.AlertIfLike) {
                        $ParameterCheck.CritIfLike($CriticalThreshold.Pattern) | Out-Null;
                    } else {
                        $ParameterCheck.CritIfNotLike($CriticalThreshold.Pattern) | Out-Null;
                    }
                }
            } elseif ($parameterDefinition.ValueType -eq 'Info') {
                Write-IcingaDebugMessage -Message 'parameter {0} is Info. Value: "{1}"' -Objects $($parameterDefinition.Alias), $ValueToCheck;
                $ParameterCheck.Value      = $ValueToCheck;
                $ParameterCheck.NoPerfData = $TRUE;
            } elseif ($parameterDefinition.ValueType -eq 'PerfData') {
                Write-IcingaDebugMessage -Message 'parameter {0} is PerfData. Value: "{1}"' -Objects $($parameterDefinition.Alias), $ValueToCheck;
                $PerfData.Add((Format-IcingaHttpJsonPerfData -PerfData ([string]$ValueToCheck)));
            } else {
                Write-IcingaDebugMessage -Message 'Parameter type "{0}" not supported' -Objects $($parameterDefinition.ValueType);
            }

            if ($null -ne $ParameterCheck.Value) {
                Write-IcingaDebugMessage -Message 'Adding check "{0}"' -Objects $($ParameterCheck.Name);
                $Checks.Add($ParameterCheck);
            }
        } else {
            Write-IcingaDebugMessage -Message 'Parameter "{0}" not found in returned JSON object' -Objects $($parameterDefinition.Alias);
        }
    }

    Write-IcingaDebugMessage -Message 'Created {0} checks and {1} performance data entries' -Objects $($Checks.Count), $($PerfData.Count);

    return @{
        'Checks'   = $Checks;
        'PerfData' = $PerfData;
    };
}
