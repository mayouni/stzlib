# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #905.
#ERR Error (R14) : Calling Method without definition: boxifycharsxt

load "../../stzBase.ring"

pr()

o1 = new stzString("SOFTANZA")
o1.BoxifyCharsXT([])
? o1.Content()
#-->
# ┌───┬───┬───┬───┬───┬───┬───┬───┐
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# └───┴───┴───┴───┴───┴───┴───┴───┘

pf()
# Executed in 0.04 second(s).
