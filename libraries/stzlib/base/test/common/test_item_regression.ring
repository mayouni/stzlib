# Integration regression suite for stzItem / stzItemCS.
# stzItem represents an item-in-a-context (item + list it's looked up in).
# Covers init (string + CS variants), Item / List accessors,
# NumberOfItems, NumberOfOccurrence variants, Positions, edges.
#
# Run from base/list/test/.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzItem integration regression ==="

# ------------------------------------------------------------
# Construction (stzItemCS: item, list, case-sensitivity)
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oI = new stzItemCS("a", [ "a", "b", "a", "c", "a" ], 1)
chk("Item() = 'a'",                 oI.Item() = "a")
chk("Content alias",                oI.Content() = "a")
chk("Value alias",                  oI.Value() = "a")
chk("List() len = 5",               len(oI.List()) = 5)
chk("CaseSensitive() = 1",          oI.CaseSensitive() = 1)

# ------------------------------------------------------------
# NumberOfOccurrence variants
# ------------------------------------------------------------
? ""
? "--- NumberOfOccurrence ---"

# Item "a" appears 3 times in [a, b, a, c, a]
chk("NumberOfOccurrenceCS(1) = 3",  oI.NumberOfOccurrenceCS(1) = 3)
chk("NumberOfOccurrence = 3",       oI.NumberOfOccurrence() = 3)
chk("NumberOfOccurrences = 3",      oI.NumberOfOccurrences() = 3)
chk("HowManyOccurrence = 3",        oI.HowManyOccurrence() = 3)

# Case-insensitive: "A" in mixed-case list
oICi = new stzItemCS("A", [ "A", "a", "B", "a" ], 0)
chk("CI NumberOfOccurrence = 3",    oICi.NumberOfOccurrenceCS(0) = 3)

# ------------------------------------------------------------
# Positions
# ------------------------------------------------------------
? ""
? "--- Positions ---"

oIp = new stzItemCS("x", [ "x", "y", "x", "z", "x" ], 1)
aPos = oIp.PositionsCS(1)
chk("PositionsCS returns list",     isList(aPos))
chk("PositionsCS len = 3",          len(aPos) = 3)
chk("Positions = [1,3,5]",          aPos[1] = 1 and aPos[2] = 3 and aPos[3] = 5)

# Alias
aOcc = oIp.Occurrences()
chk("Occurrences alias len = 3",    len(aOcc) = 3)

# ------------------------------------------------------------
# Edges
# ------------------------------------------------------------
? ""
? "--- Edges ---"

# Item NOT in list
oNone = new stzItemCS("z", [ "a", "b", "c" ], 1)
chk("Missing item: count = 0",      oNone.NumberOfOccurrence() = 0)
chk("Missing item: positions = []", len(oNone.PositionsCS(1)) = 0)

# Item appears once
oOne = new stzItemCS("only", [ "only" ], 1)
chk("Single occurrence: count = 1", oOne.NumberOfOccurrence() = 1)
chk("Single position = [1]",        oOne.PositionsCS(1)[1] = 1)

# Numeric items
oNum = new stzItemCS(5, [ 1, 5, 2, 5, 3 ], 1)
chk("Numeric: count = 2",           oNum.NumberOfOccurrence() = 2)
chk("Numeric: positions = [2,4]",   oNum.PositionsCS(1)[1] = 2 and oNum.PositionsCS(1)[2] = 4)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzItem CHECKS PASSED!"
else
	? "SOME stzItem CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
