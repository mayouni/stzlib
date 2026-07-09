# Narrative
# --------
# Extracted from stzlisttest.ring, block #640.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "c" ])
? o1.ItemsHaveSameOrderAs([ "a", "c", "f" ])
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.27
