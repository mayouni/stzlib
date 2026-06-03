# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #691.

load "../../stzBase.ring"

pr()

o1 = new stzString("{{{ Scope of Life }}}")

? o1.BeginsWith("{")
#--> TRUE

? o1.EndsWith("}")
#--> TRUE

? o1.IsBoundedBy([ "{", "}" ])
#--> TRUE

? o1.TheseBoundsRemoved("{", "}")
#--> {{ Scope of Life }}

pf()
# Executed in 0.07 second(s) in Ring 1.22
