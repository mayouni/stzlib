# Narrative
# --------
# Slicing a fixed-size window of N items forward or backward from an anchor.
#
# NextNItems(n, :StartingAtPosition = p) returns the n items beginning at
# position p and moving toward the tail. PreviousNItems(n, :StartingAtPosition = p)
# returns the n items ending at position p and moving toward the head. Here both
# carve the same [ 4, 5, 6 ] core out of a list padded with "." sentinels: the
# forward call starts at position 3 (the 4), and the backward call ends at
# position 7 (the 6), so the windows coincide. This is the directional
# counterpart to plain positional slicing, letting you grab a run relative to a
# landmark without computing both endpoints yourself.
#
# Extracted from stzlisttest.ring, block #331.

load "../../stzBase.ring"

pr()

o1 = new stzList([ ".",".",".",4 ,5 ,6 ,".",".","." ])
? o1.NextNItems(3, :StartingAtPosition = 3)
#--> [ 4, 5, 6 ]

? o1.PreviousNItems(3, :StartingAtPosition = 7)
#--> [ 4, 5, 6 ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
