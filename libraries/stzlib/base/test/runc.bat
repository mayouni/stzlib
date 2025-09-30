@echo off
D:/mingw64/bin/gcc.exe -o temp_c temp.c > log.txt 2>&1
if %ERRORLEVEL% EQU 0 temp_c.exe >> log.txt 2>&1
exit %ERRORLEVEL%