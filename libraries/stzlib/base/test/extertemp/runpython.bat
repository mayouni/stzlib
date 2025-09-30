@echo off
D:/python/python-3.13.7/python.exe extertemp/temp.py > extertemp/log.txt 2>&1
exit %ERRORLEVEL%