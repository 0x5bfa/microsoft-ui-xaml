@echo off

pushd %~dp0..

echo Deleting existing MUXCustomBuildTasks*.nupkg files...
del MUXCustomBuildTasks*.nupkg

call scripts\IncrementVersionNumber.cmd

msbuild /m %RepoRoot%\tools\controls\solutions\CustomTasks.slnx /restore /p:Configuration=Release /p:Platform="Any CPU" /t:Rebuild

call scripts\BuildNupkg.cmd
call scripts\PublishNupkg.cmd
call scripts\UpdateReferences.cmd

popd
