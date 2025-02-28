@REM DATE 22:56 15.02.2025

@echo off

if [%1] == [reset] (
 if [%2] == [] (
  set PRESET=
  set BV=
  set MAXBV=
  set BUFSIZEV=
  set VIDEOH=
  set SCALEV=
  set CRF=
  set PROFILEV=
  set TUNEV=
  set CODECV=
  set CODECA=
  set FILTERV=
  set INPUTPARAMS=
  set OUTPUTPARAMS=
  set NAMESUFFIX=
  goto exit
 ) else if [%2] == [540p] (
  set BV=2000k
  set MAXBV=3000k
  set BUFSIZEV=6000k
  set VIDEOH=540
  set SCALEV=
  goto exit
  ) else if [%2] == [hq540p] (
  set BV=2500k
  set MAXBV=4000k
  set BUFSIZEV=8000k
  set VIDEOH=540
  set SCALEV=
  goto exit
 ) else if [%2] == [720p] (
  set BV=
  set MAXBV=
  set BUFSIZEV=
  set VIDEOH=
  set SCALEV=
  goto exit
 ) else if [%2] == [hq720p] (
  set BV=4000k
  set MAXBV=7000k
  set BUFSIZEV=14000k
  set VIDEOH=720
  set SCALEV=
  goto exit
 ) else if [%2] == [1080p] (
  set BV=5000k
  set MAXBV=8000k
  set BUFSIZEV=16000k
  set VIDEOH=1080
  set SCALEV=
  goto exit
 ) else if [%2] == [hq1080p] (
  set BV=7000k
  set MAXBV=10000k
  set BUFSIZEV=20000k
  set VIDEOH=1080
  set SCALEV=
  goto exit
 )
)

setlocal

if "%PRESET%" == "" set PRESET=slower
if "%BV%" == "" set BV=3000k
if "%MAXBV%" == "" set MAXBV=5000k
if "%BUFSIZEV%" == "" set BUFSIZEV=10000k
if "%VIDEOH%" == "" set VIDEOH=720
if "%CRF%" == "" set CRF=18
if "%PROFILEV%" == "" set PROFILEV=high
if "%TUNEV%" == "" set TUNEV=film
if "%CODECV%" == "" set CODECV=libx264
if "%CODECA%" == "" set CODECA=copy
if "%SCALEV%" == "" set SCALEV=-2:'min(%VIDEOH%,ih)'
if "%FILENAMESUFFIX%" == "" set FILENAMESUFFIX=_%VIDEOH%p
if "%THREADSNUMBER%" == "" set THREADSNUMBER=0

if [%1] == [] goto help
if [%1] == [?] goto help
if [%1] == [v] goto variables
if [%1] == [reset] goto help

if [%1] == [crf] (
 shift /1
) else if [%1] == [abr] (
 shift /1
 set OUTPUTPARAMS=-b:v %BV% %OUTPUTPARAMS%
) else (
 if [%1] == [vbv] shift /1
 set OUTPUTPARAMS=-b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% %OUTPUTPARAMS%
)

if [%1] == [] goto help
if [%1] == [2pass] goto twopass
if [%2] == [] goto args_count_1
if [%3] == [] goto args_count_2
if [%4] == [] goto args_count_3
if [%5] == [] goto args_count_4
goto help

:twopass

if "%LOGNAMEPREFIX%" == "" set LOGNAMEPREFIX=%~n0-%random%%random%%random%

if [%2] == [] goto help
if [%3] == [] goto args_2pass_count_1
if [%4] == [] goto args_2pass_count_2
if [%5] == [] goto args_2pass_count_3
if [%6] == [] goto args_2pass_count_4
goto help

:variables

