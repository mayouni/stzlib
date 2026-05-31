# Narrative
# --------
# pr()
#
# Extracted from stzhexnumbertTest.ring, block #3.

load "../../../stzBase.ring"

o1 = new stzList([ "12", "25", "38" ])
o1.Numberify() # Or Numbrify()
? @@( o1.Content() )
#--> [ 12, 25, 38 ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
