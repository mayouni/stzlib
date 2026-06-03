# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #46.
#ERR Error (R14) : Calling Method without definition: isdiacricised

load "../../stzBase.ring"

pr()

? StzCharQ("à").IsDiacricised() #--> TRUE
? StzCharQ("à").IsLatinDiacritic() #--> TRUE

? StzCharQ(ArabicFat7ah()).IsDiacritic() #--> TRUE
? StzCharQ(ArabicFat7ah()).IsArabicDiacritic() #--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.23
