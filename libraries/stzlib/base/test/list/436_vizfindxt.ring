# Narrative
# --------
# VizFindXT: VizFind plus a labelled row and an occurrence count.
#
# VizFind draws a "^"/"-" marker line under the rendered list so the eye
# lands on the matches. VizFindXT (the eXtended display) adds a "<item> :"
# label in front of the marker line and a "(count)" tally at the end -- so
# you read both WHERE the value occurs and HOW MANY times in one glance.
# Like VizFind, it currently aligns to lists of single chars.
#
# Extracted from stzlisttest.ring, block #436.

load "../../stzBase.ring"

pr()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? VizFindXT("A")
}
#--> [ "A", "B", "A", "C", "A", "D", "A" ]
#    "A" :  --^---------^---------^---------^-- (4)

pf()
# Executed in 0.01 second(s).
