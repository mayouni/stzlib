# Narrative
# --------
# StringifyAndReplaceXT rewrites every string item of a list, swapping one
# substring for another, even deep inside nested sublists.
#
# Here a large list (a few literal "--_--" markers, a nested [12, "--_--", 10],
# and 10,000 "ring" fillers) is wrapped in a stzList. StringifyAndReplaceXT("_", "♥")
# walks the whole structure and turns every "_" into "♥". Content()[2] then
# reads back the second top-level element -- the nested sublist -- showing that
# the replacement reached inside it: its middle item "--_--" is now "--♥--",
# while the surrounding numbers 12 and 10 are untouched. The "XT" variant works
# structurally (recursing into sublists) rather than flattening to one string.
#
# Extracted from stzlisttest.ring, block #97.

load "../../stzBase.ring"

pr()

aLargeList = [ "--_--", [ 12, "--_--", 10], "--_--", 9 ]
for i = 1 to 10_000
	aLargeList + "ring"
next
aLargeList + "--_--" + "--_--"

o1 = new stzList(aLargeList)
o1.StringifyAndReplaceXT("_", "♥")
? o1.Content()[2]
#--> [ 12, "--♥--", 10 ]

pf()
# Executed in 0.09 second(s) in Ring 1.27
# Executed in 0.21 second(s) in Ring 1.22
# Executed in 0.50 second(s) in Ring 1.20
