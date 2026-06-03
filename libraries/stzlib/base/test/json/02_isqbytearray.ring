# Narrative
# --------
# pr()
#
# Extracted from stzjsontest.ring, block #2.
#ERR Error (R3) : Calling Function without definition: isqbytearray

load "../../stzBase.ring"

pr()

? IsQByteArray( StringToQByteArray("XYZ") )
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.22
