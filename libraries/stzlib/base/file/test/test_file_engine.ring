load "../../string/test/test_stubs.ring"

# Load stz_file.dll
? "Loading stz_file.dll..."
cFileLib = _stzFindDll("stz_file.dll")
if cFileLib != ""
	pFileHandle = LoadLib(cFileLib)
	? "  stz_file.dll: loaded"
else
	? "ERROR: stz_file.dll not found!"
	return
ok

load "../stzfile.ring"

? ""
? "=== stzFileEngine Tests ==="

# Test 1: Path parsing
? ""
? "--- Test 1: Path parsing ---"
? "Extension('.../logo.png'): " + StzPathExtension("assets/images/logo.png")
? "Basename('.../logo.png'): " + StzPathBasename("assets/images/logo.png")
? "Dirname('.../logo.png'): " + StzPathDirname("assets/images/logo.png")

# Test 2: File existence (test_stubs.ring should exist)
? ""
? "--- Test 2: File/Dir existence ---"
? "FileExists('test_stubs.ring'): " + StzFileExists("../../string/test/test_stubs.ring")
? "FileExists('nonexistent.xyz'): " + StzFileExists("nonexistent.xyz")
? "DirExists('.'): " + StzDirExists(".")

# Test 3: File size
? ""
? "--- Test 3: File size ---"
nSize = StzFileSize("../../string/test/test_stubs.ring")
? "FileSize('test_stubs.ring'): " + nSize + " bytes"

# Test 4: Write, read, delete cycle
? ""
? "--- Test 4: Write/Read/Delete ---"
cTmpFile = "_test_engine_tmp.txt"
StzFileWrite(cTmpFile, "Engine test content")
? "Written file exists: " + StzFileExists(cTmpFile)
cContent = StzFileRead(cTmpFile)
? "Read content: " + cContent
StzFileDelete(cTmpFile)
? "After delete exists: " + StzFileExists(cTmpFile)

# Test 5: Append
? ""
? "--- Test 5: Append ---"
cTmpFile2 = "_test_engine_append.txt"
StzFileWrite(cTmpFile2, "Line1")
StzFileAppend(cTmpFile2, " Line2")
? "Appended content: " + StzFileRead(cTmpFile2)
StzFileDelete(cTmpFile2)

# Test 6: Dir operations
? ""
? "--- Test 6: Dir ops ---"
cTmpDir = "_test_engine_dir"
StzDirCreate(cTmpDir)
? "Dir created: " + StzDirExists(cTmpDir)
StzDirDelete(cTmpDir)
? "Dir deleted: " + StzDirExists(cTmpDir)

? ""
? "=== All stzFileEngine tests completed ==="
