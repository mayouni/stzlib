# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #116.

load "../../stzBase.ring"

pr()

ostr = new stzString("s㊱m")
? ostr.NumberOfChars() #--> 3
? ostr[2] #--> ㊱

pf()
# Executed in almost 0 second(s) in Ring 1.23
