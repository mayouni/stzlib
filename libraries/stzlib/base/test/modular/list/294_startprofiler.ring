# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #294.

load "../../../stzBase.ring"


o1 = new stzString( '[ "1", "1", [ "2", "♥", "2"], "1", [ "2", ["3", "♥"] ] ]' )

? o1.FindPreviousNthOccurrence(1, :Of = "[", :StartingAt = 21)
#--> 13
? o1.FindNextNthOccurrence(1, :Of = "]", :StartingAt = 21)
#--> 28

? o1.FindFirstPrevious("[", :StartingAt = 21)
#--> 13
? o1.FindFirstNext(:Of = "]", :StartingAt = 21)
#--> 28

StopProfiler()
#--> Executed in 0.01 second(s)
