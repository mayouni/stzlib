# Narrative
# --------
# # Now we say:
#
# Extracted from stzchainofvaluetest.ring, block #3.
#ERR Error (R24) : Using uninitialized variable: v

load "../../stzBase.ring"

pr()

OnlyWhen(:v).Is("12").DoThis('{ ? "Done! Only because you requested it." }')
# It works! And if you ask abusively why chain stopped...
? OnlyWhen(:v).Is("12").WhychainStopped() # Softanza tells you chain is not stopped!

pf()
