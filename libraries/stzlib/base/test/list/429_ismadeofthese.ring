# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #429.
#ERR Error (R14) : Calling Method without definition: ismadeofthese

load "../../stzBase.ring"

pr()

o1 = new stzList([ "by", "except", "stopwords" ])
? o1.IsMadeOfThese([ :by, :except, :stopwords ])
#--> TRUE

pf()
# Executed in 0.01 second(s).
