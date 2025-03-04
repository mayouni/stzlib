@echo off
C:\\msys64\\ucrt64\\bin\\gcc.exe -o temp\\_2y7faag2 temp\\temp_2y7faag2.c > temp\\log_2y7faag2.txt 2>&1
if %ERRORLEVEL% EQU 0 temp\\_2y7faag2 >> temp\\log_2y7faag2.txt 2>&1
exit %ERRORLEVEL%