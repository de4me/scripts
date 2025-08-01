@REM Create SIG file for IDA PRO
@REM version: 2025-07-29

@echo off

setlocal enabledelayedexpansion

if not defined FLAIRPATH set FLAIRPATH=c:\Program Files\IDA Professional 9.1\tools\flair\

if [%1] == [] goto help
if [%1] == [v] goto variables
if [%1] == [?] goto help
if [%2] == [] goto help

if [%3] == [] (
  set SIGNNAME=%~n1
) else (
  set SIGNNAME=%3
)

set PATH=%PATH%;%FLAIRPATH%

set ARRAY=

for /r %1 %%f in (*.pat) do (
  set ARRAY=!ARRAY! %%f
)

sigmake -n"%SIGNNAME%" !ARRAY! %2

goto exit

:help

echo USE: %~n0 input_folder output.sig [name]

goto exit

:variables

echo FLAIRPATH=%FLAIRPATH%

:exit

endlocal