# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #624.
#ERR Error (R14) : Calling Method without definition: ismadeofoneofthese

load "../../stzBase.ring"

pr()

o1 = new stzList([ :monday, :monday, :monday ])
? o1.IsMadeOfOneOfThese([ :sunday, :monday, :saturday, :wednesday, :thirsday, :friday, :saturday ])
#--> TRUE

pf()
# Executed in 0.01 second(s).
