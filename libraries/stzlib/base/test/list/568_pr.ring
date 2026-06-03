# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #568.

load "../../stzBase.ring"


o1 = new stzList([ "a", "b", "C", "D", "e" ])
o1.InsertBeforeWXT( '{ Q(@item).IsLowercase() }', "*" )
? o1.Content()
#--> [ "*", "a", "*", "b", "C", "D", "*", "e" ]

pf()
# Executed in 0.13 second(s).
