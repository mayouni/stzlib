# Narrative
# --------
# RemoveAllExcept keeps only the listed tokens ("Ring", "&", "Softanza") and drops
# everything else, leaving "Ring&Softanza".
#
# Extracted from stzStringTest.ring, block #78.

load "../../stzBase.ring"

pr()

o1 = new stzString("--Ring--&__Softanza__")
o1.RemoveAllExcept([ "Ring", "&", "Softanza" ])
? o1.Content()
#--> Ring&Softanza

pf()
