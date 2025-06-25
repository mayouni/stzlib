load "../stzmax.ring"


/*--- Basic Operations

pr()
       
w1 = new stzWalker(2, 12, 2)
? @@( w1.Walkables() )
#--> [ 2, 4, 6, 8, 10, 12 ]

w2 = new stzWalker(1, 10, 3)
? @@( w2.Walkables() )
#--> [ 1, 4, 7, 10 ]

w3 = new stzWalker(4, 12, 6)
? @@( w3.Walkables() ) + NL
#--> [ 4, 10 ]

#--

o1 = new stzListOfWalkers([w1, w2, w3])
    
# Number of walkers
? o1.Size()
    
# Walkables of first walker
? @@( o1.FirstWalker().Walkables() )
#--> [2, 4, 6, 8, 10, 12]

# Common walkables across all walkers
? @@( o1.CommonWalkables() )
#--> [4, 10]

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Finding the smallest and largest walkers

pr()

w1 = new stzWalker(2, 12, 2)
w2 = new stzWalker(1, 10, 3)
w3 = new stzWalker(4, 12, 6)

o1 = new stzListOfWalkers([w1, w2, w3])

? @@( o1.SmallestWalker().Walkables() )
#--> [ 4, 10 ]

? @@( o1.LargestWalker().Walkables() )
#--> [ 2, 4, 6, 8, 10, 12 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Merging walkables

pr()

w1 = new stzWalker(2, 12, 2)
w2 = new stzWalker(1, 10, 3)
w3 = new stzWalker(4, 12, 6)

o1 = new stzListOfWalkers([w1, w2, w3])

? @@( o1.MergeWalkables())
#--> [ 1, 2, 4, 6, 7, 8, 10, 12 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Balk walking operations

pr()

w1 = new stzWalker(2, 12, 2)
w2 = new stzWalker(1, 10, 3)
w3 = new stzWalker(4, 12, 6)

o1 = new stzListOfWalkers([w1, w2, w3])
? @@NL( o1.Walkables() ) + NL
#--> [
#	[ 2, 4, 6, 8, 10, 12 ],
#	[ 1, 4, 7, 10 ],
#	[ 4, 10 ]
# ]

? @@( o1.CurrentPositions() )
#--> [ 2, 1, 4 ]

# Walking all walkers one step from current position

o1.WalkAllNSteps(1)
? @@NL( o1.CurrentPositions() )
#--> [ 4, 4, 10 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Advanced walking strategies

pr()
    
wa = new stzWalker(1, 10, 1)
? @@(wa.Walkables())
#--> [ 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

wb = new stzWalker(1, 25, 4)
? @@(wb.Walkables())
#--> [ 5, 10, 15, 20, 25 ]

wc = new stzWalker(3, 15, 2)
? @@(wc.Walkables())
#--> [ 3, 5, 7, 9, 11, 13, 15 ]

o1 = new stzListOfWalkers([ wa, wb, wc ])

? @@( o1.CommonWalkables() )
#--> [ 5, 9 ]

? @@( o1.CurrentPositions() )
#--> [ 1, 1, 3 ]

# Synchronizing all the walkers at position 5

o1.WalkToPosition(5)
? @@( o1.CurrentPositions() )
#--> [ 5, 5, 5 ]

o1.WalkNSteps(3)
? @@( o1.CurrentPositions() )
#--> [ 8, 17, 11 ]

# Reset them at their respective first positions

o1.Restart()
? @@( o1.CurrentPositions() )
#--> [ 1, 1, 3 ]
    
# Walk all walkers 2 steps from current position

o1.WalkAllNSteps(2)
? @@( o1.CurrentPositions() )
#--> [ 3, 9, 7 ]

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*--- FINDING PATHS
*/
pr()

o1 = new stzListOfWalkers([
	Wk(1, 10, 2),
	Wk(2, 12, 2),
	Wk(4, 14, 2)
])

# In the planned walkables positions, let's find
# where the path [ 8, 10, 12 ] will be walked through

? @@NL( o1.Walkables() )
#--> [
#	[ 1, 3, 5, 7, 9 ],
#	[ 2, 4, 6, 8, 10, 12 ],
#	[ 4, 6, 8, 10, 12, 14 ]
# ]

# Result : sencond and third walkers

? @@( o1.FindWalkablePath([ 8, 10, 12 ]) )
#--> [ 2, 3 ]

# Now let's try to find the same path in the already walked history

? @@( o1.FindWalkedPath([ 8, 10, 12 ]) )
#--> [ ]

# Returned nothing! Why?
# Well, it's because the walkers did not move yet:

? @@( o1.History() )
#--> [ [ ], [ ], [ ] ]

# So let's instruct them to commit some steps

o1.WalkNSteps(3)
? @@NL( o1.History() )
#--> [
#	[ 1, 3, 5, 7  ],
#	[ 2, 4, 6, 8  ],
#	[ 4, 6, 8, 10 ]
# ]

# Now we can make our search of, say, the path [6, 8 ] in
# the walkable positions space:

? @@( o1.FindWalkedPath([ 6, 8 ]) )
#--> [ 2, 3 ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
