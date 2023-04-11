for /R  %%f in (*.avi,*.wmv,*.flv,*.mpeg,*.mpg,*.mkv,*.webm) do (
	ffmpeg -i "%%~f" -c:v libx264 -c:a aac -b:a 128k -map_metadata -1 -crf 22 -preset slow "%%~nf.mp4"
)
