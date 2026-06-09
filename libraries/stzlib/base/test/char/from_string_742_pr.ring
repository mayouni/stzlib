# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #742.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? StzCharQ(":").IsPunctuation()
#--> TRUE

? StzCharQ(":").CharType()
#--> punctuation_other

pf()
# Executed in 0.35 second(s).
