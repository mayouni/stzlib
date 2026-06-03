# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #150.

load "../../stzBase.ring"


o1 = new stzString("abCDE")

? o1.First2Chars()
#--> [ "a", "b" ]

? o1.First2CharsAsString() + NL
#--> "ab"

? o1.Last3Chars()
#--> [ "C", "D", "E" ]

? o1.Last3CharsAsString() + NL
#--> "CDE"

? o1.Next3Chars(:StartingAt = 2)
#--> [ "C", "D", "E" ]

? o1.Next3CharsAsString(:StartingAt = 2)
#--> "CDE"

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.07 second(s) in Ring 1.18
