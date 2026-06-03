# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #40.
#ERR Error (R14) : Calling Method without definition: ischarof

load "../../stzBase.ring"

pr()

? StzCharQ("R").IsCharOf("Ring") 	#--> TRUE
? StzCharQ("R").IsLetterOf("Ring") 	#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.23
