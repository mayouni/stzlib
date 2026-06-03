@echo off
d:/nodejs/nodejs-22.20/node.exe  temp.njs > log.txt 2>&1
exit %ERRORLEVEL%