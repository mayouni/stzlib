# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #68.
#ERR Error (R14) : Calling Method without definition: isturnedchar

load "../../stzBase.ring"

pr()

? StzCharQ("ʍ").IsTurnedChar() #--> TRUE
? StzCharQ("ᴟ").IsTurnedChar() #--> TRUE
? StzCharQ("ꟺ").IsTurnedChar() #--> TRUE

pf()
# Executed in 0.08 second(s) in Ring 1.23
