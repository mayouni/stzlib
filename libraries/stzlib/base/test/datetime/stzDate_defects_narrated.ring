load "../../stzBase.ring"
load "../_narrated.ring"

# stzDate, the two human-readable renderings the defect register listed: ToHuman and ToRelative.
#
# THE RULE UNDER TEST. Every form that starts with a word is lower case (today, tomorrow, yesterday,
# in 3 days), a form that starts with a number stays as it is (3 days ago, 2 weeks ago), and only the
# long form of ToHuman is capitalised because it starts with a day name (Friday, March 8th, 2024).
# The register said the future form began with a capital; the code had already been brought to lower
# case (the case rule above is the one the block, the tests and the narration all use), and what the
# register still carried was a stale warning in the block. ToRelative's own defect was 14 days read as
# 1 week while 15 to 20 days read as 2 weeks and 21 days as 3 (a bucket 7 days wide, then one 6 wide).
#
# THE CLOCK. Both methods are relative to today. StzFreezeClock pins it, so the main scenarios freeze
# the clock at six chosen days (a leap day, the last day of a year, the first of March, the epoch ...)
# and never read the real date. The last scenarios leave the clock live and compute every expectation
# from the real date() of the machine and from offsets alone, so the guard holds on every day of the
# year. Every expectation below is a literal or comes from an independent rule written at the end of
# this file (days-from-civil, weekday, ordinal suffix, weeks by integer division), never from stzDate.
# String equality in Ring ignores case, so every text is compared with strcmp. Run from this folder:
#   ring stzDate_defects_narrated.ring

$zdMonths = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ]
$zdWeekdays = [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ]

Scenario("Case: every form that starts with a word is lower case, in the future as in the past")
	StzFreezeClock("2026-10-24")
	d = new stzDate("")
	d.AddDays(3)
	ThenExact("ToHuman writes the future in lower case", d.ToHuman(), "in 3 days")
	ThenExact("ToRelative writes the future in lower case", d.ToRelative(), "in 3 days")
	Then("the capitalised future form is not what ToHuman answers", strcmp(d.ToHuman(), "In 3 days") != 0, 1)
	Then("nor what ToRelative answers", strcmp(d.ToRelative(), "In 3 days") != 0, 1)
	d = new stzDate("")
	d.SubtractDays(3)
	ThenExact("the past form starts with its number", d.ToHuman(), "3 days ago")
	ThenExact("in ToRelative too", d.ToRelative(), "3 days ago")
	d = new stzDate("")
	ThenExact("today is lower case", d.ToHuman(), "today")
	ThenExact("today is lower case in ToRelative", d.ToRelative(), "today")
	Then("Today with a capital is not the answer", strcmp(d.ToHuman(), "Today") != 0, 1)
	d.AddDays(1)
	ThenExact("tomorrow is lower case", d.ToHuman(), "tomorrow")
	ThenExact("tomorrow is lower case in ToRelative", d.ToRelative(), "tomorrow")
	d = new stzDate("")
	d.SubtractDays(1)
	ThenExact("yesterday is lower case", d.ToHuman(), "yesterday")
	ThenExact("yesterday is lower case in ToRelative", d.ToRelative(), "yesterday")
	Then("Yesterday with a capital is not the answer", strcmp(d.ToRelative(), "Yesterday") != 0, 1)
	Then("the harness itself tells In from in (strcmp, not =)", strcmp("In 3 days", "in 3 days") != 0, 1)
EndScenario()

