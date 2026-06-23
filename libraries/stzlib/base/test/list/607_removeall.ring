# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #607.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "c", "a", "a", "b", "c" ])
o1.RemoveAll("a")
? o1.Content()
#--> [ "b", "c", "b", "c" ]

pf()
# Executed in almost 0 second(s).
