# Narrative
# --------
# Find the gaps left over when a list is carved into sections.
#
# Given the 10-item list A..J and two covered sections [3,5] and [7,8],
# FindAntiSections returns the position-range complements -- the bands the
# sections do NOT touch: [1,2], the single index [6,6], and [9,10].
# AntiSections is the value-returning twin: it materialises those same gaps
# as actual sublists, ["A","B"], ["F"], ["I","J"]. Together they let you ask
# "what is left between my chosen slices?" in either index or value form.
#
# Extracted from stzlisttest.ring, block #262.

load "../../stzBase.ring"

pr()

o1 = new stzList("A":"J")

? @@( o1.FindAntiSections( :Of = [ [3, 5], [7, 8] ] ) )
#--> [ [ 1, 2 ], [ 6, 6 ], [ 9, 10 ] ]

? @@( o1.AntiSections(:Of = [ [3, 5], [7, 8] ] ) )
#--> [ ["A", "B"], ["F"], ["I", "J"] ]

pf()
# Executed in 0.07 second(s)
