# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #839.

load "../../stzBase.ring"

pr()

o1 = new stzString("ar-tn")
? o1.IsLocaleAbbreviation()
#--> TRUE

o1 = new stzString("ar-fr")
? o1.IsLocaleAbbreviation()
#--> FALSE

o1 = new stzString("tn-fr")
? o1.IsLocaleAbbreviation()
#--> FALSE

pf()
# Executed in 0.01 second(s) in Ring 1.22
