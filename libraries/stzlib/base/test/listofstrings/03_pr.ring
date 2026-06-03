# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #3.

load "../../stzBase.ring"


o1 = new stzListOfStrings([ "--**-*", "*---*", "--*-***" ])
o1.RemoveSubString("*")
? @@( o1.Content() )
#--> [ "---", "---", "---" ]

pf()
# Executed in 0.05 second(s)
