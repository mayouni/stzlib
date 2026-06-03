# Narrative
# --------
# Creating an empty stzDate object and then setting the date
#
# Extracted from stzdatetest.ring, block #2.
# @clock 2025-10-10 00:00:00

load "../../stzBase.ring"


pr()

o1 = new stzDate("")
? o1.Date()
#--> 10/10/2025

? o1.ToHuman() + NL
#--> today

#--

o1.SetDate(Tomorrow())
? o1.Date()
#--> 11/10/2025

? o1.ToHuman()
#--> tomorrow

pf()
# Executed in 0.01 second(s) in Ring 1.24
