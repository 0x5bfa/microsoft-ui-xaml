##############################################################################  
##  
## Add-Aliases.ps1  
##
## Sets some common aliases for PowerShell consoles.
## Mostly based on aliases found in the aliases file next to this script.
##
##############################################################################  

if (-not $env:XcpRoot)
{
    $env:XcpRoot = "$env:reporoot\src\runtime\xcp"
}

function global:root { pushd $env:reporoot }
function global:native { pushd $env:XcpRoot\dxaml\dllsrv\winrt\native\$args }
function global:tfgr { pushd $env:reporoot\tests\runtime\native\external\foundation\graphics\rendering\$args }
function global:dxaml { pushd $env:reporoot\dxaml\$args }
function global:xcp { pushd $env:XcpRoot\$args }
function global:text { pushd $env:XcpRoot\core\native\text\Controls\$args }
function global:scripts { pushd $env:reporoot\tools\setup\init\$args }
function global:idl { pushd $env:XcpRoot\dxaml\idl\winrt\$args }
function global:elements { pushd $env:XcpRoot\core\core\elements\$args }
function global:core { pushd $env:XcpRoot\core\$args }
function global:codegen { pushd $env:reporoot\tools\runtime\XCPTypesAutoGen\XamlOM\Model\$args }
function global:masters { pushd $env:reporoot\tests\visualbaselines\$args }
function global:cb { git branch | select-string "\*" -raw }

function global:ctp { & "$env:reporoot\tests\infra\payload\tools\scripts\create\CreateTestPayload.cmd" $args; pushd "$env:reporoot\TestPayload\$env:BUILDPLATFORM$env:_BuildType" }
function global:ctps { & "$env:reporoot\tests\infra\payload\tools\scripts\create\CreateTestPayload.cmd" -mode ScenarioTestSuit $args; pushd "$env:reporoot\TestPayload\$env:BUILDPLATFORM$env:_BuildType" }
function global:dbo { & taskkill /f /im msbuild.exe; & taskkill /f /im vbcscompiler.exe; & rd $env:reporoot\BuildOutput -Force -Recurse }
function global:tp { pushd $env:reporoot\TestPayload }

# Specialized chdir commands
function global:up      { pushd ..\$args }
function global:up1     { pushd ..\$args }
function global:up2     { pushd ..\..\$args }
function global:up3     { pushd ..\..\..\$args }
function global:up4     { pushd ..\..\..\..\$args }
function global:up5     { pushd ..\..\..\..\..\$args }
function global:up6     { pushd ..\..\..\..\..\..\$args }
function global:up7     { pushd ..\..\..\..\..\..\..\$args }
function global:up8     { pushd ..\..\..\..\..\..\..\..\$args }
function global:up9     { pushd ..\..\..\..\..\..\..\..\..\$args }
function global:..      { pushd ..\$args }
function global:...     { pushd ..\$args }
function global:....     { pushd ..\..\$args }
function global:.....     { pushd ..\..\..\$args }
function global:......     { pushd ..\..\..\..\$args }
function global:.......     { pushd ..\..\..\..\..\$args }
function global:........     { pushd ..\..\..\..\..\..\$args }
function global:.........     { pushd ..\..\..\..\..\..\..\$args }
function global:..........     { pushd ..\..\..\..\..\..\..\..\$args }
function global:...........     { pushd ..\..\..\..\..\..\..\..\..\$args }
