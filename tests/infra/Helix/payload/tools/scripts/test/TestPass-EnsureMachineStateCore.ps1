Write-Host "TestPass-EnsureMachineStateCore.ps1"

# List all processes to aid debugging:
Write-Host "(Skipping process listing to save time)"
#Write-Host "All processes running:"
#Get-Process | Format-Table -AutoSize

# Kill any instances of Windows Security Alert:
$windowTitleToMatch = "*Windows Security Alert*"
$procs = Get-Process | Where {$_.MainWindowTitle -like $windowTitleToMatch}
foreach ($proc in $procs)
{
    Write-Host "Found process with '$windowTitleToMatch' title: $proc"
    $proc.Kill();
}

$windowTitleToMatch = "*Install a new build*"
$procs = Get-Process | Where {$_.MainWindowTitle -like $windowTitleToMatch}
foreach ($proc in $procs)
{
    Write-Host "Found process with '$windowTitleToMatch' title: $proc"
    $proc.Kill();
}

# Minimize all windows:
$shell = New-Object -ComObject "Shell.Application"
$shell.minimizeall()

# Kill any running test processes
$testProcessNames = @(
    "te",
    "te.processhost",
    "dhandler", 
    "StartMenuExperienceHost",
    "TextInputHost",
    "ShellExperienceHost")
foreach($testProcessName in $testProcessNames)
{
    $procs = Get-Process -Name $testProcessName -ErrorAction SilentlyContinue
    foreach($proc in $procs) 
    { 
        Write-Host "Found running proc: $($proc.Name) - $($proc.Id)" 
        Write-Host "Killing Process" 
        Stop-Process $proc -Force
    }
}

$payloadRoot = if ($env:HELIX_CORRELATION_PAYLOAD) { $env:HELIX_CORRELATION_PAYLOAD } else { (Get-Location).Path }
$ensureMachineStateScript = Join-Path $payloadRoot "scripts\helix\setup\TestPass-EnsureMachineState.ps1"

if(Test-Path $ensureMachineStateScript)
{
    & $ensureMachineStateScript
}
