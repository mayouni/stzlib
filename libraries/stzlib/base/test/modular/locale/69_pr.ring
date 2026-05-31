# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #69.

load "../../../stzBase.ring"


o1 = new stzLocale("pt_Latn_BR")
? o1.Abbreviation()	#--> pt_BR
? o1.language()		#--> portuguese				
? o1.Script()		#--> latin
? o1.Country()		#--> brazil

pf()
# Executed in 0.02 second(s) in Ring 1.23
