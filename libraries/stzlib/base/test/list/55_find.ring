# Narrative
# --------
# ReplaceByMany used as a "fill the blanks" idiom.
#
# The list has the placeholder symbol :♥ at positions 2,5,6 (confirmed by
# Find). ReplaceByMany(:♥, [2,5,6]) consumes the replacement list one entry
# per occurrence -- first :♥ -> 2, second -> 5, third -> 6 -- which here
# happens to complete the sequence 1..6. A neat demonstration that the
# replacements are assigned to occurrences in order (1-to-1, no cycling).
#
# Extracted from stzlisttest.ring, block #55.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, :♥, 3, 4, :♥, :♥ ])
anPos = o1.Find(:♥)
#--> [ 2, 5, 6 ]

o1.ReplaceByMany(:♥, [2, 5, 6])
? o1.Content()

#--> [ 1, 2, 3, 4, 5, 6 ]

pf()
# Executed in 0.04 second(s)
