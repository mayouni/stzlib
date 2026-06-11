# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #104.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzChar(64544)
? o1.Content() #--> "ﰠ"

? StzCharQ("ﰠ").Name()
#--> ARABIC LIGATURE SAD WITH HAH ISOLATED FORM

pf()
# Executed in almost 0 second(s) in Ring 1.27 (Backed by StzEngine)
# Executed in 0.04 second(s) in Ring 1.23
