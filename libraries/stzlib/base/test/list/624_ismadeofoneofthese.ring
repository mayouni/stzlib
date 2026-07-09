# Narrative
# --------
# Extracted from stzlisttest.ring, block #624.

load "../../stzBase.ring"

pr()

o1 = new stzList([ :monday, :monday, :monday ])
? o1.IsMadeOfOneOfThese([ :sunday, :monday, :saturday, :wednesday, :thirsday, :friday, :saturday ])
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.01 second(s) before
