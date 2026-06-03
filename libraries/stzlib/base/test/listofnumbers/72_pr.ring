# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #72.

load "../../stzBase.ring"


o1 = new stzString("weloveringlanguage!")
o1.AddXT(" ", :AfterThese = Q([ "we", "love", "ring", "language" ]).Reversed())
#--> we love ring language !

pf()
# Executed in 0.03 second(s)
