# Narrative
# --------
# Using ..ST() and ..STD() extension
#
# Extracted from stzStringTest.ring, block #317.
#ERR Error (R14) : Calling Method without definition: findnthst

load "../../stzBase.ring"


pr()

#                     3    8    3
o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")

# Spacifying the starting prosition with the S extension
? o1.FindNthST(2, "♥♥♥", :StartingAt = 3)
#--> 8

? o1.FindFirstST("♥♥♥", :StartingAt = 5)
#--> 8

? o1.FindLastST("♥♥♥", :StartingAt = 6)
#--> 13

#--- Spacifying the direction with SD extension

? o1.FindNthSTD(2, "♥♥♥", :StartingAt = 10, :Going = :Backward)
#--> 3

? o1.FindFirstSTD("♥♥♥", :StartingAt = 14, :Backward)
#--> 8

? o1.FindLastSTD("♥♥♥", :StartingAt = 6, :Direction = :Backward)
#--> 3

pf()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.15 second(s) in Ring 1.17
