@echo off
D:\\swipl\\bin\\swipl.exe temp.pl > log.txt 2>&1
exit %ERRORLEVEL%