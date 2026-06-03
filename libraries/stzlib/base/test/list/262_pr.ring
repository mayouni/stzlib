# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #262.

load "../../stzBase.ring"


o1 = new stzList("A":"J")

? @@( o1.FindAntiSections( :Of = [ [3, 5], [7, 8] ] ) )
#--> [ [ 1, 2 ], [ 6, 6 ], [ 9, 10 ] ]

? @@( o1.AntiSections(:Of = [ [3, 5], [7, 8] ] ) )
#--> [ ["A", "B"], ["F"], ["I", "J"] ]

pf()
# Executed in 0.07 second(s)
