# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #624.

load "../../stzBase.ring"


o1 = new stzList([ :monday, :monday, :monday ])
? o1.IsMadeOfOneOfThese([ :sunday, :monday, :saturday, :wednesday, :thirsday, :friday, :saturday ])
#--> TRUE

pf()
# Executed in 0.01 second(s).
