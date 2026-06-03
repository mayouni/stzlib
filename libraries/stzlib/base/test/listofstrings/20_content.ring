# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #20.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "A", "B", "C", "D", "E", "F"])
o1.ReplaceManyOneByOneCS([ "B", "D", "F"], :With = [ "1", "2", "3" ], :CS=TRUE)
#--> [ "A", "1", "C", "2", "E", "3" ]
? o1.Content()

pf()
# Executed in 0.04 second(s)
