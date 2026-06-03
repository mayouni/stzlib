# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #33.

load "../../stzBase.ring"

pr()

o1 = new stzChar("LATIN CAPITAL LETTER N")
? o1.Content() #--> N

o1 = new stzChar("ARABIC LETTER SEEN")
? o1.Content() #--> س

o1 = new stzChar("ROMAN NUMERAL THREE")
? o1.Content() #--> Ⅲ

pf()
# Executed in 0.13 second(s) in Ring 1.23
