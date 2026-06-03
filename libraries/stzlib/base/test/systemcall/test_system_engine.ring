
#ERR Error (E9) : Can't open file ../../string/test/test_stubs.ring

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

# stzSystemCall uses stzString for parsing
load "../../string/stzString.ring"

? ""
? "=== stzSystemCall Engine Tests ==="

# Test 1: OS detection
? ""
? "--- Test 1: OS detection ---"
? "IsWindows: " + StzEngineSystemIsWindows()
? "IsLinux: " + StzEngineSystemIsLinux()
? "IsMacos: " + StzEngineSystemIsMacos()

# Test 2: Environment variable
? ""
? "--- Test 2: Environment variable ---"
cPath = StzEngineSystemEnv("PATH")
if len(cPath) > 0
	? "PATH exists: 1 (length=" + len(cPath) + ")"
else
	? "PATH exists: 0"
ok

cEmpty = StzEngineSystemEnv("_ZZZ_NONEXISTENT_VAR_ZZZ_")
? "Nonexistent var is empty: " + (cEmpty = "")

# Test 3: Engine Run (capture stdout, no console)
? ""
? "--- Test 3: Engine Run ---"
cOut = StzEngineSystemRun("echo hello engine")
cOut = trim(cOut)
? "echo output: [" + cOut + "]"
? "Contains 'hello engine': " + (StzFind(cOut, "hello engine") > 0)

# Test 4: Engine Exec (exit code only)
? ""
? "--- Test 4: Engine Exec ---"
nCode = StzEngineSystemExec("echo silent test")
? "echo exit code: " + nCode

# Test 5: stzSystemCall class (engine-backed)
? ""
? "--- Test 5: stzSystemCall class ---"
load "../../system/stzSystemCall.ring"
oSys = new stzSystemCall("echo class test")
oSys.HideConsole()
oSys.Run()
? "Output: [" + trim(oSys.Output()) + "]"
? "Succeeded: " + oSys.Succeeded()

# Test 6: stzsystem() shortcut
? ""
? "--- Test 6: stzsystem() shortcut ---"
cResult = stzsystem("echo shortcut works")
? "stzsystem result: [" + trim(cResult) + "]"

# Test 7: Silent execution
? ""
? "--- Test 7: Silent execution ---"
stzsystemSilent("echo should not capture")
? "Silent ran without error: 1"

# Test 8: OS detection via class
? ""
? "--- Test 8: OS detection via class ---"
oSys2 = new stzSystemCall("echo os-test")
? "EngineIsWindows: " + oSys2.EngineIsWindows()

? ""
? "=== All stzSystemCall engine tests completed ==="
