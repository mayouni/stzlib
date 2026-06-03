# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #325.

load "../../stzBase.ring"


o1 = new stzList(
[ "1", "1", [ "2", "♥", "2"], "1", [ "2", ["3", "♥", ["4", [ "5", "♥" ], "4", ["5","♥"], "♥"], "3"] ] ])

? o1.NumberOfLevels()
#--> 5

? @@( o1.DeepFind("♥") )
#--> [ [ 2, 2 ], [ 3, 2 ], [ 5, 2 ], [ 5, 2 ], [ 4, 3 ] ]

StopProfiler()
# Executed in 0.09 second(s) in Ring 1.22
