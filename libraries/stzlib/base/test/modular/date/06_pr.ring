# Narrative
# --------
# pr()
#
# Extracted from stzdatetest.ring, block #6.

load "../../../stzBase.ring"


? Today() #--> 10/10/2025

o1 = new stzDate("In 15 days")
? o1.Date() #--> 25/10/2025
? o1.ToHuman()
#--> Saturday, October 25th, 2025

pf()
# Executed in 0.01 second(s) in Ring 1.24
