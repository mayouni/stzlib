
#ERR Error (E9) : Can't open file ../../string/test/test_stubs.ring

load "../../string/test/test_stubs.ring"

pr()

# Load stz_locale.dll
cLocaleLib = _stzFindDll("stz_locale.dll")
if cLocaleLib != ""
	pLocaleHandle = LoadLib(cLocaleLib)
else
	? "ERROR: stz_locale.dll not found!"
	return
ok

? "=== StzLocale Engine Tests ==="

# Test 1: AM/PM text
? ""
? "--- Test 1: AM/PM Text ---"
cAm = StzEngineLocaleAmText()
cPm = StzEngineLocalePmText()
? "  AM text: '" + cAm + "'"
? "  PM text: '" + cPm + "'"
if cAm != "" and cPm != ""
	? "  PASS"
else
	? "  FAIL: AM or PM text is empty"
ok

# Test 2: ToUpper
? ""
? "--- Test 2: ToUpper ---"
cResult = StzEngineLocaleToUpper("hello world")
? "  ToUpper('hello world'): '" + cResult + "'"
if cResult = "HELLO WORLD"
	? "  PASS"
else
	? "  FAIL: expected 'HELLO WORLD'"
ok

# Test 3: ToLower
? ""
? "--- Test 3: ToLower ---"
cResult = StzEngineLocaleToLower("HELLO WORLD")
? "  ToLower('HELLO WORLD'): '" + cResult + "'"
if cResult = "hello world"
	? "  PASS"
else
	? "  FAIL: expected 'hello world'"
ok

# Test 4: ToTitlecase
? ""
? "--- Test 4: ToTitlecase ---"
cResult = StzEngineLocaleToTitlecase("hello world")
? "  ToTitlecase('hello world'): '" + cResult + "'"
if cResult = "Hello World"
	? "  PASS"
else
	? "  FAIL: expected 'Hello World'"
ok

# Test 5: FormatNumber
? ""
? "--- Test 5: FormatNumber ---"
cResult = StzEngineLocaleFormatNumber(1234567.89, 2)
? "  FormatNumber(1234567.89, 2): '" + cResult + "'"
if cResult != ""
	? "  PASS (got a formatted result)"
else
	? "  FAIL: empty result"
ok

# Test 6: MonthName
? ""
? "--- Test 6: MonthName ---"
cJan = StzEngineLocaleMonthName(1)
cDec = StzEngineLocaleMonthName(12)
? "  MonthName(1): '" + cJan + "'"
? "  MonthName(12): '" + cDec + "'"
if cJan != "" and cDec != ""
	? "  PASS"
else
	? "  FAIL: month name is empty"
ok

# Test 7: MonthAbbr
? ""
? "--- Test 7: MonthAbbr ---"
cJanAbbr = StzEngineLocaleMonthAbbr(1)
cDecAbbr = StzEngineLocaleMonthAbbr(12)
? "  MonthAbbr(1): '" + cJanAbbr + "'"
? "  MonthAbbr(12): '" + cDecAbbr + "'"
if cJanAbbr != "" and cDecAbbr != ""
	? "  PASS"
else
	? "  FAIL: month abbreviation is empty"
ok

# Test 8: DayName
? ""
? "--- Test 8: DayName ---"
cMon = StzEngineLocaleDayName(1)
cSun = StzEngineLocaleDayName(7)
? "  DayName(1): '" + cMon + "'"
? "  DayName(7): '" + cSun + "'"
if cMon != "" and cSun != ""
	? "  PASS"
else
	? "  FAIL: day name is empty"
ok

# Test 9: DayAbbr
? ""
? "--- Test 9: DayAbbr ---"
cMonAbbr = StzEngineLocaleDayAbbr(1)
cSunAbbr = StzEngineLocaleDayAbbr(7)
? "  DayAbbr(1): '" + cMonAbbr + "'"
? "  DayAbbr(7): '" + cSunAbbr + "'"
if cMonAbbr != "" and cSunAbbr != ""
	? "  PASS"
else
	? "  FAIL: day abbreviation is empty"
ok

# Test 10: Unicode case conversion (non-ASCII)
? ""
? "--- Test 10: Unicode case ---"
cUpper = StzEngineLocaleToUpper("cafe")
? "  ToUpper('cafe'): '" + cUpper + "'"
cLower = StzEngineLocaleToLower("CAFE")
? "  ToLower('CAFE'): '" + cLower + "'"
if cUpper = "CAFE" and cLower = "cafe"
	? "  PASS"
else
	? "  FAIL"
ok

? ""
? "=== All locale engine tests completed ==="

pf()
