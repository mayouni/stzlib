# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #62.

load "../../../stzBase.ring"


o1 = new stzString("[4, 5, 6, 7, 8]")

? @@(o1.RepeatedLeadingChars())
#--> []

? o1.ContainsLeadingAndTrailingChars()
#--> FALSE

? o1.FirstAndLastChars()
#--> [ "[", "]" ]

? o1.Bounds()
#--> [ "[", "]" ]


? @@( o1.FindTheseBoundsAsSections("[[", "]") )
#--> [ ]

? o1.FindTheseBoundsAsSections("[", "]")
#--> [ [ 1, 1 ], [ 15, 15 ] ]

o1.RemoveTheseBounds("[","]")
? o1.Content()
#--> "4, 5, 6, 7, 8"

pf()
# Executed in 0.06 second(s) in Ring 1.21
