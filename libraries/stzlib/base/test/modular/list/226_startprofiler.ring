# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #226.

load "../../../stzBase.ring"


o1 = new stzList([ 1, 2, "♥", 3, "*", 4, "_" ])

? o1.ExtractWXT('{ NOT isNumber(@item) }')
#--> [ "♥", "*", "_" ]

? o1.Content()
#--> [ 1, 2, 3, 4 ]

StopProfiler()
# Executed in 0.13 second(s) in Ring 1.21
# Executed in 0.44 second(s) in Ring 1.20
