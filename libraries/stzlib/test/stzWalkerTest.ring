load "../max/stzmax.ring"


/*--

pr()

o1 = new stzWalker( 1, 10, 2 )

o1 {

	? NumberOfPositions()
	#--> 10

	? StartPosition()
	#--> 1
	? EndPosition()
	#--> 10
	? NStep() + NL
	#--> 2	

	? @@( Positions() )
	#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

	? @@( WalkablePositions() ) # Or Walkables()
	#--> [ 1, 3, 5, 7, 9 ]

	? @@(Unwalkables()) + NL # Or UnwalkablePositions
	#--> [ 2, 4, 6, 8, 10 ]

	? CurrentPosition() # Or Position()
	#--> 1

}

pf()
# Executed in 0.02 second(s).

/*-------------------

pr()

o1 = new stzWalker(:Start = 1, :End = 10, :Step = 2)

o1 {

	? NumberOfPositions()
	#--> 10

	? StartPosition()
	#--> 1
	? EndPosition()
	#--> 10
	? NStep() + NL
	#--> 2	

	? @@( Positions() )
	#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

	? @@( WalkablePositions() )
	#--> [ 1, 3, 5, 7, 9 ]

	? @@( UnwalkablePositions() ) + NL
	#--> [ 2, 4, 6, 8, 10 ]

	? CurrentPosition()
	#--> 1
}

pf()
# Executed in 0.04 second(s).

/*===
*/
pr()

oWalker = new stzWalker( 5, -5, 2 )
? oWalker.Content()
#--> [ 5, 3, 1, -1, -3, -5 ]

pf()
# Executed in 0.01 second(s).

/*===

pr()

//oWalker = new stzWalker( :StartingAt = 1, :EndingAt = 8, :Step = 9 )
#--> Error: Can't walk! The step is larger then the number of walkable positions.

oWalker = new stzWalker( :StartingAt = 1, :EndingAt = 8, :Step = 0 )
#--> Error: Can't create the stzWalker object! pnStep must be strictly positive number..

pf()

/*====

pr()

oWalker = new stzWalker( 3, 9, 2 )
oWalker {

	? @@( Walkables() ) # Or WalkablePositions()
	#--> [ 3, 5, 7, 9 ]
	
	? @@( Walk() )
	#--> [ 3, 5 ]
	
	? Position() # Or CurrentPosition()
	#--> 5

	? @@( WalkN(2) )
	#--> [ 5, 7, 9 ]

	? Position()
	#--> 9

}

pf()
# Executed in 0.02 second(s).

/*----

pr()

oWalker = new stzWalker(1, 10, 2)

? oWalker.Position()
#--> 1

? oWalker.NumberOfSteps()
#--> 5

pf()
# Executed in 0.01 second(s).

/*----

pr()

oWalker = new stzWalker(1, 12, 2)
oWalker {

	? @@( Walkables())
	#--> [ 1, 3, 5, 7, 9, 11 ]
	
	? CurrentPosition()
	#--> 1
	
	? @@( WalkN(2) )
	#--> [ 1, 3, 5 ]
	
	? CurrentPosition()
	#--> 5

	? @@( RemainingWalkables())
	#--> [ 7, 9, 11 ]

	WalkN(2) # You can type ? to see the walked steps ~> [ 5, 7, 9 ]
	? CurrentPosition()
	#--> 9
	
	? @@( HowManyRemainingWalkables() )
	#--> 1
	
	? @@( RemainingWalkables() )
	#--> [ 11 ]

	? WalkN(1)
	#--> [ 9, 11 ]

	//Walk()
	#--> ERROR: Can't walk! No more walkable positions.

}

pf()
# Executed in 0.02 second(s).

/*----

pr()

oWalker = new stzWalker(12, 1, 2)
oWalker {

	? @@( Walkables())
	#--> [ 12, 10, 8, 6, 4, 2 ]
		
	? CurrentPosition() + NL
	#--> 12
	
	? @@( WalkN(2) )
	#--> [ 12, 10, 8 ]

	? CurrentPosition() + NL
	#--> 8

	? @@( RemainingWalkables())
	#--> [ 6, 4, 2 ]

	? NL + "--" + NL

	? @@( WalkN(2) )
	#--> [ 8, 6, 4 ]

	? CurrentPosition()
	#--> 4
	
	? HowManyRemainingWalkables()
	#--> 1
	
	? @@( RemainingWalkables() )
	#--> [ 2 ]

	? @@( WalkN(1) )
	#--> [ 4, 2 ]

	//Walk()
	#--> ERROR: Can't walk! No more walkable positions.
}

pf()
# Executed in 0.02 second(s).

/*===

pr()

w = new stzWalker(3, 12, 2)

? w.Position()
#--> 3

? @@( w.Walkables() )
#--> [ 3, 5, 7, 9, 11 ]

w.WalkNSteps(2) #--> Inspect it wit ? and you get [ 3, 5, 7 ]

? w.Position() + NL
#--> 7

//w.WalkTo(8)
#--> ERROR: Can't walk! The position(s) provided must be walkable.

w.WalkTo(5) #--> [ 7, 5 ]
? w.Position() + NL
#--> 5


? "--" + NL


? w.WalkToFirst()
#--> [ 5, 3 ]

? w.WalkToLast()
#--> [ 3, 5, 7, 9, 11 ]

? w.Position() + NL
#--> 11

? w.WalkBetween(5, 9)
#--> [ 5, 7, 9 ]

? w.Position() + NL
#--> 9

? w.WalkBetween(9, 5)
#--> [ 9, 7, 5 ]

? w.Position()
#--> 5

pf()
# Executed in 0.02 second(s).

/*====

pr()

oWalker = new stzWalker(1, 10, 2)

? @@( oWalker.Walkables() ) + NL
#--> [ 1, 3, 5, 7, 9 ]

? oWalker.Position() + NL
#--> 1

while oWalker.HasNext()
	oWalker.WalkN(1)
	? oWalker.Position()
end
#--> [ 3, 5, 7, 9 ]

pf()
# Executed in 0.01 second(s).

#---

pr()

w = new stzWalker(2, 9, 2)

? w.Walkables()
#--> [ 2, 4, 6, 8 ]

? w.WalkTo(4)
#--> [ 2, 4 ]

? w.Position() + NL
#--> 4

? w.WalkFromEnd()
#--> [ 8, 6, 4 ]

? w.WalkFromStart()
#--> [ 2, 4 ]

pf()
# Executed in 0.02 second(s).

#====
*/
pr()

w = new stzWalker(3, 10, 2)

w.Walk()
w.WalkBetween(7, 9)
w.WalkFromLast()

? @@NL( w.Walks() )
#--> [
#	[ 3, 5 ],
#	[ 7, 9 ],
#	[ 9 ]
# ]

? w.FirstWalk()
#--> [ 3, 5 ]

? w.NthWalk(2)
#--> [ 7, 9 ]

? w.LastWalk()
#--> [ 9 ]

w.RemoveWalks()
? w.HowManyWalks()
#--> 0

pf()
# Executed in 0.02 second(s).
