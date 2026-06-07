# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #902.

load "../../stzBase.ring"

pr()

o1 = new stzString("RING")

? o1.BoxEachCharQ().Content()
#-->
# ┌───┬───┬───┬───┐
# │ R │ I │ N │ G │
# └───┴───┴───┴───┘

? o1.Content()
#-->
# ┌───┬───┬───┬───┐
# │ R │ I │ N │ G │
# └───┴───┴───┴───┘

pf()
# Executed in 0.04 second(s).
