# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #827.

load "../../stzBase.ring"


o1 = new stzString("RÉSERVÉ")

? o1.UnicodeCompareWithInSystemLocale("réservé")
#--> :Greater

//? o1.UnicodeCompareWithInLocale("réservé", "fr-FR")	#TODO

pf()
# Executed in 0.01 second(s).
