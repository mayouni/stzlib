# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #904.

load "../../../stzBase.ring"


o1 = new stzString("SOFTANZA")
o1.BoxifyChars()
? o1.Content()
#-->
# ┌───┬───┬───┬───┬───┬───┬───┬───┐
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# └───┴───┴───┴───┴───┴───┴───┴───┘

pf()
# Executed in 0.04 second(s).
