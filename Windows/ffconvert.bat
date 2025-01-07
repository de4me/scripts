@REM DATE 20:23 04.01.2025

@echo off

if [%1] == [reset] goto reset

setlocal

if "%PRESET%" == "" set PRESET=slower
if "%BV%" == "" set BV=3000k
if "%MAXBV%" == "" set MAXBV=5000k
if "%BUFSIZEV%" == "" set BUFSIZEV=6000k
if "%VIDEOH%" == "" set VIDEOH=720
if "%CRF%" == "" set CRF=18
if "%PROFILEV%" == "" set PROFILEV=high
if "%TUNEV%" == "" set TUNEV=film
if "%CODECV%" == "" set CODECV=libx264
if "%CODECA%" == "" set CODECA=copy
if "%SCALEV%" == "" set SCALEV="-2:'min(%VIDEOH%,ih)'"
if "%FILENAMESUFFIX%" == "" set FILENAMESUFFIX="_%VIDEOH%p"

if [%1] == [] goto help
if [%1] == [?] goto help
if [%1] == [v] goto variables
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
echo 	CRF = %CRF% [A lower value generally leads to higher quality and a subjectively sane range is 17-28]
echo 	BV = %BV%
echo 	MAXBV = %MAXBV%
echo 	BUFSIZEV = %BUFSIZEV%
echo 	VIDEOH = %VIDEOH%
echo 	SCALEV = %SCALEV%
echo 	FILTERV = %FILTERV% [crop=in_w:in_h-44]
echo 	INPUTPARAMS = %INPUTPARAMS% [-benchmark -itsscale 1.0 -t 00:10:00]
echo 	OUTPUTPARAMS = %OUTPUTPARAMS% [-dn -x264opts no-deblock -map_metadata -1]
echo 	FILENAMESUFFIX = %FILENAMESUFFIX% [_720p]
echo 	LOGNAMEPREFIX = %LOGNAMEPREFIX% [ffmpeg2pass]
goto clean_exit

:help

echo USE:
echo 	%~n0 [? v]
echo 	%~n0 [2pass] input
echo 	%~n0 [2pass] input output
echo 	%~n0 [2pass] HH:MM:SS input output
echo 	%~n0 [2pass] HH:MM:SS HH:MM:SS input output
echo 	%~n0 reset [540p 720p hq720p 1080p hq1080p]
echo EXAMPLE:
echo 	set PRESET=fast
echo 	%~n0 reset 540p
echo 	%~n0 2pass 00:10:00 00:20:00 input.mkv output_540p.mp4
echo 	%~n0 reset 720p
echo 	%~n0 2pass 00:10:00 00:20:00 input.mkv output_720p.mp4
goto clean_exit

:reset

if [%2] == [] goto setdefault
if [%2] == [540p] goto set540p
if [%2] == [720p] goto set720p
if [%2] == [hq720p] goto setHQ720p
if [%2] == [1080p] goto set1080p
if [%2] == [hq1080p] goto setHQ1080p
setlocal
goto help

:setdefault

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

:set540p

set BV=1800k
set MAXBV=3000k
set BUFSIZEV=3600k
set VIDEOH=540
set SCALEV=
goto exit

:set720p

set BV=
set MAXBV=
set BUFSIZEV=
set VIDEOH=
set SCALEV=
goto exit

:setHQ720p

set BV=4100k
set MAXBV=7000k
set BUFSIZEV=8200k
set VIDEOH=720
set SCALEV=
goto exit

:set1080p

set BV=5000k
set MAXBV=8000k
set BUFSIZEV=10000k
set VIDEOH=1080
set SCALEV=
goto exit

:setHQ1080p

set BV=6000k
set MAXBV=10000k
set BUFSIZEV=12000k
set VIDEOH=1080
set SCALEV=
goto exit

:args_count_1

ffmpeg -hide_banner %INPUTPARAMS% -i %1 %OUTPUTPARAMS% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%,%FILTERV%" "%~n1%FILENAMESUFFIX%.mp4"
goto clean_exit

:args_count_2

ffmpeg -hide_banner %INPUTPARAMS% -i %1 %OUTPUTPARAMS% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%,%FILTERV%" %2
goto clean_exit

:args_count_3

ffmpeg -hide_banner -ss %1 %INPUTPARAMS% -i %2 %OUTPUTPARAMS% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%,%FILTERV%" %3
goto clean_exit

:args_count_4

ffmpeg -hide_banner -ss %1 -to %2 %INPUTPARAMS% -i %3 %OUTPUTPARAMS% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%,%FILTERV%" %4
goto clean_exit

:args_2pass_count_1

ffmpeg -hide_banner -y %INPUTPARAMS% -i %2 %OUTPUTPARAMS% -c:v %CODECV% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -crf %CRF% -vf "scale=%SCALEV%,%FILTERV%" -an -pass 1 -passlogfile "%LOGNAMEPREFIX%" -f null NUL && ^
ffmpeg -hide_banner %INPUTPARAMS% -i %2 %OUTPUTPARAMS% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%,%FILTERV%" -pass 2 -passlogfile "%LOGNAMEPREFIX%" "%~n2%FILENAMESUFFIX%.mp4"
goto clean_2pass

:args_2pass_count_2

ffmpeg -hide_banner -y %INPUTPARAMS% -i %2 %OUTPUTPARAMS% -c:v %CODECV% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -crf %CRF% -vf "scale=%SCALEV%,%FILTERV%" -an -pass 1 -passlogfile "%LOGNAMEPREFIX%" -f null NUL && ^
ffmpeg -hide_banner %INPUTPARAMS% -i %2 %OUTPUTPARAMS% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%,%FILTERV%" -pass 2 -passlogfile "%LOGNAMEPREFIX%" %3
goto clean_2pass

:args_2pass_count_3

ffmpeg -hide_banner -y -ss %2 %INPUTPARAMS% -i %3 %OUTPUTPARAMS% -c:v %CODECV% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -crf %CRF% -vf "scale=%SCALEV%,%FILTERV%" -an -pass 1 -passlogfile "%LOGNAMEPREFIX%" -f null NUL && ^
ffmpeg -hide_banner -ss %2 %INPUTPARAMS% -i %3 %OUTPUTPARAMS% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%,%FILTERV%" -pass 2 -passlogfile "%LOGNAMEPREFIX%" %4
goto clean_2pass

:args_2pass_count_4

ffmpeg -hide_banner -y -ss %2 -to %3 %INPUTPARAMS% -i %4 %OUTPUTPARAMS% -c:v %CODECV% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -crf %CRF% -vf "scale=%SCALEV%,%FILTERV%" -an -pass 1 -passlogfile "%LOGNAMEPREFIX%" -f null NUL && ^
ffmpeg -hide_banner -ss %2 -to %3 %INPUTPARAMS% -i %4 %OUTPUTPARAMS% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%,%FILTERV%" -pass 2 -passlogfile "%LOGNAMEPREFIX%" %5
goto clean_2pass

:clean_2pass

del /Q "%LOGNAMEPREFIX%-*.log" "%LOGNAMEPREFIX%-*.log.mbtree"

:clean_exit

endlocal

:exit


