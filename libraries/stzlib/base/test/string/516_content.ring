# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #516.
#ERR Error (R14) : Calling Method without definition: move

load "../../stzBase.ring"

pr()

o1 = new stzString("ACB")
o1.Move( :CharFromPosition = 3, :To = 2 )
? o1.Content()
#--> "ABC"

o1.Swap( :Positions = 2, :And = 3 )
? o1.Content()
#--> "ACB"

pf()
# Executed in 0.08 second(s) in Ring 1.22
