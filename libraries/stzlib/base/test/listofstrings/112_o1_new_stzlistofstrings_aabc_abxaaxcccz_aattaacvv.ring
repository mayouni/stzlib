# Narrative
# --------
# o1 = new stzListOfStrings([ "aabc", "abxaaxcccz", "aattaacvv" ])
#
# Extracted from stzlistofstringstest.ring, block #112.
#ERR Error (R24) : Using uninitialized variable: o1

load "../../stzBase.ring"

pr()

? @@( o1.FindSubString("aa") )
#--> [ [ 1, [ 1 ] ], [ 2, [ 4 ] ], [ 3, [ 1, 5 ] ] ]

pf()
