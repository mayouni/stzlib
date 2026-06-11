# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #4.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? Basmalah()
#--> ﷽

? StzChar(65021)
#--> ﷽

? StzCharQ(65021).Name()
#--> ARABIC LIGATURE BISMILLAH AR-RAHMAN AR-RAHEEM

? StzCharQ(65021).SizeInBytes()
#--> 35

? StzCharQ(65021).SizeInChars()
#--> 1

pf()
# Executed in almost 0 second(s) in Ring 1.27 (Backed by StzEngine)
# Executed in 0.05 second(s) on Ring 1.21
# Executed in 0.09 second(s) on ring 1.20
