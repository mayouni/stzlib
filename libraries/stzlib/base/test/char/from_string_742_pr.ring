# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #742.

load "../../stzBase.ring"

pr()

? StzCharQ(":").IsPunctuation()
#--> TRUE

? StzCharQ(":").CharType()
#--> punctuation_other

pf()
# Executed in 0.35 second(s).
