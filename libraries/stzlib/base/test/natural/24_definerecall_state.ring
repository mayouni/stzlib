# Narrative
# --------
# DEFINE/RECALL STATE
#
# Extracted from stznaturaltest.ring, block #24.
#ERR Error (R14) : Calling Method without definition: findantisectionszz

load "../../stzBase.ring"


pr()

Naturally("
    Create a string with 'test'
    @box
    Uppercase it
    box@
    Show it
")
#-->
# ┌──────┐
# │ TEST │
# └──────┘

pf()
# Executed in 0.01 second(s) in Ring 1.24
