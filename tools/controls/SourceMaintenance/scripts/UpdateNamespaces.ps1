if ($env:RepoRoot)
{
    $repoRoot = $env:RepoRoot
}
else
{
    $repoRoot = [System.IO.Path]::GetFullPath("$PSScriptRoot\..\..\..\..")
}

$controlsSourceRoot = [System.IO.Path]::Combine($repoRoot, "src", "controls")
$controlsTestRoot = [System.IO.Path]::Combine($repoRoot, "tests", "controls")

$cppFiles = (Get-ChildItem $controlsSourceRoot -Filter "*.cpp" -Recurse -File) + (Get-ChildItem $controlsTestRoot -Filter "*.cpp" -Recurse -File)
$hFiles = (Get-ChildItem $controlsSourceRoot -Filter "*.h" -Recurse -File) + (Get-ChildItem $controlsTestRoot -Filter "*.h" -Recurse -File)
$idlFiles = (Get-ChildItem $controlsSourceRoot -Filter "*.idl" -Recurse -File) + (Get-ChildItem $controlsTestRoot -Filter "*.idl" -Recurse -File)
$csFiles = (Get-ChildItem $controlsSourceRoot -Filter "*.cs" -Recurse -File) + (Get-ChildItem $controlsTestRoot -Filter "*.cs" -Recurse -File)

foreach ($sourceFile in ($cppFiles + $hFiles + $idlFiles + $csFiles) | Sort-Object -Property @{Expression = {$_.Name}})
{
    [System.IO.FileSystemInfo]$sourceFile = $sourceFile

    Write-Host "    Updating $($sourceFile.Name)..."

    [string]$fileExtension = [System.IO.Path]::GetExtension($sourceFile.FullName)
    [string]$fileContents = [System.IO.File]::ReadAllText($sourceFile.FullName)
    $originalFileContents = $fileContents

    $replacements = @(
        @{Original = "Windows\.UI\.Xaml"; Replacement = "Microsoft.UI.Xaml"},
        @{Original = "Windows\.UI\.Composition"; Replacement = "Microsoft.UI.Composition"},
        @{Original = "Windows\.UI\.Colors"; Replacement = "Microsoft.UI.Colors"},
        @{Original = "Microsoft\.UI\.Xaml\.Interop\.TypeKind"; Replacement = "Windows.UI.Xaml.Interop.TypeKind"},
        @{Original = "Microsoft\.UI\.Xaml\.Interop\.TypeName"; Replacement = "Windows.UI.Xaml.Interop.TypeName"}
    )

    foreach ($replacement in $replacements)
    {
        $fileContents = $fileContents -replace $replacement.Original, $replacement.Replacement
    }
    
    if ($fileExtension -eq ".cpp" -or $fileExtension -eq ".h")
    {
        foreach ($replacement in $replacements)
        {
            $fileContents = $fileContents -replace $replacement.Original.Replace("\.", "::"), $replacement.Replacement.Replace(".", "::")
            $fileContents = $fileContents -replace $replacement.Original.Replace("\.", "_"), $replacement.Replacement.Replace(".", "_")
        }
    }

    if ($fileContents -ne $originalFileContents)
    {
        [System.IO.File]::WriteAllText($sourceFile.FullName, $fileContents, [System.Text.Encoding]::UTF8)
    }
}
