# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #842.

load "../../stzBase.ring"

pr()

o1 = new stzString("fr")
? o1.IsLocaleAbbreviation()
#--> FALSE

o1 = new stzString("fr-fr")
? o1.IsLocaleAbbreviation()
#--> TRUE

? StzLocaleQ("fr-fr").Country()
# france

pf()
# Executed in 0.01 second(s) in Ring 1.24
# Executed in 0.02 second(s).in ring 1.20
