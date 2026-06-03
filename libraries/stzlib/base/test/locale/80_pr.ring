# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #80.

load "../../stzBase.ring"


o1 = new stzLocale("fr")
? o1.LanguageName() #--> french
? o1.CountryName()	#--> france
? o1.ScriptName()	#--> latin

pf()
# Executed in 0.02 second(s) in Ring 1.23