echo VARIABLES:
echo 	CODECV = %CODECV% [list: ffmpeg -encoders]
echo 	CODECA = %CODECA% [list: ffmpeg -encoders]
echo 	PRESET = %PRESET% [ultrafast superfast veryfast faster fast medium slow slower veryslow]
echo 	PROFILEV = %PROFILEV% [baseline main high high10 high422 high444]
echo 	TUNEV = %TUNEV% [film animation grain stillimage fastdecode zerolatency]
echo 	CRF = %CRF% [A lower value generally leads to higher quality and a subjectively sane range is x264: 17-28 (23), x265: 24-34 (28)]
echo 	BV = %BV%
echo 	MAXBV = %MAXBV%
echo 	BUFSIZEV = %BUFSIZEV%
echo 	VIDEOH = %VIDEOH%
echo 	SCALEV = %SCALEV%
echo 	FILTERV = %FILTERV% [crop=in_w:in_h-44]
echo 	INPUTPARAMS = %INPUTPARAMS% [-benchmark -itsscale 1.0 -t 00:10:00]
echo 	OUTPUTPARAMS = %OUTPUTPARAMS% [-dn -an -map_metadata -1 -c:s mov_text -x264-params keyint=40:min-keyint=10:no-deblock]
echo 	FILENAMESUFFIX = %FILENAMESUFFIX% [_720p]
echo 	LOGNAMEPREFIX = %LOGNAMEPREFIX% [ffmpeg2pass]
echo 	THREADSNUMBER = %THREADSNUMBER% [number of threads: 0 - optimal]
goto clean_exit

:help

echo USE:
echo 	%~n0 [? v]
echo 	%~n0 [crf abr vbv] [2pass] input
echo 	%~n0 [crf abr vbv] [2pass] input output
echo 	%~n0 [crf abr vbv] [2pass] HH:MM:SS input output
echo 	%~n0 [crf abr vbv] [2pass] HH:MM:SS HH:MM:SS input output
echo 	%~n0 reset [540p hq540p 720p hq720p 1080p hq1080p]
echo EXAMPLE:
echo 	set PRESET=fast
echo 	%~n0 reset 540p
echo 	%~n0 crf 2pass 00:10:00 00:20:00 input.mkv output_540p.mp4
echo 	%~n0 reset 720p
echo 	%~n0 vbv 2pass 00:10:00 00:20:00 input.mkv output_720p.mp4
goto clean_exit

:args_count_1

set INPUTFILENAME=%1
set OUTPUTFILENAME="%~n1%FILENAMESUFFIX%.mp4"
goto convert

:args_count_2

set INPUTFILENAME=%1
set OUTPUTFILENAME=%2
goto convert

:args_count_3

set INPUTFILENAME=%2
set OUTPUTFILENAME=%3
set INPUTPARAMS=-ss %1 %INPUTPARAMS%
goto convert

:args_count_4

set INPUTFILENAME=%3
set OUTPUTFILENAME=%4
set INPUTPARAMS=-ss %1 -to %2 %INPUTPARAMS%
goto convert

:args_2pass_count_1

set INPUTFILENAME=%2
set OUTPUTFILENAME="%~n2%FILENAMESUFFIX%.mp4"
goto convert_2pass


:args_2pass_count_2

set INPUTFILENAME=%2
set OUTPUTFILENAME=%3
goto convert_2pass

:args_2pass_count_3

set INPUTFILENAME=%3
set OUTPUTFILENAME=%4
set INPUTPARAMS=-ss %2 %INPUTPARAMS%
goto convert_2pass

:args_2pass_count_4

set INPUTFILENAME=%4
set OUTPUTFILENAME=%5
set INPUTPARAMS=-ss %2 -to %3 %INPUTPARAMS%
goto convert_2pass

:convert

ffmpeg -hide_banner %INPUTPARAMS% -i %INPUTFILENAME% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%,%FILTERV%" -threads %THREADSNUMBER% %OUTPUTPARAMS% %OUTPUTFILENAME%
goto clean_exit

:convert_2pass

ffmpeg -hide_banner -y %INPUTPARAMS% -i %INPUTFILENAME% -c:v %CODECV% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -crf %CRF% -vf "scale=%SCALEV%,%FILTERV%" -an  -threads %THREADSNUMBER% %OUTPUTPARAMS% -pass 1 -passlogfile "%LOGNAMEPREFIX%" -f null NUL && ^
ffmpeg -hide_banner %INPUTPARAMS% -i %INPUTFILENAME% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%,%FILTERV%" -threads %THREADSNUMBER% %OUTPUTPARAMS% -pass 2 -passlogfile "%LOGNAMEPREFIX%" %OUTPUTFILENAME%
del /Q "%LOGNAMEPREFIX%-*.log" "%LOGNAMEPREFIX%-*.log.mbtree"

:clean_exit

endlocal

:exit
