
load "../max/stzmax.ring"

/*----

profon()

o1 = new stzListOfSections([
	[ 1, 4], [6, 8], [9, 10], [12, 13], [13, 15]
])

o1.MergeContiguous() # Or MergeAdjuscent()
? @@( o1.Content() )
#--> [ [1, 4], [6, 10], [12, 15] ]

proff()
# Executed in 0.03 second(s)

/*------------------

profon()

aSections = [ [ 4, 5 ], [ 8, 9 ], [ 10, 11 ], [ 14, 15 ], [ 16, 17 ], [ 18, 19 ], [ 22, 23 ] ]

o1 = new stzListOfSections(aSections)
o1.MergeContiguous()

? @@( o1.Content() )
#--> [ [ 4, 5 ], [ 8, 11 ], [ 14, 19 ], [ 22, 23 ] ]

proff()
# Executed in 0.03 second(s) in Ring 1.22
