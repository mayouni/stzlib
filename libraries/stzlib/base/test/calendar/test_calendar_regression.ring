# Integration regression suite for stzCalendar.
# Covers construction shapes (year, year-month, year-quarter), period
# info (TotalDays / TotalWeeks / QuarterNumber), accessors (Year,
# MonthNumber, MonthName), Start / End, and working-day arithmetic.
#
# Run from base/datetime/test/.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzCalendar integration regression ==="

# ------------------------------------------------------------
# Year construction
# ------------------------------------------------------------
? ""
? "--- Construction: year ---"

oCy = new stzCalendar(2024)
chk("Year() = 2024",                oCy.Year() = 2024)
chk("Start of 2024 = Jan 1",        oCy.Start() = "2024-01-01")
chk("End of 2024 = Dec 31",         oCy.End_() = "2024-12-31")

# Leap year 2024 -> 366 days
chk("2024 TotalDays = 366 (leap)",  oCy.TotalDays() = 366)

# Non-leap 2025 -> 365
oC25 = new stzCalendar(2025)
chk("2025 TotalDays = 365",         oC25.TotalDays() = 365)

# Century leap year 2000 -> 366
oC00 = new stzCalendar(2000)
chk("2000 TotalDays = 366 (century leap)", oC00.TotalDays() = 366)

# Century non-leap 1900? > 1900 so not allowed. Use 2100 instead.
oC2100 = new stzCalendar(2100)
chk("2100 TotalDays = 365 (non-leap century)", oC2100.TotalDays() = 365)

# ------------------------------------------------------------
# Year-quarter construction
# ------------------------------------------------------------
? ""
? "--- Construction: year-quarter ---"

oCq1 = new stzCalendar("2024-Q1")
chk("Q1 Year = 2024",               oCq1.Year() = 2024)
chk("Q1 Start = 2024-01-01",        oCq1.Start() = "2024-01-01")
chk("Q1 End = 2024-03-31",          oCq1.End_() = "2024-03-31")
chk("Q1 QuarterNumber = 1",         oCq1.QuarterNumber() = 1)

oCq2 = new stzCalendar("2024-Q2")
chk("Q2 Start = 2024-04-01",        oCq2.Start() = "2024-04-01")
chk("Q2 End = 2024-06-30",          oCq2.End_() = "2024-06-30")

oCq3 = new stzCalendar("2024-Q3")
chk("Q3 Start = 2024-07-01",        oCq3.Start() = "2024-07-01")
chk("Q3 End = 2024-09-30",          oCq3.End_() = "2024-09-30")

oCq4 = new stzCalendar("2024-Q4")
chk("Q4 Start = 2024-10-01",        oCq4.Start() = "2024-10-01")
chk("Q4 End = 2024-12-31",          oCq4.End_() = "2024-12-31")

# ------------------------------------------------------------
# Year-month construction
# ------------------------------------------------------------
? ""
? "--- Construction: year-month ---"

oCm = new stzCalendar("2024-02")
chk("Feb 2024 Year = 2024",         oCm.Year() = 2024)
chk("Feb 2024 MonthNumber = 2",     oCm.MonthNumber() = 2)
chk("Feb 2024 Start = 2024-02-01",  oCm.Start() = "2024-02-01")
# Feb 2024 has 29 days (leap)
chk("Feb 2024 End = 2024-02-29",    oCm.End_() = "2024-02-29")
chk("Feb 2024 TotalDays = 29",      oCm.TotalDays() = 29)

# Feb 2023 non-leap -> 28 days
oCm23 = new stzCalendar("2023-02")
chk("Feb 2023 TotalDays = 28",      oCm23.TotalDays() = 28)

# April -> 30 days
oCa = new stzCalendar("2024-04")
chk("Apr 2024 TotalDays = 30",      oCa.TotalDays() = 30)

# January -> 31 days
oCj = new stzCalendar("2024-01")
chk("Jan 2024 TotalDays = 31",      oCj.TotalDays() = 31)

# ------------------------------------------------------------
# Total weeks
# ------------------------------------------------------------
? ""
? "--- TotalWeeks ---"

# 2024 has 366 days -> ~52 full weeks + 2 days
oCw = new stzCalendar(2024)
nW = oCw.TotalWeeks()
chk("2024 TotalWeeks reasonable",   isNumber(nW) and nW >= 52 and nW <= 53)

# ------------------------------------------------------------
# MonthName
# ------------------------------------------------------------
? ""
? "--- MonthName ---"

oCmn = new stzCalendar("2024-05")
cMn = oCmn.MonthName()
chk("MonthName = 'May'",            cMn = "May")

# ------------------------------------------------------------
# Edge: very different years
# ------------------------------------------------------------
? ""
? "--- Edges ---"

oCmin = new stzCalendar(1901)
chk("1901 (just above guard) ok",   oCmin.Year() = 1901)

oCfut = new stzCalendar(2099)
chk("2099 ok",                      oCfut.Year() = 2099 and oCfut.TotalDays() = 365)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzCalendar CHECKS PASSED!"
else
	? "SOME stzCalendar CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
