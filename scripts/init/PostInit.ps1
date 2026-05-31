param(
    [Parameter(Mandatory=$true)] [string] $repoRoot,
    [string] $Verbosity = 'quiet'
)


if ($env:BUILDPLATFORM -eq $null)
{
    if ($env:amd64)
    {
        $buildPlatform = "x64"
    }
    elseif ($env:arm64)
    {
        $buildPlatform = "arm64"
    }
    else
    {
        $buildPlatform = "x86"
    }
}
else
{
    $buildPlatform = $env:BUILDPLATFORM
}

if (Test-Path "$repoRoot\build\PipelineScripts\GetLKGCompilerPackageInfoIfNeeded.ps1")
{
    # Trigger install of the LKG toolset by default, allowing customization.
    # Retrieve default package info if needed.
    . $repoRoot\build\PipelineScripts\GetLKGCompilerPackageInfoIfNeeded.ps1 -SourceDirectory $repoRoot
    
    # The following call skips download of the package if it already exists locally.
    . $repoRoot\build\PipelineScripts\DownloadLKGCompiler.ps1 -SourceDirectory $repoRoot
}

[System.Collections.Generic.List[string]]$mainPkgs = @()

# Regardless of the WinUI flavor we're building,
# we also always need to build a version of GenXbf needs to match the architecture of MSBuild - x64 for VS2022, x86 for all prior versions.
# So we need x86 and x64 for GenXbf no matter what.

# The others we'll pull down as needed.
$mainPkgs.Add("eng\packages\packages.config")
$mainPkgs.Add("eng\packages\packages.x86.config")
$mainPkgs.Add("eng\packages\packages.x64.config")

if (($buildPlatform -ne "x86") -and ($buildPlatform -ne "x64"))
{
    $mainPkgs.Add("eng\packages\packages.$buildPlatform.config")
}

Write-Host "Restoring packages for build platform $buildPlatform..." -NoNewline
$installed = 0
foreach ($pkg in $mainPkgs)
{
    Write-Progress "Restoring packages for build platform $buildPlatform..." -PercentComplete (100 * $installed / $mainPkgs.Count)
    nuget restore $repoRoot\$pkg -ConfigFile $repoRoot\nuget.config -PackagesDirectory $repoRoot\packages -Verbosity $Verbosity
    $installed++
}
Write-Host -ForegroundColor Green Done.
Write-Progress "Restoring packages for build platform $buildPlatform..." -Completed

. $repoRoot\scripts\init\DownloadDotNetCoreSdk.ps1
. $repoRoot\scripts\init\DownloadDotNetRuntimeInstaller.ps1

Write-Host "Restoring Maestro and ensuring authentication..."
msbuild -nologo -t:Restore $repoRoot\eng\restore\Microsoft.MaestroRestore.csproj -v:$Verbosity -p:Configuration=Release -p:NugetInteractive=true -p:PublishReadyToRun=true

Write-Host "Restoring additional packages..."
$isOssBuild = -not (Test-Path $repoRoot\src\compiler\BuildTasks\Microsoft\Lmr\XamlTypeUniverse.cs)
$pgoPackagesConfig = if ($isOssBuild) { 'eng\pgo\packages.OSS.config' } else { 'eng\pgo\packages.config' }
$projectPackages = @(
    (Join-Path $repoRoot $pgoPackagesConfig),
    (Join-Path $repoRoot 'eng\xamlcompiler\BuildGenXbfForMSBuild\BuildGenXbfForMSBuild.csproj'),
    (Join-Path $repoRoot 'eng\restore\Microsoft.MaestroRestore.csproj'),
    (Join-Path $repoRoot 'src\controls\dll\packages.config'),
    (Join-Path $repoRoot 'src\compiler\XamlCompilerPrerequisites.sln'),
    (Join-Path $repoRoot 'src\runtime\Microsoft.UI.Xaml.sln'),
    (Join-Path $repoRoot 'tools\runtime\XbfParser\XbfParser.sln'),
    (Join-Path $repoRoot 'src\compiler\XamlCompiler.sln')
)

# Check if this is an OSS build, where not all files are available
if ($isOssBuild)
{
    # We don't have all necessary files to build the compiler, so also restore
    # the project which uses the public compiler
    $projectPackages += Join-Path $repoRoot 'eng\xamlcompiler\XamlCompilerPublic.csproj'
}

$installed = 0
foreach ($project in $projectPackages)
{
    Write-Host "Restoring $project"
    Write-Progress "Restoring additional packages..." -PercentComplete (100 * $installed / $projectPackages.Count)
    nuget restore $project -ConfigFile $repoRoot\nuget.config -PackagesDirectory $repoRoot\packages -Verbosity $Verbosity
    $installed++
}
Write-Host -ForegroundColor Green Done.
Write-Progress "Restoring additional packages..." -Completed
