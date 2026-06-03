# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #854.

load "../../stzBase.ring"


o1 = new stzString("abcbbaccbtttx")
? @@( o1.UniqueChars() )
#--> [ "a", "b", "c", "t", "x" ]

? o1.ContainsNOccurrences(2, :Of = "a")
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.22