Scenario("ToHuman: 2 to 7 days are counted, the singular never shows, 8 days is a long date")
	StzFreezeClock("2026-10-24")
	ThenExact("2 days ahead", zdHumanAt(2), "in 2 days")
	ThenExact("7 days ahead is still a count", zdHumanAt(7), "in 7 days")
	ThenExact("8 days ahead is the long form (a Sunday, 1 November 2026)", zdHumanAt(8), "Sunday, November 1st, 2026")
	Then("8 days ahead is not a count", strcmp(zdHumanAt(8), "in 8 days") != 0, 1)
	ThenExact("7 days back is still a count", zdHumanAt(-7), "7 days ago")
	ThenExact("8 days back is the long form (a Friday, 16 October 2026)", zdHumanAt(-8), "Friday, October 16th, 2026")
	Then("8 days back is not a count", strcmp(zdHumanAt(-8), "8 days ago") != 0, 1)
	ThenExact("1 day ahead is tomorrow, not 1 day", zdHumanAt(1), "tomorrow")
	ThenExact("1 day back is yesterday, not 1 day ago", zdHumanAt(-1), "yesterday")
	Then("no count is ever written 1 days", zdHasText("1 days"), 0)
	Then("nor 1 day", zdHasText("1 day"), 0)
EndScenario()

Scenario("ToRelative: days to 7, then whole weeks rounded down to 30 days, then the plain date")
	StzFreezeClock("2026-10-24")
	ThenExact("7 days ahead is a count", zdRelAt(7), "in 7 days")
	ThenExact("8 days ahead is 1 week, singular", zdRelAt(8), "in 1 week")
	ThenExact("13 days ahead is still 1 week", zdRelAt(13), "in 1 week")
	ThenExact("14 days ahead is 2 weeks, not 1", zdRelAt(14), "in 2 weeks")
	Then("14 days ahead is not 1 week", strcmp(zdRelAt(14), "in 1 week") != 0, 1)
	ThenExact("20 days ahead is 2 weeks", zdRelAt(20), "in 2 weeks")
	ThenExact("21 days ahead is 3 weeks", zdRelAt(21), "in 3 weeks")
	ThenExact("27 days ahead is 3 weeks", zdRelAt(27), "in 3 weeks")
	ThenExact("28 days ahead is 4 weeks", zdRelAt(28), "in 4 weeks")
	ThenExact("30 days ahead is the last week form", zdRelAt(30), "in 4 weeks")
	ThenExact("31 days ahead is the plain date (24 November 2026)", zdRelAt(31), "24/11/2026")
	Then("31 days ahead is not a week count", strcmp(zdRelAt(31), "in 4 weeks") != 0, 1)
	ThenExact("7 days back is a count", zdRelAt(-7), "7 days ago")
	ThenExact("8 days back is 1 week ago, singular", zdRelAt(-8), "1 week ago")
	ThenExact("13 days back is still 1 week ago", zdRelAt(-13), "1 week ago")
	ThenExact("14 days back is 2 weeks ago", zdRelAt(-14), "2 weeks ago")
	ThenExact("21 days back is 3 weeks ago", zdRelAt(-21), "3 weeks ago")
	ThenExact("30 days back is 4 weeks ago", zdRelAt(-30), "4 weeks ago")
	ThenExact("31 days back is the plain date (23 September 2026)", zdRelAt(-31), "23/09/2026")
	Then("the singular only shows for a week, never 1 weeks", zdHasText("1 weeks"), 0)
	Then("nor 1 days", zdHasText("1 days"), 0)
	Then("a week count is a week count: 10 days is not in 10 days", strcmp(zdRelAt(10), "in 10 days") != 0, 1)
EndScenario()

Scenario("ToHuman and ToRelative agree on the days both write as words or counts")
	StzFreezeClock("2026-10-24")
	nSame = 0
	for n = -7 to 7
		if strcmp(zdHumanAt(n), zdRelAt(n)) = 0
			nSame++
		ok
	next
	Then("the 15 days from 7 back to 7 ahead read the same in both", nSame, 15)
	Then("8 days ahead is where they part: a long date against a week", strcmp(zdHumanAt(8), zdRelAt(8)) != 0, 1)
EndScenario()

