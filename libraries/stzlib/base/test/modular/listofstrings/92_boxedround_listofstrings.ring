# Narrative
# --------
# BoxedRound on a stzListOfStrings draws one round-corner box
# per string. Each box auto-sizes to its content.
#
# Extracted from stzlistofstringstest.ring, the per-string round-
# corner box block.

load "../../../stzBase.ring"


o1 = new stzListOfStrings([ "CAIRO", "TUNIS", "PARIS" ])
? o1.BoxedRound()

#--> 	╭───────╮
#	│ CAIRO │
# 	╰───────╯
# 	╭───────╮
# 	│ TUNIS │
# 	╰───────╯
# 	╭───────╮
# 	│ PARIS │
# 	╰───────╯
