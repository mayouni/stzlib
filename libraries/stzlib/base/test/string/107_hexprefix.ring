# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #107.

load "../../stzBase.ring"

pr()

? HexPrefix()
#--> Ox

? Q( HexPrefix() + '066E').RepresentsNumberInHexForm()
#--> TRUE

? Q('U+066E').RepresentsNumberInUnicodeHexForm()
#--> TRUE

pf()
