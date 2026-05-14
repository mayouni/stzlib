? "Ring version: " + version()
load "stdlibcore.ring"
? "loaded stdlib"
cDll = "D:\Ring126\libraries\stzlib\engine\zig-out\bin\stz_string.dll"
pHandle = LoadLib(cDll)
? "loaded dll"
? type(pHandle)
cResult = CallCFunc(pHandle, "stz_engine_version", "i", "")
? "version: " + cResult
