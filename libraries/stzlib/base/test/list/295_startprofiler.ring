# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #295.

load "../../stzBase.ring"


o1 = new stzList(["__", "♥", "_", "__", "♥", "♥", "__", "♥" ])
? o1.NumberOfOccurrence("♥") #NOTE that this is a misspelled form (lacks an "r")
			    # but Softanza is kind to accept it
#--> 4

o1 = new stzList(["__", 1:3, "_", "__", 1:3, 1:3, "__", 1:3 ])
? o1.NumberOfOccurrence(1:3)
#--> 4

StopProfiler()
# Executed in 0.02 second(s)
