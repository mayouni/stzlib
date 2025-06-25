load "../stzmax.ring"

# These functions are used by stzList for manageing nested lists

/*---

pr()

cNestedList = "[1,[2,3],[4,5,[6,7]]]"
? @@NL( GenPaths(cNestedList) )
#--> [
#	[ 1 ],
#	[ 2 ],
#	[ 2, 1 ],
#	[ 2, 2 ],
#	[ 3 ],
#	[ 3, 1 ],
#	[ 3, 2 ],
#	[ 3, 3 ],
#	[ 3, 3, 1 ],
#	[ 3, 3, 2 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

? @@( PathsIn([2, 3, 2]) )
#--> [ [ 2 ], [ 2, 3 ], [ 2, 3, 2 ] ]

pf()

/*---

pr()

? @@( NthPathIn(1, [2, 3, 2]) )
#--> [ 2 ]

? @@( NthPathIn(2, [2, 3, 2]) )
#--> [ 2, 3 ]

? @@( NthPathIn(3, [2, 3, 2]) )
#--> [ 2, 3, 2 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

? @@( LastPathIn([2, 3, 2]) )
#--> [ 2, 3, 2 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

aPaths = [ [1], [1, 2], [1, 2, 3], [4], [4, 5] ]

? @@( ReducePaths(aPaths) )
#--> [ [ 1 ], [ 4 ] ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

aUnsorted = [ [4], [2, 3], [1, 5], [2, 1], [3, 2, 1]] 

? @@NL( SortPaths(aUnsorted) )
#--> [
#	[ 1, 5 ],
#	[ 2, 1 ],
#	[ 2, 3 ],
#	[ 3, 2, 1 ],
#	[ 4 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

? PathIsGreaterThan([4], [3, 1, 2])
#--> TRUE

? PathIsGreaterThan([2, 2], [2, 1])
#--> TRUE

? PathIsGreaterThan([1, 2], [1, 2, 3])
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

? IsSubPathOf([2, 1], [2, 1, 3])
#--> TRUE

? IsSubPathOf([2, 1], [2, 2])
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

aPathSet = [[1, 2, 3, 4], [1, 2, 5], [1, 2, 6, 7]]
? @@( CommonPath(aPathSet) )
#--> [ 1, 2 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

? @@( PathsSection([2], [2, 3, 1]) )
#--> [ [ 2 ], [ 2, 3 ], [ 2, 3, 1 ] ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

aPathCollection = [[1], [2, 3], [1, 2, 3], [4, 5]]
? @@( DeepestPath(aPathCollection) )
#--> [ 4, 5 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

? IsTree([1, 2, 3])
#--> TRUE

? IsTree([ 1, 2, [ 2, 1 ], 3 ])
#--> TRUE

? IsTree([1, [2, 3], [4, [5, 6]]])
#--> TRUE

pf()

#===

pr()

aPaths = [ [1], [1, 2], [1, 2, 3], [4], [4, 5], [3, 2, 1] ]

? @@( LargestPath(aPaths) )
#--> [ 4, 5 ]

? @@( SmallestPath(aPaths) )
#--> [ 1 ]

? @@( LongestPath(aPaths) )
#--> [ 1, 2, 3 ]

? @@( ShortestPath(aPaths) )
#--> [ 1 ]

? @@( PathsWithDepth(aPaths, 2) )
#--> [ [ 1, 2 ], [ 4, 5 ] ]

? @@( SuperPathsOf(aPaths, [1]) )
#--> [ [ 1, 2 ], [ 1, 2, 3 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
