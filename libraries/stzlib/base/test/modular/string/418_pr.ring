# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #418.

load "../../../stzBase.ring"


o1 = new stzString("...456...")

? o1.NextNChars(3, :StartingAt = 3)
#--> [ "4", "5", "6" ]

? o1.PreviousNChars(3, :StartingAtPosition = 7)
#--> [ "4", "5", "6" ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
