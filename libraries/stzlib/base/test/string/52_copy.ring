# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #52.
#ERR Error (R14) : Calling Method without definition: spacifyq

load "../../stzBase.ring"

pr()

o1 = new stzString("ilir")

? o1.Copy().UppercaseQ().SpacifyQ().ReplaceQ(" ", "*").Content()
#--> "I*L*R"

? o1.Content()
#--> "ilir"

pf()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.10 second(s) in Ring 1.17
