load "stzlib.ring"



/*-------------------

pron()

o1 = new stzWalker([ 1, 10, 2 ])

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
*/
pron()

o1 = new stzWalker([
	:Start = 1,
	:End = 10,
	:Jump = 2
])

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
	#--> [ 10, 8, 6, 4, 2 ]

	? @@( UnwalkablePositions() ) + NL
	#--> [ 1, 3, 5, 7, 9 ]

	? CurrentPosition()
	#--> 10
}

proff()
# Executed in 0.02 second(s).

/*===

pron()

oWalker = new stzWalker([ :StartingAt = 1, :EndingAt = 8, :Jump = 9 ])
#--> Error: Can't walk! The step is larger then the number of walkable items.

proff()

/*---

pron()

oWalker = new stzWalker([])
#--> Error: Can not create the stzWalker object! paWalkerOptions can not be an empty list.

proff()

/*---

pron()

oWalker = new stzWalker([ :w1, 3, 8, 2 ])

/*---

pron()

oWalker = new stzWalker([ :w1, 3, 8, 2 ])
#--> Can't create the stzWalker object! paWalkerOptions must be a list of 3 items or a hashlist of 4 pairs or less.

proff()

/*====

? oWalker.Direction()
#-- forward

? @@( oWalker.Walkables() ) # Or WalkablePositions()
#--> [ 3, 5, 7 ]

oWalker.TurnAround()

? oWalker.Direction()
#--> backward

? @@( oWalker.Walkables() )
#--> [ 3, 5, 7 ]

proff()
# Executed in 0.01 second(s).

/*---
*/
pron()

oWalker = new stzWalker([ 3, 9, 2 ])

? oWalker.Direction()
#-- forward

	? @@( oWalker.Walkables() ) # Or WalkablePositions()
	#--> [ 3, 5, 7, 9 ]
	
	? @@( oWalker.Walk() )
	#--> [ 3, 5, 7, 9 ]
	
	? oWalker.Position() # Or CurrentPosition()
	#--> 9

oWalker.TurnAround() # Or Turn()

	? oWalker.Direction()
	#--> backward

	? @@( oWalker.Walkables() )
	#--> [ 3, 5, 7, 9 ]

	? @@( oWalker.Walk() ) # Walks starting from CurrentPosition() ~> 9
	#--> [ 9, 7, 5, 3 ]

	? oWalker.Position()
	#--> 3

proff()
# Executed in 0.01 second(s).

