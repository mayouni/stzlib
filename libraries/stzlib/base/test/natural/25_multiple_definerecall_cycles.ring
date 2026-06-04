# Narrative
# --------
# MULTIPLE DEFINE/RECALL CYCLES
#
# Extracted from stznaturaltest.ring, block #25.

load "../../stzBase.ring"


pr()

Naturally("
    Create a string with 'hello'
    @box
    box@
    @uppercase
    uppercase@
    Show it
")
#-->
# ┌───────┐
# │ HELLO │
# └───────┘

pf()
# Executed in 0.01 second(s) in Ring 1.24
