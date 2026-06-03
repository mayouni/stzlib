# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #836.

load "../../stzBase.ring"


# You can use the simple form of InsertSubStrings() without ..XT and
# get default configurations that works:

o1 = new stzString("All our software versions must be updated!")
o1.InsertSubStrings( o1.PositionAfter("versions"), [ "V1", "V2", "V3" ])
? o1.Content()
#--> All our software versions (V1, V2, V3)  must be updated!

pf()
# Executed in 0.01 second(s).
