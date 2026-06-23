# Narrative
# --------
# Contrasts in-place sorting against copy-returning sorting across the
# Ring and Softanza idioms, clearing up the perennial "does sort() mutate
# or return?" uncertainty.
#
# stzList.Sort() mutates the list in place (verified via Show()), while
# Q([...]).Sorted() leaves the source untouched and hands back a sorted
# copy -- the passive-voice name signals the non-mutating intent. Ring's
# ring_sort() returns a freshly sorted list as its value, so chaining it
# inline yields the sorted result; note, however, that calling it as a
# bare statement does NOT modify its argument in place -- aList stays in
# its original order, which is why the fourth check prints the unsorted
# [ 4, 3, 5, 2, 1 ].
#
# Extracted from stzlisttest.ring, block #136.

load "../../stzBase.ring"


pr()

# A Common Programming Dilemma:
# When working with Ring sort() function, there's often a moment of uncertainty:
# Does it modify the list in place, or does it return a new sorted list?
# This uncertainty typically leads to writing test cases for verification...

alist = [ 4, 3, 1 , 2, 5 ]
alist = ring_sort(alist)

? @@(alist)
#--> [ 1, 2, 3, 4, 5 ]

# Softanza's Solution: Crystal-Clear Mental Models
# When you want to modify the list in place, the syntax is explicit:

o1 = new stzList([ 4, 3, 1 , 2, 5 ])
o1.Sort()
# The list is now sorted in place, and you can verify it:
o1.Show()
#--> [ 1, 2, 3, 4, 5 ]

# Need a sorted copy instead? The passive voice syntax makes it intuitive:

aSorted = Q([ 4, 3, 1 , 2, 5 ]).Sorted()
? @@(aSorted)
#--> [ 1, 2, 3, 4, 5 ]

# Bridging Ring and Softanza:
# A common gotcha: calling ring_sort() as a BARE statement does NOT sort
# the list in place -- Ring's ring_sort returns the sorted list as a value,
# leaving its argument untouched. Take ring_sort() for example:

aList = [ 4, 3, 5, 2, 1 ]
ring_sort(aList)

# aList is unchanged -- the returned (sorted) value was discarded:
? @@( aList )
#--> [ 4, 3, 5, 2, 1 ]

# And simultaneously returns the sorted list:
? @@( ring_sort([ 4, 3, 5, 2, 1 ]) )
#--> [ 1, 2, 3, 4, 5 ]

# This unified behavior eliminates cognitive overhead, allowing you to use
# Ring functions seamlessly within your workflow.

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.19
