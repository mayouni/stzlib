
#ERR Error (E9) : Can't open file ../../string/test/test_stubs.ring

load "../../string/test/test_stubs.ring"

# Load stz_datetime.dll
cDtLib = _stzFindDll("stz_datetime.dll")
if cDtLib != ""
	pDtHandle = LoadLib(cDtLib)
else
	? "ERROR: stz_datetime.dll not found!"
	return
ok

# Set $cEngineDir from the discovered DLL path (strip /zig-out/bin/stz_datetime.dll)
cTemp = cDtLib
nLen = len(cTemp)
cNorm = ""
for i = 1 to nLen
	if cTemp[i] = "\"
		cNorm += "/"
	else
		cNorm += cTemp[i]
	ok
next
nCut = len(cNorm) - len("/zig-out/bin/stz_datetime.dll")
$cEngineDir = left(cNorm, nCut)

# Load bridge wrappers (DLL already loaded, this adds Ring functions)
load "../../../engine/stz_datetime.ring"

pr()

? "=== DateTime Bridge Wrapper Tests ==="

# Test 1: StzDaysInMonth
? ""
? "--- Test 1: StzDaysInMonth ---"
n = StzDaysInMonth(2026, 2)
? "  Feb 2026: " + n + " days"
if n = 28
	? "  PASS"
else
	? "  FAIL (expected 28)"
ok

# Test 2: StzDaysInYear
? ""
? "--- Test 2: StzDaysInYear ---"
n = StzDaysInYear(2024)
? "  2024: " + n + " days"
if n = 366
	? "  PASS"
else
	? "  FAIL (expected 366)"
ok

# Test 3: StzIsLeapYear
? ""
? "--- Test 3: StzIsLeapYear ---"
n1 = StzIsLeapYear(2024)
n2 = StzIsLeapYear(2025)
? "  2024 leap: " + n1 + ", 2025 leap: " + n2
if n1 = 1 and n2 = 0
	? "  PASS"
else
	? "  FAIL"
ok

# Test 4: StzDateToString
? ""
? "--- Test 4: StzDateToString ---"
cDate = StzDateToString(2026, 5, 20)
? "  2026-05-20: '" + cDate + "'"
if len(cDate) > 0
	? "  PASS"
else
	? "  FAIL (empty string)"
ok

# Test 5: StzDateToISO
? ""
? "--- Test 5: StzDateToISO ---"
cISO = StzDateToISO(2026, 5, 20)
? "  ISO: '" + cISO + "'"
if len(cISO) > 0
	? "  PASS"
else
	? "  FAIL"
ok

# Test 6: StzCompareDates
? ""
? "--- Test 6: StzCompareDates ---"
nCmp = StzCompareDates(2026, 1, 1, 2026, 12, 31)
? "  Jan 1 vs Dec 31: " + nCmp
if nCmp < 0
	? "  PASS (earlier date < later date)"
else
	? "  FAIL"
ok

# Test 7: StzTimeToString
? ""
? "--- Test 7: StzTimeToString ---"
cTime = StzTimeToString(14, 30, 0)
? "  14:30:00: '" + cTime + "'"
if len(cTime) > 0
	? "  PASS"
else
	? "  FAIL"
ok

# Test 8: StzTimeToString12h
? ""
? "--- Test 8: StzTimeToString12h ---"
cTime12 = StzTimeToString12h(14, 30, 0)
? "  14:30 in 12h: '" + cTime12 + "'"
if len(cTime12) > 0
	? "  PASS"
else
	? "  FAIL"
ok

# Test 9: StzCompareTimes
? ""
? "--- Test 9: StzCompareTimes ---"
nCmp = StzCompareTimes(8, 0, 0, 17, 0, 0)
? "  08:00 vs 17:00: " + nCmp
if nCmp < 0
	? "  PASS (earlier time < later time)"
else
	? "  FAIL"
ok

# Test 10: StzTimeHour12 and StzTimeIsPm
? ""
? "--- Test 10: StzTimeHour12/IsPm ---"
pH = StzTimeNew(14, 30, 0)
n12 = StzTimeHour12(pH)
nPm = StzTimeIsPm(pH)
StzEngineTimeFree(pH)
? "  14:30 -> hour12=" + n12 + " isPm=" + nPm
if n12 = 2 and nPm = 1
	? "  PASS"
else
	? "  FAIL"
ok

# Test 11: StzDateTimeToISO
? ""
? "--- Test 11: StzDateTimeToISO ---"
cDTISO = StzDateTimeToISO(2026, 5, 20, 14, 30, 0)
? "  ISO: '" + cDTISO + "'"
if len(cDTISO) > 0
	? "  PASS"
else
	? "  FAIL"
ok

# Test 12: StzCompareDateTimes
? ""
? "--- Test 12: StzCompareDateTimes ---"
nCmp = StzCompareDateTimes(2026, 5, 20, 8, 0, 0, 2026, 5, 20, 17, 0, 0)
? "  morning vs evening: " + nCmp
if nCmp < 0
	? "  PASS"
else
	? "  FAIL"
ok

? ""
? "=== All datetime bridge tests completed ==="

pf()
