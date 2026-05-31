[CmdLetBinding()]
# Example usage:
# ./GenerateNewControlProject.ps1 MyControl
#
Param(
    [Parameter(Mandatory = $true)]
    [string]$controlName
)

function FindAndReplaceInFile
{
    Param($file, $regex, $replace)

    $content = Get-Content $file -Raw

    [regex]$pattern = $regex
    $content = $pattern.replace($content, $replace, 1)

    Set-Content -Path $file -Value $content

}

function AddAttribute
{
    Param([xml]$xml, $element, $attrName, $attrValue)

    $attribute = $xml.CreateAttribute($attrName)
    $attribute.Value = $attrValue;
    $element.Attributes.Append($attribute)
}

$toolsDir = Split-Path (Split-Path -Path $MyInvocation.MyCommand.Path) -Parent
$repoRoot = [System.IO.Path]::GetFullPath("$PSScriptRoot\..\..\..\..")
$muxControlsDir = Join-Path $repoRoot "controls"
$muxControlsSolutionsDir = Join-Path $muxControlsDir "solutions"
$controlsSourceDir = Join-Path $repoRoot "src\controls"
$controlsTestDir = Join-Path $repoRoot "tests\controls"
$controlDir = Join-Path $controlsSourceDir $controlName
$controlTestUiDir = Join-Path $controlsTestDir "testui\$controlName"
$controlApiTestsDir = Join-Path $controlsTestDir "apitests\$controlName"
$controlInteractionTestsDir = Join-Path $controlsTestDir "interactiontests\$controlName"

$newDir = New-Item $controlDir -ItemType Directory
if (!$newDir)
{
    Write-Error "Control directory could not be created."
    exit 1
}

$from = Join-Path $toolsDir "Templates\*"
Copy-Item $from $controlDir -Recurse

# Replace NEWCONTROL with $controlName in file names
Get-ChildItem -Path $controlDir -Filter "*NEWCONTROL*" -Recurse | Rename-Item -NewName {$_.name -replace 'NEWCONTROL', $controlName }

# Replace NEWCONTROL with $controlName in file contents
$files = Get-ChildItem -Path $controlDir -Recurse -File
foreach ($file in $files)
{
    (Get-Content $file.PSPath) | Foreach-Object { 
        $_ -replace "NEWCONTROLUPPERCASE", $controlName.ToUpper() `
           -replace "NEWCONTROL", $controlName
    } | Set-Content $file.PSPath
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $controlTestUiDir) | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $controlApiTestsDir) | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $controlInteractionTestsDir) | Out-Null
Move-Item -LiteralPath (Join-Path $controlDir "TestUI") -Destination $controlTestUiDir
Move-Item -LiteralPath (Join-Path $controlDir "APITests") -Destination $controlApiTestsDir
Move-Item -LiteralPath (Join-Path $controlDir "InteractionTests") -Destination $controlInteractionTestsDir

# Add project to FeatureAreas.props
$featureAreasProps = Join-Path $muxControlsDir "build\FeatureAreas.props";
[xml]$xml = Get-Content $featureAreasProps
$featureEnabledName = "Feature" + $controlName + "Enabled"
foreach ($group in $xml.Project.ChildNodes)
{
    if($group.NodeType -eq "Comment")
    {
        # Get comment before list of all areas
        if($null -ne $group.NextSibling.Attributes -and $null -ne $group.NextSibling.Attributes['Condition'].Value -and $group.NextSibling.Attributes['Condition'].Value.Contains("(SolutionName) != 'MUXControlsInnerLoop'"))
        {
            # Comment for dependencies
            $controlDependenciesComment = $xml.CreateComment(" Dependencies for $($controlName) ")
            $xml.Project.InsertBefore($controlDependenciesComment, $group);

            # Control dependencies list
            $controlDependenciesNode = $xml.CreateElement("PropertyGroup",$xml.Project.NamespaceURI);
            $controlDependenciesCondition = "Exists('`$(InnerLoopAreasProps)') And `$(SolutionName) == 'MUXControlsInnerLoop' And `$(" + $featureEnabledName + ") == 'true'"
            AddAttribute $xml $controlDependenciesNode "Condition" $controlDependenciesCondition
            # Make node have empty content and not be a one liner
            $controlDependenciesNode.InnerText = "";
            $xml.Project.InsertBefore($controlDependenciesNode, $group);
        }
    }else
    {
        # Add new control to list of all controls to build
        if ($null -ne $group.Attributes['Condition'].Value -and $group.Attributes['Condition'].Value.Contains("(SolutionName) != 'MUXControlsInnerLoop'"))
        {
            $enabled = $xml.CreateElement($featureEnabledName, $xml.Project.NamespaceURI);
            $enabled.AppendChild($xml.CreateTextNode("true"));
            $group.AppendChild($enabled);
        }
    }
}

