# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #84.

load "../../stzBase.ring"


o1 = new stzLocale("en-US")
? o1.Abbreviation() #--> en_US
? o1.Abbreviation() #--> en_US
? o1.Country() #--> united_states

pf()
# Executed in 0.02 second(s) in Ring 1.23
