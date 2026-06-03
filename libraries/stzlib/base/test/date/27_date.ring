# Narrative
# --------
# pr()
#
# Extracted from stzdatetest.ring, block #27.

load "../../stzBase.ring"

pr()

o1 = new stzDate(:Today)

? o1.Date()		#--> 30/09/2025
? o1.ToHuman()	+ NL	#--> today

o1 + "1 day"
? o1.Date()		#--> 01/10/2025
? o1.ToHuman() + NL	#--> tomorrow

o1 - "2 days"
? o1.Date()		#--> 29/09/2025
? o1.ToHuman() + NL	#--> yesterday

o1 + "2 weeks"
? o1.Date()		#--> 13/10/2025
? o1.ToRelative()	#--> in 1 week

pf()
# Executed in 0.01 second(s) in Ring 1.24
