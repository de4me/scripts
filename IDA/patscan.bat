@REM Create PAT files for IDA PRO
@REM version: 2025-07-29

@echo off

setlocal enabledelayedexpansion

if not defined FLAIRPATH set FLAIRPATH=c:\Program Files\IDA Professional 9.1\tools\flair\
if not defined PATTOOL set PATTOOL=pelf
if not defined SIGLENGTH set SIGLENGTH=38

if [%1] == [] goto help
if [%1] == [v] goto variables
if [%1] == [?] goto help
if [%2] == [] goto help

set PATH=%PATH%;%FLAIRPATH%

if not exist %2 (
  mkdir %2
)

for /r %1 %%f in (*.obj *.o *.lib *.a) do (
  if not exist %2\%%~nf.pat (
    call :convert "%%f" %2
  ) else (
    call :convert_rename "%%f" %2
  )
)

goto exit

:convert

%PATTOOL% -p%SIGLENGTH% "%~1" "%~2\%~n1.pat"

goto :eof

:convert_rename

echo %~1 %~2 

for /l %%n in (1,1,99) do (
  if not exist "%~2\%~n1%%n.pat" (
    %PATTOOL% -p%SIGLENGTH% "%~1" "%~2\%~n1%%n.pat"
    goto :eof
  )
)

goto :eof

:help

echo USE: %~n0 input_folder output_folder

goto exit

:variables

echo FLAIRPATH=%FLAIRPATH%
echo PATTOOL=%PATTOOL% [pcf pelf pmacho ppsx ptmobj]
echo SIGLENGTH=%SIGLENGTH% [32]

:exit

endlocal