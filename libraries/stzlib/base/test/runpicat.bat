@echo off
D:\\Picat\\Picat-3.9\\picat.exe temp.pi > log.txt 2>&1
exit %ERRORLEVEL%