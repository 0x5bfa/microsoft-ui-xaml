@echo off
pushd "%~dp0..\.."
te.exe test\MUXControls.Test.dll /select:"@Classification='ScenarioTestSuite'"
set _exitCode=%ERRORLEVEL%
popd
exit /b %_exitCode%
