# Narrative
# --------
# BOXING WITH MODIFIERS
#
# Extracted from stznaturaltest.ring, block #5.
#ERR Error (R14) : Calling Method without definition: findantisectionszz

load "../../stzBase.ring"


pr()

Naturally("
    Create a fantastic string with 'Softanza ♥ Ring'
    @Box it
    The box@ should be rounded
    @Box it but the box@ should be rounded
    Display the result
")
#-->
# ╭─────────────────╮
# │ Softanza ♥ Ring │
# ╰─────────────────╯

pf()
# Executed in 0.02 second(s) in Ring 1.24
