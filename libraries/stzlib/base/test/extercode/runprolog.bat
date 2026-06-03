@echo off
d:/prolog/swipl-9.9.9/bin/swipl.exe -q -g main -t halt temp.pl > log.txt 2>&1
exit %ERRORLEVEL%