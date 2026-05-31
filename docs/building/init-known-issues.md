If you hit build errors saying that Visual Studio is missing the Spectre mitigation libs, you need to update your VS 
install to include these components. The easiest way to do this is to use the Visual Studio Installer to import the 
Visual Studio setup config under `tools\setup\vsconfig` in this repo.
