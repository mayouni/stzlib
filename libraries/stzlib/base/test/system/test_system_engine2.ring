

load "../string/test_stubs.ring"
# Load stz_system.dll
? "Loading stz_system.dll..."
cSysLib = _stzFindDll("stz_system.dll")
if cSysLib != ""
	pSysHandle = LoadLib(cSysLib)
	? "  stz_system.dll: loaded"
else
	? "ERROR: stz_system.dll not found!"
	return
ok

? ""
? "=== stz_system Engine Tests ==="

# Test 1: Platform detection
? ""
? "--- Test 1: Platform detection ---"
? "  IsWindows: " + StzEngineSystemIsWindows()
? "  IsLinux: " + StzEngineSystemIsLinux()
? "  IsMacos: " + StzEngineSystemIsMacos()

# Test 2: Environment variable
? ""
? "--- Test 2: Environment variable ---"
cPath = StzEngineSystemEnv("PATH")
if StzLen(cPath) > 0
	? "  PATH length: " + StzLen(cPath) + " chars"
	? "  PATH starts with: " + StzLeft(cPath, 40) + "..."
else
	? "  PATH: (empty)"
ok

cUser = StzEngineSystemEnv("USERNAME")
? "  USERNAME: " + cUser

# Test 3: Exec (simple echo)
? ""
? "--- Test 3: Exec ---"
if StzEngineSystemIsWindows() = 1
	nResult = StzEngineSystemExec("echo hello > NUL")
	? "  exec('echo hello > NUL'): " + nResult
else
	nResult = StzEngineSystemExec("echo hello > /dev/null")
	? "  exec('echo hello > /dev/null'): " + nResult
ok

# Test 4: Run (capture output)
? ""
? "--- Test 4: Run ---"
if StzEngineSystemIsWindows() = 1
	cOutput = StzEngineSystemRun("echo hello-from-engine")
	? "  run('echo hello-from-engine'): " + cOutput
else
	cOutput = StzEngineSystemRun("echo hello-from-engine")
	? "  run('echo hello-from-engine'): " + cOutput
ok

? ""
? "=== All stz_system engine tests completed ==="
