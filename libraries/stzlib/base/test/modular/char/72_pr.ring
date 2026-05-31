# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #72.

load "../../../stzBase.ring"


? StzCharQ("،").IsWordSeparator() 	#--> TRUE
? StzCharQ(" ").IsWordSeparator() 	#--> TRUE
? StzCharQ(".").IsSentenceSeparator() 	#--> TRUE
? StzCharQ(NL).IsLineSeparator() 	#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.23
