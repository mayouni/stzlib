# Narrative
# --------
# #narration
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
# Softanza provides an elegant solution by wrapping Ring's native functions
# with enhanced versions that offer consistent behavior. Take ring_sort()
# for example:

# Using the wrapped function:
aList = [ 4, 3, 5, 2, 1 ]
ring_sort(aList)

# The list is modified in place:
? @@( aList )
#--> [ 1, 2, 3, 4, 5 ]

# And simultaneously returns the sorted list:
? @@( ring_sort([ 4, 3, 5, 2, 1 ]) )
#--> [ 1, 2, 3, 4, 5 ]

# This unified behavior eliminates cognitive overhead, allowing you to use
# Ring functions seamlessly within your workflow.

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.02 second(s) in Ring 1.19
