# Narrative
# --------
# VizFindManyXT: VizFindMany plus a per-row occurrence count.
#
# Same multi-value grid as VizFindMany -- one "^"/"." marker row per
# searched value -- with a "(count)" tally appended to each row. So a single
# call shows, for every value, both its layout across the list and its
# total number of occurrences. Aligns to lists of single chars.
#
# Extracted from stzlisttest.ring, block #438.

load "../../stzBase.ring"

pr()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? VizFindManyXT([ "A", "B", "C", "D" ])
}
#--> [ "A", "B", "A", "C", "A", "D", "A" ]
#    "A" :  --^----.----^----.----^----.----^-- (4)
#    "B" :  --.----^----.----.----.----.----.-- (1)
#    "C" :  --.----.----.----^----.----.----.-- (1)
#    "D" :  --.----.----.----.----.----^----.-- (1)

pf()
# Executed in 0.02 second(s).
