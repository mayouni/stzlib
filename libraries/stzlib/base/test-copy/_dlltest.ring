? "Testing DLL load..."
cDll = "D:\Ring126\libraries\stzlib\engine\zig-out\bin\stz_string.dll"
? "File exists: " + fexists(cDll)

# Try LoadLibrary (Windows API name)
# In Ring, LoadLib() is the function
pHandle = NULL
try
    pHandle = LoadLib(cDll)
    ? "LoadLib result: " + pHandle
catch
    ? "LoadLib failed"
done

# Check if cfunctions is available
? "Done"