Scenario("The long date: ordinal suffixes, day names, a far past and a far future")
	StzFreezeClock("2026-10-24")
	ThenExact("the 1st (a Sunday)", zdHumanOf("2026-11-01"), "Sunday, November 1st, 2026")
	ThenExact("the 2nd", zdHumanOf("2026-11-02"), "Monday, November 2nd, 2026")
	ThenExact("the 3rd", zdHumanOf("2026-11-03"), "Tuesday, November 3rd, 2026")
	ThenExact("the 4th", zdHumanOf("2026-11-04"), "Wednesday, November 4th, 2026")
	ThenExact("the 11th is not 11st", zdHumanOf("2026-11-11"), "Wednesday, November 11th, 2026")
	ThenExact("the 12th is not 12nd", zdHumanOf("2026-11-12"), "Thursday, November 12th, 2026")
	ThenExact("the 13th is not 13rd", zdHumanOf("2026-11-13"), "Friday, November 13th, 2026")
	ThenExact("the 21st", zdHumanOf("2026-11-21"), "Saturday, November 21st, 2026")
	ThenExact("the 22nd", zdHumanOf("2026-11-22"), "Sunday, November 22nd, 2026")
	ThenExact("the 23rd", zdHumanOf("2026-11-23"), "Monday, November 23rd, 2026")
	ThenExact("the 31st", zdHumanOf("2026-12-31"), "Thursday, December 31st, 2026")
	Then("the 11th does not end in st", strcmp(zdHumanOf("2026-11-11"), "Wednesday, November 11st, 2026") != 0, 1)
	ThenExact("the epoch, 56 years back", zdHumanOf("1970-01-01"), "Thursday, January 1st, 1970")
	ThenExact("a far future date", zdHumanOf("2999-07-04"), "Thursday, July 4th, 2999")
	Then("the far future weekday agrees with the independent rule", zdWeekdayName(2999, 7, 4), "Thursday")
	ThenExact("a leap day in the long form", zdHumanOf("2028-02-29"), "Tuesday, February 29th, 2028")
	Then("that weekday agrees with the independent rule", zdWeekdayName(2028, 2, 29), "Tuesday")
	ThenExact("the far past is the plain date in ToRelative", zdRelOf("1970-01-01"), "01/01/1970")
	ThenExact("the far future is the plain date in ToRelative", zdRelOf("2999-07-04"), "04/07/2999")
	Then("the far future is not a count", strcmp(zdRelOf("2999-07-04"), "in 1 week") != 0, 1)
EndScenario()

Scenario("Six frozen days, every offset from -40 to 40: both renderings, the date and the case rule")
	aClocks = [ [ 2026, 10, 24 ], [ 2024, 2, 29 ], [ 2026, 12, 31 ], [ 2026, 3, 1 ], [ 1970, 1, 1 ], [ 2028, 2, 29 ] ]
	for i = 1 to len(aClocks)
		aBad = zdCheckClock(aClocks[i][1], aClocks[i][2], aClocks[i][3], -40, 40)
		cName = "" + aClocks[i][1] + "-" + zdPad(aClocks[i][2]) + "-" + zdPad(aClocks[i][3])
		Then("clock " + cName + ": the 81 dates are right (AddDays)", aBad[1], 0)
		Then("clock " + cName + ": ToHuman is right for all 81", aBad[2], 0)
		Then("clock " + cName + ": ToRelative is right for all 81", aBad[3], 0)
		Then("clock " + cName + ": no short form starts with a capital", aBad[4], 0)
	next
	Then("six clocks were checked", len(aClocks), 6)
EndScenario()

