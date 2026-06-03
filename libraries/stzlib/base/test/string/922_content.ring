# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #922.

load "../../stzBase.ring"

pr()

o1 = new stzString("AB3CD6EF9GH")
o1.ReplaceCharsAtPositions([ 3, 9, 6], Heart())
? o1.Content()
#--> AB♥CD♥EF♥GH

pf()
# Executed in 0.01 second(s).
