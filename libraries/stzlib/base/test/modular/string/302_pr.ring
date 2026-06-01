# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #302.

load "../../../stzBase.ring"


o1 = new stzString("r  in  g language is like a r  ing at your fingertips!")

acSubStrXT =  o1.SubStringsBoundedByIBZZ([ "r","g" ])
? @@SP(acSubStrXT) + NL
#--> [
#	[ "r in g", [  1, 8  ] ],
#	[ "r ing",  [ 29, 34 ] ],
#	[ "r fing", [ 42, 47 ] ]
# ]


oHashList = QRT(acSubStrXT, :stzHashList)
acWithoutSpaces = oHashList.KeysQRT(:stzListOfStrings).WithoutSapces()
? @@(acWithoutSpaces) + NL
#-->  [ "ring", "ring", "rfing" ]

aSectionsPos = Q(acWithoutSpaces).FindW('This[@i] = "ring"')
? @@(aSectionsPos)
#--> [1, 2]

aSections = oHashList.ValuesQ().ItemsAtPositions(aSectionsPos)
? @@(aSections) + NL
#--> [ [ 1, 8 ], [ 29, 34 ] ]

o1.RemoveSpacesInSections(aSections)
? o1.Content()
# ring language is like a ring at your fingertips!

pf()
# Executed in 0.07 second(s) in Ring 1.22
# Executed in 0.12 second(s) in Ring 1.21
