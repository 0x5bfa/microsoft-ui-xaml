@echo OFF

for %%I in ("%~dp0..\..\..") do set "_repoRoot=%%~fI"
for %%I in ("%_repoRoot%\controls") do set "_controlsRoot=%%~fI"
pushd "%_controlsRoot%"

set PATH=%PATH%;%_repoRoot%\tools\controls

call "%_repoRoot%\tools\controls\Shell\addaliases.cmd"

"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -Latest -requires Microsoft.Component.MSBuild -property InstallationPath > %TEMP%\vsinstalldir.txt

set /p _VSINSTALLDIR15=<%TEMP%\vsinstalldir.txt

call "%_VSINSTALLDIR15%\Common7\Tools\VsDevCmd.bat"

pushd "%_controlsRoot%"

if '%1%' neq '/PreserveContext' (
    cmd /k
)
