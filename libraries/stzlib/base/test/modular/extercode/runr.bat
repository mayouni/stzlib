@echo off
d:/r/r-4.5.1/bin/rscript.exe  temp.R > log.txt 2>&1
exit %ERRORLEVEL%