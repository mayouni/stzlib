# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #711.

load "../../../stzBase.ring"


? StzStringQ("tunis").IsLowercased()
#--> TRUE

? StzStringQ("TUNIS").IsUppercased()
#--> TRUE

? StzStringQ("Tunis").IsTitlecased()
#--> TRUE

//? StzStringQ("tunis").IsFoldcased()	#TODO

pf()
