load "stzlib.ring"



/*-------------------

pron()

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

proff()
# Executed in 0.02 second(s).

/*-------------------

pron()

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

proff()
# Executed in 0.02 second(s).

/*===

pron()

oWalker = new stzWalker( :StartingAt = 1, :EndingAt = 8, :Step = 9 )
#--> Error: Can't walk! The step is larger then the number of walkable positions.

proff()

/*====

pron()

oWalker = new stzWalker( 3, 9, 2 )
oWalker {

	Direction()
	#-- forward

	? @@( Walkables() ) # Or WalkablePositions()
	#--> [ 3, 5, 7, 9 ]
	
	? @@( Walk() )
	#--> [ 3, 5, 7, 9 ]
	
	? Position() # Or CurrentPosition()
	#--> 9

	TurnAround() # Or Turn()

	? Direction()
	#--> backward

	? @@( Walkables() )
	#--> [ 3, 5, 7, 9 ]

	? @@( Walk() ) # Walks starting from CurrentPosition() ~> 9
	#--> [ 9, 7, 5, 3 ]

	? Position()
	#--> 3
}

proff()
# Executed in 0.02 second(s).

/*----

pron()

oWalker = new stzWalker(1, 10, 2)

? oWalker.Position()
#--> 1

? oWalker.NumberOfSteps()
#--> 5

? oWalker.Position()
#--> 1

proff()
# Executed in 0.01 second(s).

/*----

pron()

oWalker = new stzWalker(1, 12, 2)
oWalker {

	? @@( Walkables())
	#--> [ 1, 3, 5, 7, 9, 11 ]
	
	? CurrentPosition()
	#--> 1
	
	? Direction()
	#--> Forward
	
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
	#--> 11

	//Walk()
	#--> ERROR: Can't walk! n exceeds the number of remaining walkable positions.

}

proff()
# Executed in 0.02 second(s).

/*----

pron()

oWalker = new stzWalker(12, 1, 2)
oWalker {

	? @@( Walkables())
	#--> [ 2, 4, 6, 8, 10, 12 ]
	
	? Direction()
	#--> Backward
	
	? CurrentPosition()
	#--> 12
	
	? @@( Remaining() )
	#--> [ 2, 4, 6, 8, 10 ]
	
	
	? @@( WalkN(2) )
	#--> [ 12, 10, 8 ]

	? CurrentPosition()
	#--> 8

	? @@( RemainingWalkables())
	#--> [ 2, 4, 6 ]

	? "--" + NL

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

proff()
# Executed in 0.02 second(s).

/*----
*/

pron()

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

proff()
