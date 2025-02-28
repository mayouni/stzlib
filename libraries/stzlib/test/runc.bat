@echo off
C:\\msys64\\ucrt64\\bin\\gcc.exe temp.c > log.txt 2>&1
exit %ERRORLEVEL%