$xml.Save($featureAreasProps)

# Add project to MUXC project via ProjectImports.targets
$muxProject = Join-Path $muxControlsDir "build\ProjectImports.targets";
[xml]$xml = Get-Content $muxProject
[xml]$xml = Get-Content $muxProject
foreach ($group in $xml.Project.ImportGroup)
{
        $import = $xml.CreateElement("Import", $xml.Project.NamespaceURI);
        AddAttribute $xml $import "Project" "`$(MUXControlsSourceRoot)$controlName\$controlName.vcxitems"
        AddAttribute $xml $import "Label" "Shared"
        AddAttribute $xml $import "Condition" "`$($($featureEnabledName)) == 'true' Or `$($($featureEnabledName)) == 'productOnly'"
        $group.AppendChild($import);
    
}
$xml.Save($muxProject)

# Add tests to MUXControls.Test.csproj
$testProject = Join-Path $controlsTestDir "MUXControls.Test\MUXControls.Test.csproj";
[xml]$xml = Get-Content $testProject
$import = $xml.CreateElement("Import", $xml.Project.NamespaceURI);
AddAttribute $xml $import "Project" "`$(MUXControlsTestRoot)interactiontests\$controlName\$($controlName)_InteractionTests.projitems"
AddAttribute $xml $import "Label" "Shared"
AddAttribute $xml $import "Condition" "`$($($featureEnabledName)) == 'true'"
$xml.Project.AppendChild($import);
$xml.Save($testProject)

# Add test page to MUXControlsTestApp.csproj
$testAppProject = Join-Path $controlsTestDir "apps\MUXControlsTestApp\MUXControlsTestApp.csproj";
[xml]$xml = Get-Content $testAppProject
$import = $xml.CreateElement("Import", $xml.Project.NamespaceURI);
AddAttribute $xml $import "Project" "`$(MUXControlsTestRoot)testui\$controlName\$($controlName)_TestUI.projitems"
AddAttribute $xml $import "Label" "Shared"
AddAttribute $xml $import "Condition" "`$($($featureEnabledName)) == 'true'"
$xml.Project.AppendChild($import);
$xml.Save($testAppProject)

# Add API test project
$testAppProject = Join-Path $controlsTestDir "apps\MUXControlsTestApp\MUXControlsTestApp.csproj";
[xml]$xml = Get-Content $testAppProject
$import = $xml.CreateElement("Import", $xml.Project.NamespaceURI);
AddAttribute $xml $import "Project" "`$(MUXControlsTestRoot)apitests\$controlName\$($controlName)_APITests.projitems"
AddAttribute $xml $import "Label" "Shared"
AddAttribute $xml $import "Condition" "`$($($featureEnabledName)) == 'true'"
$xml.Project.AppendChild($import);
$xml.Save($testAppProject)

