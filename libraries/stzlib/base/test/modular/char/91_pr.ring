# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #91.

load "../../../stzBase.ring"


? CurrentUnicodeVersion() #--> 13.0
o1 = new stzChar("四")
? o1.UnicodeVersion() #--> 0.9
? o1.IntroducedInUnicodeVersion() #--> 0.9

pf()
# Executed in almost 0 second(s) in Ring 1.23
