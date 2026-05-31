Param(
    [Parameter(Mandatory = $true)] 
    [string]$WinUI2RepoRoot
)

if ($env:RepoRoot)
{
    $repoRoot = $env:RepoRoot
}
else
{
    $repoRoot = [System.IO.Path]::GetFullPath("$PSScriptRoot\..\..\..")
}

# First, we'll delete all of the existing resw files.
Write-Host "Deleting existing resw files..."

foreach ($projectFile in (Get-ChildItem "$repoRoot\src\controls" -Filter "*.vcxitems" -Recurse))
{
    Write-Host "    Deleting resw files from $($projectFile.FullName)..."

    $pathToProject = $projectFile.DirectoryName
    $reswFiles = Get-ChildItem $pathToProject -Filter "*.resw" -Recurse | Sort-Object -Property @{Expression = {$_.Name.Length}; Descending = $True}

    foreach ($reswFile in $reswFiles)
    {
        Remove-Item $reswFile.FullName | Out-Null
    }
}

# Next, we'll bring over the new resw files.
Write-Host "Copying over new resw files..."

$winUI2DevRoot = [System.IO.Path]::GetFullPath("$WinUI2RepoRoot\dev").TrimEnd('\')
$targetRoot = "$repoRoot\src\controls"

foreach ($projectFile in (Get-ChildItem "$WinUI2RepoRoot\dev" -Filter "*.vcxitems" -Recurse))
{
    Write-Host "    Copying resw files from $($projectFile.FullName)..."

    $pathToProject = $projectFile.DirectoryName
    $reswFiles = Get-ChildItem $pathToProject -Filter "*.resw" -Recurse | Sort-Object -Property @{Expression = {$_.Name.Length}; Descending = $True}

    foreach ($reswFile in $reswFiles)
    {
        $relativePath = $reswFile.FullName.Substring($winUI2DevRoot.Length).TrimStart('\')
        $targetPath = Join-Path $targetRoot $relativePath
        $targetDirectory = [System.IO.Path]::GetDirectoryName($targetPath)

        if (-not [System.IO.Directory]::Exists($targetDirectory))
        {
            New-Item -Path $targetDirectory -ItemType Directory | Out-Null
        }

        Copy-Item $reswFile.FullName $targetPath | Out-Null
    }
}
