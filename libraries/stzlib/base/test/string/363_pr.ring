# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #363.

load "../../stzBase.ring"


o1 = new stzString("...♥^♥.|.♥^♥...")

? @@( o1.SplitAround("♥^♥") )
#--> [ "...", ".|.", "..." ]

? @@( o1.SplitAroundIB("♥^♥") )
#--> [ "...♥", "♥.|.♥", "♥..." ]

#--

? @@( o1.SplitAroundPosition(8) )
#--> [ "...♥^♥.", ".♥^♥..." ]

? @@( o1.SplitAroundPositions([ 5, 8, 11 ]) )
#--> [ "...♥", "♥.", ".♥", "♥..." ]

? @@( o1.SplitAroundSection(5, 11) )
#--> [ "...♥", "♥..." ]

? @@( o1.SplitAroundSectionIB(5, 11) )
#--> [ "...♥^", "^♥..." ]

? @@( o1.SplitAroundSections( o1.FindZZ("♥^♥") ) )
#--> [ "...", ".|.", "..." ]

? @@( o1.SplitAroundSectionsIB( o1.FindZZ("♥^♥") ) )
#--> [ "...♥", "♥.|.♥", "♥..." ]

? @@( o1.SplitAroundSubString("♥^♥") )
#--> [ "...", ".|.", "..." ]

? @@( o1.SplitAroundSubStringIB("♥^♥") )
#--> [ "...♥", "♥.|.♥", "♥..." ]

? @@( o1.SplitAroundSubStrings([ "♥^♥.", ".♥^♥" ]) )
#--> [ "..", "|", ".." ]

? @@( o1.SplitAroundSubStringsIB([ "♥^♥.", ".♥^♥" ]) )
#--> [ "...", ".|.", "..." ]

pf()
# Executed in 0.11 second(s) in Ring 1.21
