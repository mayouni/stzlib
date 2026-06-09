# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #56.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? StzCharQ("U+214B").Content() #--> ⅋
? StzCharQ("0x214B").Name() #--> TURNED AMPERSAND

pf()
# Executed in 0.08 second(s) in Ring 1.23
