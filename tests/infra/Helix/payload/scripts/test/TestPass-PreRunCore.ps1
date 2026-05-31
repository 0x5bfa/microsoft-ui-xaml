Write-Host "TestPass-PreRunCore.ps1"

$payloadRoot = if ($env:HELIX_CORRELATION_PAYLOAD) { $env:HELIX_CORRELATION_PAYLOAD } else { (Get-Location).Path }
$preRunScript = Join-Path $payloadRoot "scripts\helix\commands\TestPass-PreRun.ps1"

if(Test-Path $preRunScript)
{
    & $preRunScript
}
