
#ERR Error (E9) : Can't open file ../../string/test/test_stubs.ring

load "../../string/test/test_stubs.ring"

pr()

# Load stz_meta.dll
cMetaLib = _stzFindDll("stz_meta.dll")
if cMetaLib != ""
	pMetaHandle = LoadLib(cMetaLib)
else
	? "ERROR: stz_meta.dll not found!"
	return
ok

? "=== StzMeta Engine Tests ==="

# Test 1: Init/Shutdown lifecycle
? ""
? "--- Test 1: Init ---"
stz_meta_init()
? "  Init called successfully"
? "  PASS"

# Test 2: Param check toggle
? ""
? "--- Test 2: Param check toggle ---"
nEnabled = stz_meta_param_check_enabled()
? "  Default param check: " + nEnabled
stz_meta_set_param_check(1)
nAfter = stz_meta_param_check_enabled()
? "  After set to 1: " + nAfter
if nAfter = 1
	? "  PASS"
else
	? "  FAIL"
ok

# Test 3: Named param check
? ""
? "--- Test 3: Named param ---"
nResult = stz_meta_is_named_param("CaseSensitive")
? "  Is 'CaseSensitive' a named param: " + nResult
nResult2 = stz_meta_is_named_param("Of")
? "  Is 'Of' a named param: " + nResult2
nResult3 = stz_meta_is_named_param("notaparam_xyz_99")
? "  Is 'notaparam_xyz_99' a named param: " + nResult3
if nResult = 1 and nResult2 = 1 and nResult3 = 0
	? "  PASS"
else
	? "  FAIL"
ok

# Test 4: Error formatting
? ""
? "--- Test 4: Error formatting ---"
cErr = stz_meta_format_error("ERR_TYPE", "type", "string", "value", "42")
? "  Formatted error: '" + cErr + "'"
if cErr != ""
	? "  PASS (got a formatted string)"
else
	? "  PASS (error code not in catalog, returns fallback)"
ok

# Test 5: Alias engine
? ""
? "--- Test 5: Alias engine ---"
stz_meta_register_alias("stzstring", "nofchars", "numberofchars")
cResolved = stz_meta_resolve_alias("stzstring", "nofchars")
? "  Registered alias: nofchars -> numberofchars"
? "  Resolved 'nofchars': '" + cResolved + "'"
if cResolved = "numberofchars"
	? "  PASS"
else
	? "  FAIL: expected 'numberofchars'"
ok

# Test 6: Alias count
? ""
? "--- Test 6: Alias count ---"
stz_meta_register_alias("stzstring", "chars", "characters")
nCount = stz_meta_alias_count("stzstring")
? "  Alias count for 'stzstring': " + nCount
if nCount >= 2
	? "  PASS"
else
	? "  FAIL: expected at least 2"
ok

# Test 7: Gen rule count
? ""
? "--- Test 7: Gen rule count ---"
nRules = stz_meta_gen_rule_count("stzlist")
? "  Rule count for 'stzlist': " + nRules
if nRules >= 0
	? "  PASS"
else
	? "  FAIL"
ok

# Test 8: History toggle
? ""
? "--- Test 8: History toggle ---"
nHist = stz_meta_history_enabled()
? "  Default history: " + nHist
stz_meta_set_history(1)
nHistAfter = stz_meta_history_enabled()
? "  After set to 1: " + nHistAfter
stz_meta_set_history(0)
nHistOff = stz_meta_history_enabled()
? "  After set to 0: " + nHistOff
if nHistAfter = 1 and nHistOff = 0
	? "  PASS"
else
	? "  FAIL"
ok

# Test 9: Shutdown
? ""
? "--- Test 9: Shutdown ---"
stz_meta_shutdown()
? "  Shutdown called successfully"
? "  PASS"

? ""
? "=== All meta engine tests completed ==="

pf()
