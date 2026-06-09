# Narrative
# --------
# 01 Ring State Pointers
#
# Extracted from stzglobalsystemtest.ring (single-block file; the
# original used no `/*---` delimiters, so the whole body
# is preserved verbatim as one modular block).
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"
pr()

pState1 = ring_state_init()
pState2 = ring_state_init()

? IsPointer(pState1)
#--> TRUE

? IsPointer(pState2)
#--> TRUE

? ArePointers([ pState1, pState2 ])
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.21
