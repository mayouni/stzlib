# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #82.

load "../../../stzBase.ring"


o1 = new stzLocale(:C)
? o1.LanguageName() #--> ""

o1 = new stzLocale(:system)
? o1.LanguageName() #--> ""

pf()
# Executed in 0.02 second(s) in Ring 1.23
