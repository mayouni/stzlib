# Narrative
# --------
# # Testing FindNthNext()/FindNthPrevious
#
# Extracted from stzStringTest.ring, block #237.

load "../../../stzBase.ring"

# on a very large string (~2M chars)

StartProfiler()

o1 = new stzString( UnicodeDataAsString() ) # Contains 1_897_793 chars

? o1.FindNext("", :StartingAt = 1)
#--> 0

? o1.FindNext("ARABIC HA", :StartingAt = 1)
#--> 110819

? o1.FindNthNext(6, "ARABIC", :StartingAt = 3)
#--> 106564

? o1.FindNthNext(12, "HAN", :StartingAt = 250_000)
#--> 300643

? o1.FindPrevious("", :StartingAt = 9)
#--> 0

? o1.FindPrevious("x", :StartingAt = 2)
#--> 0

StopProfiler()
# Executed in 0.19 second(s) in Ring 1.21
