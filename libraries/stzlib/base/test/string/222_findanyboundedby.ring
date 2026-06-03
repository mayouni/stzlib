# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #222.

load "../../stzBase.ring"

pr()

#                   1  4 6  9 1   567      456
o1 = new stzString("...<<ring>>...<<softanza>>...")

? @@( o1.FindAnyBoundedBy(["<<",">>"]) )
#--> [6, 17]

? @@( o1.FindAnyBoundedByAsSections(["<<",">>"]) )
#--> [ [6, 9], [17, 24] ]

? @@( o1.AnyBoundedBy(["<<",">>"]) )
#--> ["ring", "softanza"]

? @@( o1.FindAnyBoundedByIB(["<<",">>"]) )
#--> [4, 15]

? @@( o1.FindAnyBoundedByAsSectionsIB(["<<",">>"]) )
#--> [ [4, 11], [15, 26] ]

? @@( o1.AnyBoundedByIB(["<<",">>"]) )
#--> ["<<ring>>", "<<softanza>>"]

pf()
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.25 second(s) in Ring 1.18
