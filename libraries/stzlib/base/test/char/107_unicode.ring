# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #107.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzChar("෴")
? o1.Unicode()
#--> 3572

o1 = new stzChar(3572)
? o1.Content() #--> ෴
? o1.Name() #--> SINHALA PUNCTUATION KUNDDALIYA

pf()
# Executed in 0.04 second(s) in Ring 1.23