# Add new profiler id to RuntimeProfiler.h
FindAndReplaceInFile (Join-Path $controlsSourceDir "Telemetry\RuntimeProfiler.h") "(\s*ProfId_Size.*\s*})" @"

        ProfId_$controlName,`$1
"@
# Randomize class name for multiple use of class in one powershell
$id = get-random

# We need double backslash for C# strings below
$cleanMuxControlsSolutionsDir = $muxControlsSolutionsDir.Replace("\","\\") + "\\"
$cleanControlsSourceDir = $controlsSourceDir.Replace("\","\\") + "\\"
$cleanControlsTestDir = $controlsTestDir.Replace("\","\\") + "\\"

Write-Output "$cleanMuxControlsSolutionsDir"

$assemblies=(
    "System","EnvDTE","EnvDTE80", "Microsoft.VisualStudio.Interop"
)

$source=@"
using System;
using EnvDTE;
using EnvDTE80;
using System.Collections.Generic;
namespace SolutionHelper
{
    public static class SolutionRegister$id{
        public static void Main(){
            Console.WriteLine("Started script");
            // dte.17 is for visual studio 2022
            var dteType = Type.GetTypeFromProgID("VisualStudio.DTE.17.0", true);
            if(dteType == null)
            {
                Console.WriteLine("You need to install Visual Studio to add projects to the solution");
                return;
            }
            var dte = (EnvDTE.DTE)System.Activator.CreateInstance(dteType);
            Solution2 solution = (Solution2)dte.Solution;
            Console.WriteLine("Got solution class");

            var solutionNames = new List<string>(){"MUXControls.sln","MUXControlsInnerLoop.sln"};
            foreach(var solutionName in solutionNames)
            {
                Console.WriteLine("Opening solution: $($cleanMuxControlsSolutionsDir)" + solutionName);
                solution.Open("$cleanMuxControlsSolutionsDir" + solutionName);
                Console.WriteLine("Opened solution");
                var sourceFolder = solution.Projects.Item(1);
    
                // Get correct reference here:
                Console.WriteLine("Get source folder");
                var devSolutionFolder = (SolutionFolder)sourceFolder.Object;
                Console.WriteLine("Add folder");
                SolutionFolder newControlFolder = (SolutionFolder)devSolutionFolder.AddSolutionFolder("$controlName").Object;

                Console.WriteLine("Adding projects:");
                Console.WriteLine(" -Adding source");
                newControlFolder.AddFromFile("$($cleanControlsSourceDir)$($controlName)\\$($controlName).vcxitems");
                Console.WriteLine(" -Adding API test");
                newControlFolder.AddFromFile("$($cleanControlsTestDir)apitests\\$($controlName)\\$($controlName)_APITests.shproj");
                Console.WriteLine(" -Adding test UI");
                newControlFolder.AddFromFile("$($cleanControlsTestDir)testui\\$($controlName)\\$($controlName)_TestUI.shproj");
                Console.WriteLine(" -Adding interactions test");
                newControlFolder.AddFromFile("$($cleanControlsTestDir)interactiontests\\$($controlName)\\$($controlName)_InteractionTests.shproj");
                Console.WriteLine("Finished adding projects, saving solution");

                solution.Close(true);
                Console.WriteLine("Saved solution " + solutionName);
            }
        }
    }
}
"@

# Add vswhere path to environment paths
$env:path += ';' + ${env:ProgramFiles(x86)} + "\Microsoft Visual Studio\Installer\"

# Call vswhere to get the installation path
$vspath = vswhere -property installationPath

# Generate dll location
$solutionPaths = $vspath + "\Common7\IDE\PublicAssemblies";

$envdtePath = $solutionPaths + "\envdte.dll"
$envdete80Path = $solutionPaths + "\envdte80.dll"
$interopPath = $solutionPaths + "\microsoft.visualstudio.interop.dll"

Add-Type -Path $envdtePath
Add-Type -Path $envdete80Path
Add-Type -Path $interopPath

Add-Type -ReferencedAssemblies $assemblies -TypeDefinition $source -Language CSharp

Invoke-Expression "[SolutionHelper.SolutionRegister$id]::Main()"
