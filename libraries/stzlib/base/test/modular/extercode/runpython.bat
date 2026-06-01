@echo off
d:/python/python-3.13.7/python.exe  temp.py > log.txt 2>&1
exit %ERRORLEVEL%