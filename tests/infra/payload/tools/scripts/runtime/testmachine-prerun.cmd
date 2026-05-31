@echo off
echo Time: %TIME%
pushd "%~dp0..\.."
powershell -NonInteractive -ExecutionPolicy Bypass -File "%~dp0..\helix\test\TestPass-OneTimeMachineSetupCore.ps1" %*
set _exitCode=%ERRORLEVEL%
popd
echo Time: %TIME%
exit /b %_exitCode%
