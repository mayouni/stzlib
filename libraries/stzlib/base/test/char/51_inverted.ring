# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #51.
#ERR Error (R14) : Calling Method without definition: inverted

load "../../stzBase.ring"

pr()

? StzCharQ("f").Inverted()	#--> "f"

? StzCharQ("L").Inverted()	#--> "⅂"
? StzCharQ("I").Inverted()	#--> "I"
? StzCharQ("F").Inverted()	#--> "Ⅎ"
? StzCharQ("E").Inverted()	#--> "E"

pf()
# Executed in 0.06 second(s) in Ring 1.23
