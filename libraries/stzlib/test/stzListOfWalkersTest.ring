load "../max/stzmax.ring"


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
# Executed in 0.01 second(s) in Ring 1.22

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
*/
pr()
    
wa = new stzWalker(1, 10, 1)
wb = new stzWalker(5, 25, 5)
wc = new stzWalker(3, 15, 2)

o1 = new stzListOfWalkers([ wa, wb, wc ])
? @@( o1.CommonWalkables() )
#--> [ 5 ]

? @@( o1.CurrentPositions() )
#--> [ 1, 5, 3 ]

o1.WalkToPosition(5)
? @@( o1.CurrentPositions() )

o1.Restart()
? @@( o1.CurrentPositions() )
    

    
# Walk all walkers 2 steps from current position

o1.WalkAllNSteps(2)
? @@( o1.CurrentPositions() )
    #--> Walk all walkers 2 steps from current position:
    #--> Final positions:
    #--> Walker 1 position: 10
    #--> Walker 2 position: 20
    #--> Walker 3 position: 15
    
pf()  # End performance measurement


