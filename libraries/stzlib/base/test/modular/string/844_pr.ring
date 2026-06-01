# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #844.

load "../../../stzBase.ring"


o1 = new stzString("ara")
? o1.IsLanguageAbbreviation()
#--> TRUE

? o1.IsShortLanguageAbbreviation()
#--> FALSE

? o1.IsLongLanguageAbbreviation()
#--> TRUE

? o1.LanguageAbbreviationForm()
#--> long

pf()
# Executed in 0.02 second(s).
