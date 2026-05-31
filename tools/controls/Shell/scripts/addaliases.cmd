@echo OFF
for %%I in ("%~dp0..\..\..\..\controls") do set "_controlsRoot=%%~fI"
pushd "%_controlsRoot%"

doskey ..=pushd ..
doskey ...=pushd ..\..
doskey ....=pushd ..\..\..
doskey .....=pushd ..\..\..\..
doskey ......=pushd ..\..\..\..\..
doskey src=pushd %CD%

popd
