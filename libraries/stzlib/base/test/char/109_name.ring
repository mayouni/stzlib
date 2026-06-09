# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #109.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzChar("O")
? o1.Name() #--> LATIN CAPITAL LETTER O
? o1.Unicode() #--> 79
? o1.UnicodeCategory() #--> letter_uppercase
? ""
o1 = new stzChar("Ο")
? o1.Name() #--> GREEK CAPITAL LETTER OMICRON
? o1.Unicode() #--> 927
? o1.UnicodeCategory() #--> letter_uppercase

pf()
# Executed in 0.06 second(s) in Ring 1.23
