# Building & Running

## Build Controls in WinUI 3.0
1. Follow the instructions to [clone the WinUI repo](developer-guide.md#clone-the-winui-repo).
2. Initialize your environment
    * Running `init` with no additional parameters should be fine for WebView2 purposes.
3. Build entire WinUI repo
    * Only needed the first time you clone or sync to a new commit
    * Run `build` at repo root
4. Build Controls (if not building entire WinUI repo)
     * `msbuild <repo>\src\controls\solutions\MUXControls.slnx`

Other build options:
* Rebuild MUXC without using incremental build:
    * `msbuild <repo>\src\controls\solutions\MUXControls.slnx /t:Rebuild`
* For additional scoped builds, see the options in [tools\controls\Build\scripts\Build.cmd](../../tools/controls/Build/scripts/Build.cmd).

Additional notes:
* Multi-proc builds (default for `msb.cmd`) are not yet supported for MUXC. 
Therefore, use `msbuild.exe` (defaults to single-proc) as the build command (or `tools\controls\Build\scripts\Build.cmd`).
* If running in VS and getting an error asking to attach another debugger, make sure you are running with "mixed" 
debugging.

## Run WebView2 sample (MUXControlsTestApp)
1. Using the instructions in the [Testing FAQ](../testing/testing-FAQ.md), run
   [`scripts\runtime\testmachine-prerun.cmd`](../../tests/infra/payload/scripts/runtime/testmachine-prerun.cmd) if it has not
already been run.
2. Navigate to `<repo>\BuildOutput\bin\x86chk\Test` and run `MuxControlsTestApp.appx` to install.  
Run using the option in the install dialog, or as you would any other installed application.
    * Alternatively, run a test to install (a WebView2 test will ensure you have the correct Anaheim installed as well)
3. After app launches, click *WebView2* button, then choose a test page (usually *WebView2 Basic Tests*)
    * Invoke the *Load URI* button to navigate to Bing
    * Not providing fully qualified URI (like "www.bing.com" instead of "https://www.bing.com") will crash the app (for
    now).

### Run WebView2 sample in Visual Studio
Not working at this time  
~~1. In Visual Studio, set *Startup Project* dropdown menu to *'MUXControlsTestApp~~  
~~(..\tests\controls\apps\MUXControlsTestApp\MUXControlsTestApp) (Universal Windows)'*~~
~~2. Run on *Local Machine* with F5 or Control+F5~~  
    ~~F5 sometimes doesn't work due to missing environment variables. To work around this, temporarily change the~~  
    ~~incorrect paths in the error you see to hard-coded real paths.~~  