Scenario("Far offsets: a year ahead and a year back, across a leap day")
	StzFreezeClock("2024-02-29")
	ThenExact("365 days after the leap day is 28 February 2025 (a Friday)", zdHumanAt(365), "Friday, February 28th, 2025")
	ThenExact("365 days before is 1 March 2023 (a Wednesday)", zdHumanAt(-365), "Wednesday, March 1st, 2023")
	ThenExact("ToRelative gives the plain date a year ahead", zdRelAt(365), "28/02/2025")
	ThenExact("and a year back", zdRelAt(-365), "01/03/2023")
	ThenExact("the day after the leap day is 1 March, tomorrow", zdHumanAt(1), "tomorrow")
	Then("that day's date is 01/03/2024", zdDateAt(1), "01/03/2024")
	Then("the day before is 28 February", zdDateAt(-1), "28/02/2024")
	StzFreezeClock("2026-12-31")
	Then("the day after 31 December is 01/01/2027", zdDateAt(1), "01/01/2027")
	ThenExact("and it is tomorrow", zdHumanAt(1), "tomorrow")
	ThenExact("8 days after 31 December crosses the year (a Friday)", zdHumanAt(8), "Friday, January 8th, 2027")
	StzFreezeClock("2026-03-01")
	Then("the day before 1 March 2026 is 28 February (not a leap year)", zdDateAt(-1), "28/02/2026")
	ThenExact("8 days before 1 March 2026 (a Saturday)", zdHumanAt(-8), "Saturday, February 21st, 2026")
	ThenExact("31 days after 1 March is 1 April, the plain date", zdRelAt(31), "01/04/2026")
	ThenExact("30 days after 1 March is 31 March, 4 weeks", zdRelAt(30), "in 4 weeks")
	StzUnfreezeClock()
EndScenario()

Scenario("The sibling renderings agree with each other and with a hand calendar")
	StzFreezeClock("2026-10-24")
	d = new stzDate("2024-02-29")
	ThenExact("ToString is day first", d.ToString(), "29/02/2024")
	ThenExact("ToISO8601", d.ToISO8601(), "2024-02-29")
	ThenExact("ToEuropean is the same text as ToString", d.ToEuropean(), "29/02/2024")
	ThenExact("ToAmerican is month first", d.ToAmerican(), "02/29/2024")
	ThenExact("ToShort", d.ToShort(), "Thu 29 Feb")
	ThenExact("ToLong has no ordinal", d.ToLong(), "Thursday, February 29, 2024")
	ThenExact("ToHuman has the ordinal", d.ToHuman(), "Thursday, February 29th, 2024")
	ThenExact("Day is the day name, capitalised like the long forms", d.Day(), "Thursday")
	ThenExact("Month is the month name", d.Month(), "February")
	ThenExact("DayShort", d.DayShort(), "Thu")
	ThenExact("MonthShort", d.MonthShort(), "Feb")
	Then("DayOfYear (31 + 29)", d.DayOfYear(), 60)
	Then("DaysInMonth of a leap February", d.DaysInMonth(), 29)
	Then("DaysInYear of a leap year", d.DaysInYear(), 366)
	Then("it is a leap year", d.IsLeapYear(), 1)
	Then("the Julian day agrees with the independent days-from-civil rule", d.ToJulianDay(), zdDays(2024, 2, 29) + 2440588)
	d = new stzDate("2026-03-15")
	ThenExact("a normal date, ToLong", d.ToLong(), "Sunday, March 15, 2026")
	ThenExact("a normal date, ToShort", d.ToShort(), "Sun 15 Mar")
	Then("2026 is not a leap year", d.IsLeapYear(), 0)
	Then("DaysInYear of 2026", d.DaysInYear(), 365)
	Then("DayOfYear of 15 March 2026 (31 + 28 + 15)", d.DayOfYear(), 74)
	d = new stzDate("2025-12-31")
	ThenExact("31 December ToShort", d.ToShort(), "Wed 31 Dec")
	Then("31 December is day 365", d.DayOfYear(), 365)
	d = new stzDate("1970-01-01")
	ThenExact("the epoch ToLong", d.ToLong(), "Thursday, January 1, 1970")
	Then("the epoch Julian day", d.ToJulianDay(), 2440588)
	d = new stzDate("2999-07-04")
	ThenExact("a far future date ToAmerican", d.ToAmerican(), "07/04/2999")
	StzUnfreezeClock()
EndScenario()

