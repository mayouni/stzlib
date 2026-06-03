# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #72.
#ERR Error (R14) : Calling Method without definition: addxt

load "../../stzBase.ring"

pr()

o1 = new stzString("weloveringlanguage!")
o1.AddXT(" ", :AfterThese = Q([ "we", "love", "ring", "language" ]).Reversed())
#--> we love ring language !

pf()
# Executed in 0.03 second(s)
