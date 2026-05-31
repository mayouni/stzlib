# Narrative
# --------
# pr()
#
# Extracted from stzhexnumbertTest.ring, block #10.

load "../../../stzBase.ring"


? HexPrefixes()
#--> [ "x", "0x", "U+" ]

? StzStringQ("x167A").RepresentsNumberInHexForm()
#--> TRUE

? HexToDecimal("x167A")
#--> 5754

pf()
# Executed in 0.02 second(s).
