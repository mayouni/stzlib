@echo off
C:\\msys64\\ucrt64\\bin\\g++.exe -std=c++17 -o temp_cpp temp.cpp > log.txt 2>&1
if %ERRORLEVEL% EQU 0 temp_cpp.exe >> log.txt 2>&1
exit %ERRORLEVEL%