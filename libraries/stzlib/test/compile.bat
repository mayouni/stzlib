@echo off
"C:\msys64\ucrt64\bin\g++.exe" %1 -o %2 2>&1
echo %ERRORLEVEL%