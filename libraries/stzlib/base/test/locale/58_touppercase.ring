# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #58.

load "../../stzBase.ring"

pr()

o1 = new stzLocale("fr_FR")
? o1.ToUppercase("tunis") #--> TUNIS
? o1.ToLowercase("tunis") #--> tunis
? o1.ToTitlecase("tunis") #--> Tunis

pf()
# Executed in 0.04 second(s) in Ring 1.23
