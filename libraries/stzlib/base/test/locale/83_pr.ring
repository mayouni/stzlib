# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #83.

load "../../stzBase.ring"


o1 = new stzLocale("fr_FR")
# Or o1 = new stzLocale([:Country = "france", :Language = "french"])

? o1.LanguageName() #--> french
? o1.bcp47Abbreviation() #--> fr
? o1.FirstDayOfWeek() #--> monday
? o1.CurrencyName() #--> Euro

pf()
# Executed in 0.04 second(s) in Ring 1.23
