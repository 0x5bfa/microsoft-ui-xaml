rem usage: RunHelixWorkItem [testbinaries] (/taefQuery [taefQuery] /taefParameters [taefParameters])

: Due to the fact that the value for taefQuery is a complex expression including special symbols,
: we cannot directly pass it to Powershell. Instead we pass the arguments via a file which 
: the script will parse.
echo %* > args.txt
powershell -NonInteractive -ExecutionPolicy Bypass -File "%~dp0RunHelixWorkItem.ps1" -ArgsFile .\args.txt
