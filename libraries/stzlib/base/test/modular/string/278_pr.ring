# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #278.

load "../../../stzBase.ring"


? Q( :Step = [ 3, :Andthen = 2 ] ).IsStepNamedParam()
#--> 1

? Q( :Step = [ 3, :Andthen = 2 ] ).IsOneOfTheseNamedParams([ :Step, :Stepping, :EachNChars ])
#--> 1

pf()
# Executed in 0.01 second(s).
