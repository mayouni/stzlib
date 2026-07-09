# Narrative
# --------
# Extracted from stzlisttest.ring, block #643.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 2, 1, 3 ])
? o1.ItemsHaveSameOrderAs([ 2, 1, 3, 6 ])
#-- TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.27
