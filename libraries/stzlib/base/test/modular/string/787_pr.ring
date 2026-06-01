# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #787.

load "../../../stzBase.ring"


? StzStringQ("[ 2, 3, 5:7 ]").IsListInString()
#--> TRUE

? StzStringQ("'A':'F'").IsListInString()
#--> TRUE

pf()
# Executed in 0.04 second(s).