Scenario("The live clock: offsets from the real today, every expectation computed from the machine date")
	StzUnfreezeClock()
	Then("the clock is live in this scenario", StzClockIsFrozen(), 0)
	aBad = zdCheckLive()
	Then("the live offsets are all right dates", aBad[1], 0)
	Then("ToHuman is right at every live offset", aBad[2], 0)
	Then("ToRelative is right at every live offset", aBad[3], 0)
	Then("no live short form starts with a capital", aBad[4], 0)
	Then("the live offsets were -8..8, 27..32, -32..-27, a year each way, the month and year ends, the week boundaries 13 to 15 and 20 to 22 each way, two leap days and fixed calendar days: 66 offsets", aBad[5], 66)
EndScenario()

Summary()

# --- helpers: everything below is independent of stzDate -------------------------------------------
# (kept at the end of the file: top-level code after a func definition becomes part of that function)

func ThenExact(cText, cActual, cExpected)
	nSame = (strcmp(cActual, cExpected) = 0)
	if nSame = 0
		? "    exact expected: [" + cExpected + "]"
		? "    exact got:      [" + cActual + "]"
	ok
	Then(cText, nSame, 1)

func zdHumanAt(nOff)
	zdObj = new stzDate("")
	zdObj.AddDays(nOff)
	return zdObj.ToHuman()

func zdRelAt(nOff)
	zdObj = new stzDate("")
	zdObj.AddDays(nOff)
	return zdObj.ToRelative()

func zdDateAt(nOff)
	zdObj = new stzDate("")
	zdObj.AddDays(nOff)
	return zdObj.Date()

func zdHumanOf(cDate)
	zdObj = new stzDate(cDate)
	return zdObj.ToHuman()

func zdRelOf(cDate)
	zdObj = new stzDate(cDate)
	return zdObj.ToRelative()

# 1 if any rendering of -40..40 days around the frozen clock contains the text (a number written the
# wrong way, such as 1 days or 1 weeks)
func zdHasText(cText)
	zdFound = 0
	for zdN = -40 to 40
		if StzFindFirst(cText, zdHumanAt(zdN)) > 0 or StzFindFirst(cText, zdRelAt(zdN)) > 0
			zdFound = 1
		ok
	next
	return zdFound

func zdPad(nValue)
	if nValue < 10
		return "0" + nValue
	ok
	return "" + nValue

func zdDays(nYear, nMonth, nDay)
	if nMonth <= 2
		nYear = nYear - 1
	ok
	nEra = floor(nYear / 400)
	nYoe = nYear - nEra * 400
	if nMonth > 2
		nMp = nMonth - 3
	else
		nMp = nMonth + 9
	ok
	nDoy = floor((153 * nMp + 2) / 5) + nDay - 1
	nDoe = nYoe * 365 + floor(nYoe / 4) - floor(nYoe / 100) + nDoy
	return nEra * 146097 + nDoe - 719468

func zdCivil(nZ)
	nZ = nZ + 719468
	nEra = floor(nZ / 146097)
	nDoe = nZ - nEra * 146097
	nYoe = floor((nDoe - floor(nDoe / 1460) + floor(nDoe / 36524) - floor(nDoe / 146096)) / 365)
	nYear = nYoe + nEra * 400
	nDoy = nDoe - (365 * nYoe + floor(nYoe / 4) - floor(nYoe / 100))
	nMp = floor((5 * nDoy + 2) / 153)
	nDay = nDoy - floor((153 * nMp + 2) / 5) + 1
	if nMp < 10
		nMonth = nMp + 3
	else
		nMonth = nMp - 9
	ok
	if nMonth <= 2
		nYear = nYear + 1
	ok
	return [ nYear, nMonth, nDay ]

func zdWeekdayName(nYear, nMonth, nDay)
	nZ = zdDays(nYear, nMonth, nDay)
	nIdx = ((nZ + 4) % 7 + 7) % 7
	return $zdWeekdays[nIdx + 1]

