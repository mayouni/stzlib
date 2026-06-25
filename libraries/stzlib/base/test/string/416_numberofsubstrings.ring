# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #416.

load "../../stzBase.ring"

pr()

o1 = new stzString("*#!ABC$^..")
? o1.NumberOfSubStrings()
#--> 55

# Complex predicate (IsMadeOfLetters not in the engine W-DSL) -> the WF form:
? @@( o1.SubStringsWF( func s { return Q(s).IsMadeOfLetters() } ) )
#--> [ "A", "AB", "ABC", "B", "BC", "C" ]

pf()
# Executed in 0.58 second(s) in Ring 1.22
# Executed in 0.99 second(s) in Ring 1.19
