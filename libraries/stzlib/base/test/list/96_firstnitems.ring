# Narrative
# --------
# Taking head and tail slices of a list with FirstNItems / LastNItems.
#
# A small heterogeneous seed list (strings plus a nested sublist) is
# padded out to ~1000 trailing "_--_" entries to make a large list.
# StringifyAndReplace("_", "heart") first renders every element to its
# textual form (so the nested [12,...,10] becomes a quoted string and the
# integer 9 becomes "9"), then swaps each underscore for the heart glyph.
# FirstNItems(5) returns the leading five rendered items; LastNItems(3)
# returns the trailing three -- all identical "heart--heart" padding tokens.
#
# Extracted from stzlisttest.ring, block #96.

load "../../stzBase.ring"

pr()

aLargeList = [ "--_--", [ 12, "--_--", 10], "--_--", 9 ]
for i = 1 to 1_000
	aLargeList + "_--_"
next

o1 = new stzList(aLargeList)
o1.StringifyAndReplace("_", "♥")

? o1.FirstNItems(5)
#--> [ "--♥--", '[ 12, "--♥--", 10 ]', "--♥--", "9", "♥--♥" ]

? o1.LastNItems(3)
#--> [ "♥--♥", "♥--♥", "♥--♥" ]

pf()
# Executed in 0.09 second(s)
