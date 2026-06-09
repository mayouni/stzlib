# Integration regression suite for stzDuration.
# Three ctor shapes: string ("2h 30m"), numeric (seconds), hashlist
# (:days/:hours/:minutes/:seconds/:milliseconds). Accessors: Total*
# (in unit) + per-unit getters (Days/Hours/Minutes/Seconds).
# Compare / IsEqualTo / IsLessThan / IsGreaterThan / IsBetween.
#
# Run from base/datetime/test/.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzDuration integration regression ==="

# ------------------------------------------------------------
# Construction from numeric seconds
# ------------------------------------------------------------
? ""
? "--- Construction (numeric) ---"

oDr = new stzDuration(3661)   # 1h 1m 1s
chk("TotalSeconds = 3661",          oDr.TotalSeconds() = 3661)
chk("TotalMinutes = 61",            oDr.TotalMinutes() = 61)
chk("TotalHours = 1",               oDr.TotalHours() = 1)
chk("ToSeconds alias = 3661",       oDr.ToSeconds() = 3661)
chk("ToHours alias = 1",            oDr.ToHours() = 1)

# Per-unit getters
chk("Hours() = 1",                  oDr.Hours() = 1)
chk("Minutes() = 1",                oDr.Minutes() = 1)
chk("Seconds() = 1",                oDr.Seconds() = 1)
chk("Days() = 0",                   oDr.Days() = 0)
chk("Milliseconds() = 0",           oDr.Milliseconds() = 0)

# 2 days 3 hours 4 minutes 5 seconds = 2*86400 + 3*3600 + 4*60 + 5
nFull = 2*86400 + 3*3600 + 4*60 + 5
oFull = new stzDuration(nFull)
chk("Full Days = 2",                oFull.Days() = 2)
chk("Full Hours = 3",               oFull.Hours() = 3)
chk("Full Minutes = 4",             oFull.Minutes() = 4)
chk("Full Seconds = 5",             oFull.Seconds() = 5)
chk("Full TotalDays = 2",           oFull.TotalDays() = 2)
chk("Full TotalHours = 51",         oFull.TotalHours() = 51)

# ------------------------------------------------------------
# Construction from hashlist
# ------------------------------------------------------------
? ""
? "--- Construction (hashlist) ---"

oH = new stzDuration([
	:days = 1,
	:hours = 2,
	:minutes = 30,
	:seconds = 45
])
chk("Hash Days = 1",                oH.Days() = 1)
chk("Hash Hours = 2",               oH.Hours() = 2)
chk("Hash Minutes = 30",            oH.Minutes() = 30)
chk("Hash Seconds = 45",            oH.Seconds() = 45)

# Singular keys (:hour vs :hours)
oH2 = new stzDuration([
	:day = 1,
	:hour = 6
])
chk("Singular keys also work",      oH2.Days() = 1 and oH2.Hours() = 6)

# Milliseconds
oMs = new stzDuration([
	:seconds = 1,
	:milliseconds = 500
])
chk("Ms preserved",                 oMs.Milliseconds() = 500)
chk("Total = 1 sec",                oMs.TotalSeconds() = 1)

# ------------------------------------------------------------
# Components()
# ------------------------------------------------------------
? ""
? "--- Components ---"

aC = oFull.Components()
chk("Components is hashlist",       isList(aC) and IsHashList(aC))
chk("Components Days = 2",          aC[:Days] = 2)
chk("Components Hours = 3",         aC[:Hours] = 3)
chk("Components Seconds = 5",       aC[:Seconds] = 5)

# ------------------------------------------------------------
# Compare / IsEqualTo / IsLessThan / IsGreaterThan
# ------------------------------------------------------------
? ""
? "--- Compare ---"

oA = new stzDuration(100)
oB = new stzDuration(200)

chk("A.IsLessThan(B) = 1",          oA.IsLessThan(oB) = 1)
chk("B.IsGreaterThan(A) = 1",       oB.IsGreaterThan(oA) = 1)
chk("A.IsEqualTo(A) = 1",           oA.IsEqualTo(oA) = 1)
chk("A.IsEqualTo(B) = 0",           oA.IsEqualTo(oB) = 0)

oMid = new stzDuration(150)
chk("Mid IsBetween(A, B) = 1",      oMid.IsBetween(oA, oB) = 1)

oOut = new stzDuration(300)
chk("Out IsBetween(A, B) = 0",      oOut.IsBetween(oA, oB) = 0)

# ------------------------------------------------------------
# Edges
# ------------------------------------------------------------
? ""
? "--- Edges ---"

# Zero
oZ = new stzDuration(0)
chk("Zero TotalSeconds = 0",        oZ.TotalSeconds() = 0)
chk("Zero Days = 0",                oZ.Days() = 0)

# Empty string
oES = new stzDuration("")
chk("Empty string TotalSeconds = 0", oES.TotalSeconds() = 0)

# Very large
oLg = new stzDuration(86400 * 365)  # one year worth of seconds
chk("Year in Days = 365",           oLg.Days() = 365)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzDuration CHECKS PASSED!"
else
	? "SOME stzDuration CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
