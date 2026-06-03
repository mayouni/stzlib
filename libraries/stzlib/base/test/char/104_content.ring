# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #104.

load "../../stzBase.ring"

pr()

o1 = new stzChar(64544)
? o1.Content() #--> "ﰠ"

? StzCharQ("ﰠ").Name() # ARABIC LIGATURE SAD WITH HAH ISOLATED FORM

pf()
# Executed in 0.04 second(s) in Ring 1.23
