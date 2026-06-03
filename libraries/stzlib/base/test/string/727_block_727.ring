# Narrative
# --------
# #TODO
#
# Extracted from stzStringTest.ring, block #727.

load "../../stzBase.ring"


pr()

o1 = new stzString("Ring Programming Language")
? o1.WalkBackwardW( :StartingAt = 12, :UntilBefore = '{ @char = " " }' ) #--> 5
? o1.WalkForwardW( :StartingAt =  6, :UntilBefore = '{ @char = "r" }' ) #--> 9

pf()
