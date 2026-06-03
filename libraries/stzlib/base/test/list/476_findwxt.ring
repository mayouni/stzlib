# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #476.
#ERR exit 1

load "../../stzBase.ring"

pr()

o1 = new stzList([ "_", "_", 1:3, "_", 5:9, "_" ])
? o1.FindWXT( :Where = '{ Q(@item).IsOneOfThese([ 1:3, 5:9 ]) }' )
#--> [ 3, 5 ]

pf()
# Executed in 0.13 second(s).
