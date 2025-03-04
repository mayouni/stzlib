@echo off
C:\\msys64\\ucrt64\\bin\\gcc.exe -o temp\\_6xwb98j1 temp\\temp_6xwb98j1.c > temp\\log_6xwb98j1.txt 2>&1
if %ERRORLEVEL% EQU 0 temp\\_6xwb98j1 >> temp\\log_6xwb98j1.txt 2>&1
exit %ERRORLEVEL%