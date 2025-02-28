@REM 18:00 18.10.2023
@echo off

for /R  %%f in (*.mp4,*.mkv,*.avi,*.m4v,*.mpeg,*.mpg,*.wmv,*.flv,*.vob,*.webm) do (
 	ffconvert %* "%%~f"
	timeout /t 60
)
