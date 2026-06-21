# Narrative
# --------
# Detecting and resolving duplicate items in a stzList.
#
# Starting from [ 5, 7, 5, 5, 4, 7 ], Softanza answers the full
# family of duplicate questions: ContainsDuplicates() is a yes/no
# guard, HowManyDuplicates() counts the redundant occurrences (3:
# two extra 5s and one extra 7), and FindDuplicates() returns the
# POSITIONS of those redundant occurrences ([ 3, 4, 6 ]) rather
# than the values. DuplicatesZ() (alias DuplicatesAndTheirPositions)
# pairs each repeated value with the positions of its repeats, and
# RemoveDuplicates() collapses the list in place to its first-seen
# order [ 5, 7, 4 ].
#
# Extracted from stzlisttest.ring, block #243.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 5, 7, 5, 5, 4, 7 ])

? o1.ContainsDuplicates()
#--> TRUE
# Executed in 0.03 second(s)

? o1.HowManyDuplicates()
#--> 3
# Executed in 0.03 second(s)

? @@( o1.FindDuplicates() )
#--> [ 3, 4, 6 ]
# Executed in 0.03 second(s)

? @@( o1.DuplicatesZ() ) # Or DuplicatesAndTheirPositions()
#--> [ [ 5, [ 3, 4 ] ], [ 7, [ 6 ] ] ]

#~> the number 5 is duplicated at positions 3 and 4
#~> the number 7 is duplicated at position 6.

# Executed in 0.25 second(s)

o1.RemoveDuplicates()
? @@( o1.Content() )
#--> [ 5, 7, 4 ]

# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.18

pf()
# Executed in 0.54 second(s)
