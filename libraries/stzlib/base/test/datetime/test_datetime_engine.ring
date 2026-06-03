load "../../string/test/test_stubs.ring"

# Load stz_datetime.dll
? "Loading stz_datetime.dll..."
cDtLib = _stzFindDll("stz_datetime.dll")
if cDtLib != ""
	pDtHandle = LoadLib(cDtLib)
	? "  stz_datetime.dll: loaded"
else
	? "ERROR: stz_datetime.dll not found!"
	return
ok

# Load date/time classes
load "../stzDate.ring"
load "../stzTime.ring"

pr()

? ""
? "=== stzDate & stzTime Engine Migration Tests ==="

# Test 1: Date creation from components
? ""
? "--- Test 1: Date creation ---"
oDate = new stzDate([2026, 5, 19])
? "Year: " + oDate.Year()
? "MonthN: " + oDate.MonthN()
? "DayN: " + oDate.DayN()

# Test 2: Date formatting (uses migrated ring_substr2)
? ""
? "--- Test 2: Date formatting ---"
? "ISO: " + oDate.ToISO8601()
? "European: " + oDate.ToEuropean()
? "Short day: " + oDate.DayShort()
? "Short month: " + oDate.MonthShort()

# Test 3: Date string parsing (uses migrated ring_find)
? ""
? "--- Test 3: Date parsing ---"
oDate2 = new stzDate("2025-12-25")
? "Parsed ISO: Y=" + oDate2.Year() + " M=" + oDate2.MonthN() + " D=" + oDate2.DayN()

oDate3 = new stzDate("15/03/2024")
? "Parsed EU: Y=" + oDate3.Year() + " M=" + oDate3.MonthN() + " D=" + oDate3.DayN()

# Test 4: Compact date (8-digit, uses StzLeft/StzRight)
? ""
? "--- Test 4: Compact date ---"
oDate4 = new stzDate("25122025")
? "Compact: Y=" + oDate4.Year() + " M=" + oDate4.MonthN() + " D=" + oDate4.DayN()

# Test 5: Date with "in N days"
? ""
? "--- Test 5: Relative date ---"
oDate5 = new stzDate("in 7 days")
? "In 7 days from today: " + oDate5.ToISO8601()

# Test 6: Time creation
? ""
? "--- Test 6: Time creation ---"
oTime = new stzTime("14:30:45")
? "Hour: " + oTime.HourN()
? "Minute: " + oTime.MinuteN()
? "Second: " + oTime.SecondN()

# Test 7: Time formatting (uses migrated ring_substr2)
? ""
? "--- Test 7: Time formatting ---"
? "Standard: " + oTime.ToString()
? "Short: " + oTime.ToShort()
? "12h: " + oTime.To12Hour()

# Test 8: Time with AM/PM parsing (uses StzRight/StzLeft)
? ""
? "--- Test 8: AM/PM parsing ---"
oTime2 = new stzTime("2:30:00 PM")
? "PM time: Hour=" + oTime2.HourN() + " Min=" + oTime2.MinuteN()
? "IsPM: " + oTime2.IsPM()

# Test 9: Time with milliseconds (uses ring_find for ".")
? ""
? "--- Test 9: Milliseconds ---"
oTime3 = new stzTime("10:15:30.500")
? "Ms time: " + oTime3.HourN() + ":" + oTime3.MinuteN() + ":" + oTime3.SecondN() + "." + oTime3.MillisecondN()

# Test 10: IsTime validation (uses migrated functions)
? ""
? "--- Test 10: IsTime ---"
? "IsTime('14:30'): " + IsTime("14:30")
? "IsTime('2:30 PM'): " + IsTime("2:30 PM")
? "IsTime('invalid'): " + IsTime("invalid")

? ""
? "=== All stzDate & stzTime migration tests completed ==="

pf()
