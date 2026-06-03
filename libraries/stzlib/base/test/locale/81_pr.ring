# Narrative
# --------
# pr()
#
# Extracted from stzlocaletest.ring, block #81.

load "../../stzBase.ring"


o1 = new stzLocale("es")
? o1.LanguageName() #--> spanish

? o1.LanguageAbbreviation() #--> es
? o1.bcp47Abbreviation() #--> es
? StzStringQ("es_ES").IsLocaleAbbreviation() #--> TRUE

pf()
# Executed in 0.03 second(s) in Ring 1.23
