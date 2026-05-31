# Narrative
# --------
# pr()
#
# Extracted from stzhexnumbertTest.ring, block #12.

load "../../../stzBase.ring"


? IsUnicodeHex("U+214B")
#--> TRUE

? StringRepresentsNumberInHexform("xE82")
#--> TRUE

o1 = new stzHexNumber("xE82")
? o1.Content()
#--> E82

pf()
# Executed in 0.02 second(s).
