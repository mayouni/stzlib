# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #528.

load "../../../stzBase.ring"


o1 = new stzList([ "A", "a", "A" ])
o1.ReplaceAt(2, :By = "A")
? o1.Content()
#--> [ "A", "A", "A" ]

pf()
# Executed in almost 0 second(s).
