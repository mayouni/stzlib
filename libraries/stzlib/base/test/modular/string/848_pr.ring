# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #848.

load "../../../stzBase.ring"


o1 = new stzString("01234567")
? o1.IsMadeOfSome( OctalChars() )
#--> TRUE

o1 = new stzString("001100101")
? o1.IsMadeOf( BinaryChars() )
#--> TRUE

pf()
# Executed in 0.01 second(s).
