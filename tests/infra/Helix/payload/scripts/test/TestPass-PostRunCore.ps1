Write-Host "TestPass-PostRunCore.ps1"

$payloadRoot = if ($env:HELIX_CORRELATION_PAYLOAD) { $env:HELIX_CORRELATION_PAYLOAD } else { (Get-Location).Path }
$postRunScript = Join-Path $payloadRoot "scripts\helix\setup\TestPass-PostRun.ps1"

if(Test-Path $postRunScript)
{
    & $postRunScript
}
