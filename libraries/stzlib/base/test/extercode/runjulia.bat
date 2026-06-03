@echo off
d:/julia/julia-1.11.7/bin/julia.exe  temp.jl > log.txt 2>&1
exit %ERRORLEVEL%