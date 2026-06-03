# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #40.

load "../../stzBase.ring"


o1 = new stzList([ "ring", "php", "ring", "ruby", "ring", "python", "ring", "csharp", "ring" ])
o1.ReplaceAnyItemAtPositionsByManyXT([ 3, 5, 7, 9], [ "♥", "♥♥" ])

? o1.Content()
#--> [ "ring", "php", "♥", "ruby", "♥♥", "python", "♥", "csharp", "♥♥" ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
