@echo off

nuget.exe pack %~dp0..\MUXCustomBuildTasks.nuspec -OutputDirectory %~dp0..