func zdSuffix(nDay)
	nRest = nDay % 100
	if nRest >= 11 and nRest <= 13
		return "th"
	ok
	nLast = nDay % 10
	if nLast = 1
		return "st"
	ok
	if nLast = 2
		return "nd"
	ok
	if nLast = 3
		return "rd"
	ok
	return "th"

# the promise of ToHuman, written from the block: aT is the target [ y, m, d ] and nOff its distance
func zdExpHuman(nOff, aT)
	if nOff = 0
		return "today"
	ok
	if nOff = 1
		return "tomorrow"
	ok
	if nOff = -1
		return "yesterday"
	ok
	if nOff >= 2 and nOff <= 7
		return "in " + nOff + " days"
	ok
	if nOff <= -2 and nOff >= -7
		return "" + (-nOff) + " days ago"
	ok
	return zdWeekdayName(aT[1], aT[2], aT[3]) + ", " + $zdMonths[aT[2]] + " " + aT[3] + zdSuffix(aT[3]) + ", " + aT[1]

# the promise of ToRelative: weeks by integer division, the plain date from 31 days either way
func zdExpRel(nOff, aT)
	if nOff = 0
		return "today"
	ok
	if nOff = 1
		return "tomorrow"
	ok
	if nOff = -1
		return "yesterday"
	ok
	nAbs = nOff
	if nAbs < 0
		nAbs = -nAbs
	ok
	cCount = ""
	if nAbs <= 7
		cCount = "" + nAbs + " days"
	but nAbs <= 30
		nWeeks = (nAbs - nAbs % 7) / 7
		if nWeeks = 1
			cCount = "1 week"
		else
			cCount = "" + nWeeks + " weeks"
		ok
	else
		return zdPad(aT[3]) + "/" + zdPad(aT[2]) + "/" + aT[1]
	ok
	if nOff > 0
		return "in " + cCount
	ok
	return cCount + " ago"

# first character class: 1 when the text starts with an upper-case letter
func zdStartsUpper(cText)
	nAsc = ascii(cText[1])
	return (nAsc >= 65 and nAsc <= 90)

# [ wrong dates, wrong ToHuman, wrong ToRelative, short forms starting with a capital, offsets checked ]
func zdCheckAt(nY, nM, nD, aOffsets)
	nBadDate = 0
	nBadHuman = 0
	nBadRel = 0
	nBadCase = 0
	nZ0 = zdDays(nY, nM, nD)
	nCount = len(aOffsets)
	for zdI = 1 to nCount
		nOff = aOffsets[zdI]
		aT = zdCivil(nZ0 + nOff)
		zdObj = new stzDate("")
		zdObj.AddDays(nOff)
		cDate = zdObj.Date()
		cHuman = zdObj.ToHuman()
		cRel = zdObj.ToRelative()
		cExpDate = zdPad(aT[3]) + "/" + zdPad(aT[2]) + "/" + aT[1]
		cExpHuman = zdExpHuman(nOff, aT)
		cExpRel = zdExpRel(nOff, aT)
		if strcmp(cDate, cExpDate) != 0
			nBadDate++
			? "    offset " + nOff + " date: got [" + cDate + "] expected [" + cExpDate + "]"
		ok
		if strcmp(cHuman, cExpHuman) != 0
			nBadHuman++
			? "    offset " + nOff + " ToHuman: got [" + cHuman + "] expected [" + cExpHuman + "]"
		ok
		if strcmp(cRel, cExpRel) != 0
			nBadRel++
			? "    offset " + nOff + " ToRelative: got [" + cRel + "] expected [" + cExpRel + "]"
		ok
		# the case rule, checked on its own: a rendering is capital only when it is the long date,
		# which is only ToHuman at 8 days or more
		nLongHuman = (nOff >= 8 or nOff <= -8)
		if zdStartsUpper(cRel)
			nBadCase++
		ok
		if zdStartsUpper(cHuman) and nLongHuman = 0
			nBadCase++
		ok
		if nLongHuman and zdStartsUpper(cHuman) = 0
			nBadCase++
		ok
	next
	return [ nBadDate, nBadHuman, nBadRel, nBadCase, nCount ]

