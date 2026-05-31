@echo off
set packagestate=%3
echo Package state :  %packagestate%
echo %* > args.txt
powershell -NonInteractive -ExecutionPolicy Bypass -File "%~dp0RunPerfWorkItem.ps1" -PackageState %packagestate% -ArgsFile .\args.txt
