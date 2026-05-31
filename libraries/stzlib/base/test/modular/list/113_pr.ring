# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #113.

load "../../../stzBase.ring"


o1 = new stzList([ "ee♥ee", "b♥bbb", "ccc♥", "♥♥" ])
? o1.EachContains("♥")
#--> TRUE

o1 = new stzList([ ["ee","♥","ee"], ["♥", "bb"], "ccc♥", "♥♥" ])
? o1.EachContains("♥")
#--> TRUE

o1 = new stzList([ "a♥a" ])
? o1.EachContains("♥")
#--> TRUE

o1 = new stzList([ 0, "a♥a" ])
? o1.EachContains("♥")
#--> FALSE

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.04 second(s) in Ring 1.19
