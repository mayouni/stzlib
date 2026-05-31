# Narrative
# --------
# pr()
#
# Extracted from stzlistofbytestest.ring, block #5.

load "../../../stzBase.ring"


oQByteArray = new QByteArray()
oQByteArray.append("RING")

? @@( QByteArrayToListOfBytecodes(oQByteArray) ) + NL
#--> [ 82, 73, 78, 71 ]

? @@( QByteArrayToListOfChars(oQByteArray) ) + NL
#--> [ "R", "I", "N", "G" ]

? @@( QByteArrayToListOfUnicodesPerChar(oQByteArray) )
#--> [ [ "R", [ 82 ] ], [ "I", [ 73 ] ], [ "N", [ 78 ] ], [ "G", [ 71 ] ] ]

pf()
#--> Executed in 0.08 second(s)
