# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #41.

load "../../stzBase.ring"

pr()

? StzCharQ("R").UnicodeCategoryNumber() #--> 14

? StringIsLowercase("RiNG")	#--> FALSE
? StzCharQ("R").IsLetter() 		#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.23
