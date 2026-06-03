# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #256.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "A", "A", "C", "D", "B", "E", "a" , "b"])
? @@( o1.DuplicatesCSZ(:CaseSensitive = FALSE) )
#--> [ [ "A", [ 3, 4, 9 ] ], [ "B", [ 7, 10 ] ] ]

pf()
# Executed in 0.03 second(s)
