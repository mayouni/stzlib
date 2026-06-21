# Narrative
# --------
# Finding the "anti-sections" of a list: the position ranges that fall OUTSIDE
# a given set of sections.
#
# Given the list A..J (positions 1..10) and the sections [3,5] and [7,8],
# FindAntiSections returns the strict gaps between/around them as [start,end]
# pairs: [[1,2],[6,6],[9,10]] -- everything not covered by the input sections.
# The IB ("Inclusive of Bounds") variant overlaps the section boundaries by one
# position on each side, yielding [[1,3],[5,7],[8,10]] so each anti-section
# touches its neighbouring sections. This is the complement idiom for section
# math, useful when you want to operate on the leftover slices of a list.
#
# Extracted from stzlisttest.ring, block #319.

load "../../stzBase.ring"

pr()

o1 = new stzList("A":"J")

? @@( o1.FindAntiSections( :Of = [ [3,5], [7,8] ]) )
#--> [ [ 1, 2 ], [ 6, 6 ], [ 9, 10 ] ]

? @@( o1.FindAntiSectionsIB( :Of = [ [3,5], [7,8] ]) )
#--> [ [ 1, 3 ], [ 5, 7 ], [ 8, 10 ] ]

pf()
# Executed in 0.03 second(s).
