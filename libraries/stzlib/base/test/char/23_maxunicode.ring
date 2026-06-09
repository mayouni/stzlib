# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #23.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? MaxUnicode()
#--> 1_114_112

? NumberOfUnicodeChars()
#--> 149_186

? LastUnicodeChar()
#--> 䛂

? Unicode("䛂")

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.04 second(s) in Ring 1.20
