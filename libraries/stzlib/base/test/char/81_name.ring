# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #81.
#ERR Error (R14) : Calling Method without definition: isturnedchar

load "../../stzBase.ring"

pr()

o1 = new stzChar("⅋")
? o1.Name() #--> TURNED AMPERSAND
? o1.IntroducedInUnicodeVersion() #--> 3.2
? o1.UnicodeCategory() #--> symbol_math
? o1.IsTurnedChar() #--> TRUE

pf()
# Executed in 0.07 second(s) in Ring 1.23
