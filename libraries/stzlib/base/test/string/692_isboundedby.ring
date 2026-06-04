# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #692.

load "../../stzBase.ring"

pr()

o1 = new stzString('"name"')
? o1.IsBoundedBy([ '"','"' ])	#--> TRUE

o1 = new stzString(':name')
? o1.IsBoundedBy([ ':', NULL ])	#--> TRUE

pf()
# Executed in 0.01 second(s).
