# Narrative
# --------
# StringifyAndReplace(subStr, with): render every item to its string form,
# then SUBSTRING-replace within each.
#
# First each item is stringified (numbers -> "10", a sublist ->
# '[ "tunis", "paris" ]', etc.), then subStr is replaced by `with` inside
# those strings -- so the comma in the stringified sublist becomes "*",
# while the "*N" items (no comma) are untouched. The replace is the
# engine-backed, UTF-8-safe StzReplace.
#
# Extracted from stzlisttest.ring, block #238. (Two fixes vs the raw
# extraction: the stray `aLarge` line is now proper aList appends; and the
# recorded output's "__*N__" markers were artifacts of an old buggy
# implementation -- corrected to the real substring-replace result.)

load "../../stzBase.ring"

pr()

aList = [ 10, 20, "One", "ONE", [ :Tunis, :Paris ], 30, "two" ]
for i = 1 to 10
	aList + ("*" + i)
next
aList + "in"
aList + "out"
aList + "IN"
aList + "OUT"

o1 = new stzList(aList)

? @@( o1.StringifyAndReplaceQ(",", "*").Content() )
#--> [ "10", "20", "One", "ONE", '[ "tunis"* "paris" ]', "30", "two", "*1", "*2", "*3", "*4", "*5", "*6", "*7", "*8", "*9", "*10", "in", "out", "IN", "OUT" ]

? o1.ContainsDuplicates()
#--> FALSE

pf()
# Executed in almost 0 second(s)
