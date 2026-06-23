# Narrative
# --------
# VizFindMany: one marker row per searched value, in a shared grid.
#
# Given several values to locate at once, VizFindMany draws ONE row per
# value beneath the rendered list. In each row, "^" marks where THAT value
# occurs and "." marks the columns taken by the OTHER searched values (so
# you see how the searches interleave); "-" is empty space. Here A/B/C/D are
# all mapped over [ "A","B","A","C","A","D","A" ] in a single visual.
#
# Extracted from stzlisttest.ring, block #437.

load "../../stzBase.ring"

pr()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? VizFindMany([ "A", "B", "C", "D" ])
}
#--> [ "A", "B", "A", "C", "A", "D", "A" ]
#    "A" :  --^----.----^----.----^----.----^--
#    "B" :  --.----^----.----.----.----.----.--
#    "C" :  --.----.----.----^----.----.----.--
#    "D" :  --.----.----.----.----.----^----.--

pf()
# Executed in 0.02 second(s).
