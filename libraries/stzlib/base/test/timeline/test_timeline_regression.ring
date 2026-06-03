# Integration regression suite for stzTimeLine.
# Date-range timeline with Points (single moments) and Spans
# (ranges within). Tests construction, Start/End accessors, Duration,
# AddPoint validation (in-range + blocked), Points listing.
#
# Run from base/datetime/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzTimeLine integration regression ==="

# ------------------------------------------------------------
# Construction + Start/End accessors
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oTl = new stzTimeLine("2026-01-01 00:00:00", "2026-12-31 23:59:59")
chk("Start non-empty",              isString(oTl.Start()) and len(oTl.Start()) > 0)
chk("End non-empty",                isString(oTl.End_()) and len(oTl.End_()) > 0)

# Aliases
chk("StartDate alias",              oTl.StartDate() = oTl.Start())
chk("EndDate alias",                oTl.EndDate() = oTl.End_())

# StartQ / EndQ return stzDateTime objects
oStart = oTl.StartQ()
chk("StartQ returns stzDateTime",   ring_classname(oStart) = "stzdatetime")
oEnd = oTl.EndQ()
chk("EndQ returns stzDateTime",     ring_classname(oEnd) = "stzdatetime")

# ------------------------------------------------------------
# Duration
# ------------------------------------------------------------
? ""
? "--- Duration ---"

nDur = oTl.Duration()
chk("Duration is number",           isNumber(nDur))
chk("Year duration > 0",            nDur > 0)

# DurationQ returns stzDuration
oDur = oTl.DurationQ()
if oDur != NULL
	chk("DurationQ returns stzDuration", ring_classname(oDur) = "stzduration")
	chk("DurationQ Days near 365",       oDur.Days() >= 364 and oDur.Days() <= 366)
else
	chk("DurationQ returns object",      0 = 1)
ok

# ------------------------------------------------------------
# AddPoint
# ------------------------------------------------------------
? ""
? "--- AddPoint ---"

oTl.AddPoint("kickoff", "2026-01-15 09:00:00")
oTl.AddPoint("milestone1", "2026-06-30 17:00:00")

aContent = oTl.Content()
chk("Content has Points",           HasKey(aContent, :Points))
chk("2 points added",               len(aContent[:Points]) = 2)

# Point label uppercased per impl (see line 167)
chk("Point label uppercased",       aContent[:Points][1][1] = "KICKOFF")

# Out-of-range point should raise
bRaised = 0
try
	oTl.AddPoint("outside", "2025-12-31 00:00:00")
catch
	bRaised = 1
done
chk("Out-of-range AddPoint raises",  bRaised = 1)

# ------------------------------------------------------------
# AddPoint aliases
# ------------------------------------------------------------
? ""
? "--- AddPoint aliases ---"

oA = new stzTimeLine("2026-01-01 00:00:00", "2026-12-31 23:59:59")
oA.AddTimePoint("tp", "2026-03-01 12:00:00")
oA.AddMoment("mom", "2026-04-01 12:00:00")
oA.AddInstant("ins", "2026-05-01 12:00:00")
chk("Three aliased adds",           len(oA.Content()[:Points]) = 3)

# ------------------------------------------------------------
# Named param construction
# ------------------------------------------------------------
? ""
? "--- Named params ---"

oNp = new stzTimeLine(:From = "2026-06-01 00:00:00", :To = "2026-06-30 23:59:59")
chk("Named-param ctor works",       isString(oNp.Start()))

aJun = oNp.Content()
oDurJ = oNp.DurationQ()
if oDurJ != NULL
	chk("June duration < 31 days",   oDurJ.Days() <= 30)
ok

# ------------------------------------------------------------
# Mutation: SetStart / SetEnd
# ------------------------------------------------------------
? ""
? "--- SetStart / SetEnd ---"

oMu = new stzTimeLine("2026-01-01 00:00:00", "2026-12-31 23:59:59")
oMu.SetStart("2026-02-01 00:00:00")
oMu.SetEnd("2026-11-30 23:59:59")
chk("After SetStart: changed",      substr(oMu.Start(), "2026-02") > 0)
chk("After SetEnd: changed",        substr(oMu.End_(), "2026-11") > 0)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzTimeLine CHECKS PASSED!"
else
	? "SOME stzTimeLine CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
