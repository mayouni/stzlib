@echo off
C:\\msys64\\ucrt64\\bin\\gcc.exe -o temp\\_wdsq91x0 temp\\temp_wdsq91x0.c > temp\\log_wdsq91x0.txt 2>&1
if %ERRORLEVEL% EQU 0 temp\\_wdsq91x0 >> temp\\log_wdsq91x0.txt 2>&1
exit %ERRORLEVEL%