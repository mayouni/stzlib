# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #398.

load "../../stzBase.ring"

pr()

o1 = new stzString("abAb")

? o1.NumberOfSubStrings()
#--> 10
# Executed in 0.02 second(s)

? @@( o1.SubStrings() )
#--> [ "a", "ab", "abA", "abAb", "b", "bA", "bAb", "A", "Ab", "b" ]
# Executed in 0.04 second(s)

? o1.NumberOfSubStringsCS(FALSE)
#--> 7
# Executed in 0.12 second(s)

? @@( o1.SubStringsCS(FALSE) )
#--> [ "a", "ab", "abA", "abAb", "b", "bA", "bAb" ]
# Executed in 0.12 second(s)

pf()
#--> Executed in 0.27 second(s)
