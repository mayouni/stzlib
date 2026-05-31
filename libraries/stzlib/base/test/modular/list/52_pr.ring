# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #52.

load "../../../stzBase.ring"


o1 = new stzList([ "a", "+", "b", "-", "c", "/", "d", "=", "0" ])
o1.ReplaceMany( ["+", "-", "/" ], :by = "*" )
? o1.Content()	
#--> [ "a", "*", "b", "*", "c", "*", "d", "=", "0" ]

pf()
#--> Executed in 0.04 second(s)
