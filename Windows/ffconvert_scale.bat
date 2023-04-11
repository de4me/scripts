@REM DATE 21:32 02.02.2023

@echo off

if "%PRESET%" == "" set PRESET=slower
if "%BV%" == "" set BV=3000k
if "%MAXBV%" == "" set MAXBV=5000k
if "%BUFSIZEV%" == "" set BUFSIZEV=2000k
if "%SCALEV%" == "" set SCALEV=-2:'min(720,ih)'
if "%CRF%" == "" set CRF=18
if "%PROFILEV%" == "" set PROFILEV=high
if "%TUNEV%" == "" set TUNEV=film
if "%CODECV%" == "" set CODECV=libx264
if "%CODECA%" == "" set CODECA=copy

if [%1] == [] goto help
if [%1] == [?] goto help
if [%1] == [reset] goto reset
if [%1] == [2pass] goto twopass
if [%2] == [] goto args_count_1
if [%3] == [] goto args_count_2
if [%4] == [] goto args_count_3
if [%5] == [] goto args_count_4
goto help

:twopass

if [%2] == [] goto help
if [%3] == [] goto args_2pass_count_1
if [%4] == [] goto args_2pass_count_2
if [%5] == [] goto args_2pass_count_3
if [%6] == [] goto args_2pass_count_4
goto help

:reset

if [%2] == [] goto setdefault
if [%2] == [540p] goto set540p
if [%2] == [720p] goto set720p
if [%2] == [hq720p] goto setHQ720p
if [%2] == [1080p] goto set1080p
goto help

:help

echo USE:
echo 	%~nx0 [2pass] input
echo 	%~nx0 [2pass] input output
echo 	%~nx0 [2pass] HH:MM:SS input output
echo 	%~nx0 [2pass] HH:MM:SS HH:MM:SS input output
echo 	%~nx0 reset [540p || 720p || hq720p || 1080p]
echo EXAMPLE:
echo 	set PRESET=fast
echo 	%~nx0 reset 540p
echo 	%~nx0 2pass 00:10:00 00:20:00 input.mkv output_540p.mp4
echo 	%~nx0 reset 720p
echo 	%~nx0 2pass 00:10:00 00:20:00 input.mkv output_720p.mp4
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
echo 	SCALEV = %SCALEV%
echo 	INPUTPARAMS = %INPUTPARAMS% [-benchmark -itsscale 1.0 -t 00:10:00]
echo 	OUTPUTPARAMS = %OUTPUTPARAMS% [-dn]
goto exit

:setdefault

set PRESET=
set BV=
set MAXBV=
set BUFSIZEV=
set SCALEV=
set CRF=
set PROFILEV=
set TUNEV=
set CODECV=
set CODECA=
set INPUTPARAMS=
set OUTPUTPARAMS=
goto exit

:set720p

set BV=
set MAXBV=
set SCALEV=
goto exit

:set540p

set BV=1800k
set MAXBV=3000k
set SCALEV=-1:'min(540,ih)'
goto exit

:setHQ720p

set BV=4100k
set MAXBV=6700k
set SCALEV=
goto exit

:set1080p

set BV=6000k
set MAXBV=10000k
set SCALEV=-1:'min(1080,ih)'
goto exit

:args_count_1

ffmpeg -hide_banner %INPUTPARAMS% -i %1 %OUTPUTPARAMS% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%" "%~n1.mp4"
goto exit

:args_count_2

ffmpeg -hide_banner %INPUTPARAMS% -i %1 %OUTPUTPARAMS% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%" %2
goto exit

:args_count_3

ffmpeg -hide_banner -ss %1 %INPUTPARAMS% -i %2 %OUTPUTPARAMS% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%" %3
goto exit

:args_count_4

ffmpeg -hide_banner -ss %1 -to %2 %INPUTPARAMS% -i %3 %OUTPUTPARAMS% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%" %4
goto exit

:args_2pass_count_1

ffmpeg -hide_banner -y %INPUTPARAMS% -i %2 %OUTPUTPARAMS% -c:v %CODECV% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -crf %CRF% -vf "scale=%SCALEV%" -an -pass 1 -f null NUL && ^
ffmpeg -hide_banner %INPUTPARAMS% -i %2 %OUTPUTPARAMS% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%" -pass 2 "%~n2.mp4"
goto exit

:args_2pass_count_2

ffmpeg -hide_banner -y %INPUTPARAMS% -i %2 %OUTPUTPARAMS% -c:v %CODECV% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -crf %CRF% -vf "scale=%SCALEV%" -an -pass 1 -f null NUL && ^
ffmpeg -hide_banner %INPUTPARAMS% -i %2 %OUTPUTPARAMS% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%" -pass 2 %3
goto exit

:args_2pass_count_3

ffmpeg -hide_banner -y -ss %2 %INPUTPARAMS% -i %3 %OUTPUTPARAMS% -c:v %CODECV% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -crf %CRF% -vf "scale=%SCALEV%" -an -pass 1 -f null NUL && ^
ffmpeg -hide_banner -ss %2 %INPUTPARAMS% -i %3 %OUTPUTPARAMS% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%" -pass 2 %4
goto exit

:args_2pass_count_4

ffmpeg -hide_banner -y -ss %2 -to %3 %INPUTPARAMS% -i %4 %OUTPUTPARAMS% -c:v %CODECV% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -crf %CRF% -vf "scale=%SCALEV%" -an -pass 1 -f null NUL && ^
ffmpeg -hide_banner -ss %2 -to %3 %INPUTPARAMS% -i %4 %OUTPUTPARAMS% -c:v %CODECV% -c:a %CODECA% -preset %PRESET% -profile:v %PROFILEV% -tune %TUNEV% -b:v %BV% -maxrate %MAXBV% -bufsize %BUFSIZEV% -movflags +faststart -crf %CRF% -vf "scale=%SCALEV%" -pass 2 %5
goto exit

:exit
