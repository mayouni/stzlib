# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #57.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

# ? StzCharQ("🌹").Name() #--> ERROR: Can not create char object!
# 127801, the real codepoint. The old [ 63, 63 ] was two question marks --
# what a byte-oriented era printed for an astral char it could not decode.
? Unicode("🌹") #--> 127801
? Q("🌹").CharName() # ?--> QUESTION MARK

pf()
# Executed in 0.06 second(s) in Ring 1.23
