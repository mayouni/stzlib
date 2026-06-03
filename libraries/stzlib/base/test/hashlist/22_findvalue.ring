# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #22.

load "../../stzBase.ring"

pr()

o1 = new stzHashList([
	:math = 18,
	:stats = "good",
	:chemistry = 18,
	:history = [ 10, 15 ]
])

? @@( o1.FindValue(18) )
#--> [ 1, 3 ] 

? @@( o1.FindValue("good") )	// TODO: CaseSensitivity
#--> [ 2 ]
	
? @@( o1.FindValue([ 10, 15 ]) )
#--> [ 4 ]

pf()
# Executed in 0.02 second(s)
