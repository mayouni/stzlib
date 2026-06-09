# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #54.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? UnicodeToChar(65021) #--> ﷽
? StzCharQ("﷽").Name()
#--> ARABIC LIGATURE BISMILLAH AR-RAHMAN AR-RAHEEM

pf()
# Executed in 0.06 second(s) in Ring 1.23