func zdCheckClock(nY, nM, nD, nFrom, nTo)
	StzFreezeClock("" + nY + "-" + zdPad(nM) + "-" + zdPad(nD))
	aOffsets = []
	for zdK = nFrom to nTo
		aOffsets + zdK
	next
	aBad = zdCheckAt(nY, nM, nD, aOffsets)
	StzUnfreezeClock()
	return aBad

# the real today comes from Ring's own date() (dd/mm/yyyy), never from stzDate; the run is repeated
# once if midnight passed while it ran
func zdCheckLive()
	cBefore = date()
	aBad = zdCheckLiveOnce(cBefore)
	if strcmp(date(), cBefore) != 0
		cBefore = date()
		aBad = zdCheckLiveOnce(cBefore)
	ok
	return aBad

func zdCheckLiveOnce(cToday)
	nY = 0 + substr(cToday, 7, 4)
	nM = 0 + substr(cToday, 4, 2)
	nD = 0 + substr(cToday, 1, 2)
	nZ0 = zdDays(nY, nM, nD)
	aOffsets = []
	for zdK = -8 to 8
		aOffsets + zdK
	next
	for zdK = 27 to 32
		aOffsets + zdK
	next
	for zdK = -32 to -27
		aOffsets + zdK
	next
	for zdK = 13 to 15
		aOffsets + zdK
		aOffsets + (0 - zdK)
	next
	for zdK = 20 to 22
		aOffsets + zdK
		aOffsets + (0 - zdK)
	next
	aOffsets + 365
	aOffsets + (0 - 365)
	# the last day of this month, the first of the next, the last day of this year, the first of the next
	nNextMonthY = nY
	nNextMonthM = nM + 1
	if nNextMonthM = 13
		nNextMonthM = 1
		nNextMonthY = nY + 1
	ok
	nFirstNext = zdDays(nNextMonthY, nNextMonthM, 1)
	aOffsets + (nFirstNext - 1 - nZ0)
	aOffsets + (nFirstNext - nZ0)
	aOffsets + (zdDays(nY, 12, 31) - nZ0)
	aOffsets + (zdDays(nY + 1, 1, 1) - nZ0)
	# two leap days, one in the past and one ahead of every date this file can run on
	aOffsets + (zdDays(2024, 2, 29) - nZ0)
	aOffsets + (zdDays(2028, 2, 29) - nZ0)
	# 30 days past and before the first of next month, then fixed calendar days in this and the
	# neighbouring years (66 offsets in all)
	aOffsets + (zdDays(nNextMonthY, nNextMonthM, 1) - nZ0 + 30)
	aOffsets + (zdDays(nNextMonthY, nNextMonthM, 1) - nZ0 - 30)
	aOffsets + (zdDays(nY, 3, 1) - nZ0)
	aOffsets + (zdDays(nY, 2, 28) - nZ0)
	aOffsets + (zdDays(nY + 1, 3, 1) - nZ0)
	aOffsets + (zdDays(nY - 1, 12, 31) - nZ0)
	aOffsets + (zdDays(nY - 1, 3, 1) - nZ0)
	aOffsets + (zdDays(2026, 10, 24) - nZ0)
	aOffsets + (zdDays(1970, 1, 1) - nZ0)
	aOffsets + (zdDays(2999, 7, 4) - nZ0)
	aOffsets + (zdDays(nY + 1, 2, 28) - nZ0)
	aOffsets + (zdDays(nY - 1, 2, 28) - nZ0)
	aOffsets + (zdDays(nY, 12, 25) - nZ0)
	aOffsets + (zdDays(nY, 1, 1) - nZ0)
	aOffsets + (zdDays(nY, 6, 30) - nZ0)
	aOffsets + (zdDays(nY, 7, 1) - nZ0)
	aOffsets + (zdDays(nY + 1, 12, 31) - nZ0)
	aBad = zdCheckAt(nY, nM, nD, aOffsets)
	return aBad
