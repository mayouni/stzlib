# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #78.

load "../../stzBase.ring"

pr()

? SystemLocale()
#--> fr_FR

o1 = new stzLocale([ :Language = "arabic", :Country = "tunisia" ])
? o1.LanguageName()
#--> arabic

pf()
# Executed in 0.03 second(s) in Ring 1.23
