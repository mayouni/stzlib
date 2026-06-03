
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

? "=== StzLocale Wrapper Function Tests ==="

# Test 1: StzFormatNumber
? ""
? "--- Test 1: StzFormatNumber ---"
cResult = _StzFormatNumber(1234567.89, 2)
? "  StzFormatNumber(1234567.89, 2): '" + cResult + "'"
if cResult = "1,234,567.89"
	? "  PASS"
else
	? "  FAIL: expected '1,234,567.89'"
ok

# Test 2: Engine MonthName wrappers
? ""
? "--- Test 2: Engine MonthName ---"
cJan = _StzMonthName(1)
cJun = _StzMonthName(6)
cDec = _StzMonthName(12)
? "  Month 1: '" + cJan + "'"
? "  Month 6: '" + cJun + "'"
? "  Month 12: '" + cDec + "'"
if cJan = "January" and cJun = "June" and cDec = "December"
	? "  PASS"
else
	? "  FAIL"
ok

# Test 3: Engine MonthAbbr
? ""
? "--- Test 3: Engine MonthAbbr ---"
cJanA = _StzMonthAbbr(1)
cDecA = _StzMonthAbbr(12)
? "  Month 1 abbr: '" + cJanA + "'"
? "  Month 12 abbr: '" + cDecA + "'"
if cJanA = "Jan" and cDecA = "Dec"
	? "  PASS"
else
	? "  FAIL"
ok

# Test 4: Engine DayName
? ""
? "--- Test 4: Engine DayName ---"
cMon = _StzDayName(1)
cFri = _StzDayName(5)
cSun = _StzDayName(7)
? "  Day 1: '" + cMon + "'"
? "  Day 5: '" + cFri + "'"
? "  Day 7: '" + cSun + "'"
if cMon = "Monday" and cFri = "Friday" and cSun = "Sunday"
	? "  PASS"
else
	? "  FAIL"
ok

# Test 5: Engine DayAbbr
? ""
? "--- Test 5: Engine DayAbbr ---"
cMonA = _StzDayAbbr(1)
cSunA = _StzDayAbbr(7)
? "  Day 1 abbr: '" + cMonA + "'"
? "  Day 7 abbr: '" + cSunA + "'"
if cMonA = "Mon" and cSunA = "Sun"
	? "  PASS"
else
	? "  FAIL"
ok

# Test 6: Engine Titlecase
? ""
? "--- Test 6: Engine Titlecase ---"
cResult = _StzTitlecase("hello world test")
? "  Titlecase('hello world test'): '" + cResult + "'"
if cResult = "Hello World Test"
	? "  PASS"
else
	? "  FAIL"
ok

# Test 7: StzFormatNumber with 0 decimals
? ""
? "--- Test 7: StzFormatNumber (0 decimals) ---"
cResult = _StzFormatNumber(9876543, 0)
? "  StzFormatNumber(9876543, 0): '" + cResult + "'"
if cResult = "9,876,543"
	? "  PASS"
else
	? "  FAIL: expected '9,876,543'"
ok

? ""
? "=== All StzLocale wrapper tests completed ==="

# --- Wrapper functions (mirrors what stzLocale.ring defines) ---

func _StzFormatNumber(nValue, nDecimals)
	return StzEngineLocaleFormatNumber(nValue, nDecimals)

func _StzMonthName(nMonth)
	return StzEngineLocaleMonthName(nMonth)

func _StzMonthAbbr(nMonth)
	return StzEngineLocaleMonthAbbr(nMonth)

func _StzDayName(nDay)
	return StzEngineLocaleDayName(nDay)

func _StzDayAbbr(nDay)
	return StzEngineLocaleDayAbbr(nDay)

func _StzTitlecase(cStr)
	return StzEngineLocaleToTitlecase(cStr)

pf()
