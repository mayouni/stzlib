load "stzlib.ring"

/*-------------------
s
pron()

? Q(1:10).ManyRemoved([ 3, 7, 9 ])
#--> [ 1, 2, 4, 5, 6, 8, 10 ]

proff()
# Executed in 0 second(s).

/*-------------------


pron()

o1 = new stzWalker([ :MyWalker, 1, 10 , 2 , :Forward ])

o1 {
	? Name()
	#--> :Walker0

	? NumberOfPositions()
	#--> 10

	? StartPosition()
	#--> 1
	? EndPosition()
	#--> 10
	? NStep() + NL
	#--> 2	

	? Positions()
	#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

	? WalkedPositions()
	#--> [ 1, 3, 5, 7, 9 ]

	? UnwalkedPositions()
	#--> [ 2, 4, 6, 8, 10 ]

}

proff()
# Executed in 0.02 second(s).

/*-------------------
*/
pron()

o1 = new stzWalker([
	:Name = :MyWalker,
	:Start = 1,
	:End = 10,
	:Step = 2,
	:Direction = :Backward ])

o1 {
	? Name()
	#--> "mywalker"

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

	? @@( WalkedPositions() )
	#--> [ 10, 8, 6, 4, 2 ]

	? @@( UnwalkedPositions() )
	#--> [ 1, 3, 5, 7, 9 ]

}

proff()
# Executed in 0.02 second(s).

/*------------------- TODO: test this!
*/
pron()

# Softanza tends to be permissive as part of its FELXIBILITY design goal.
# Let's show this by an example.

# A Walker can be defined by its starting position, ending position, and number of
# positions per step, like this:

oWalker = new stzWalker([
	:Direction = :Forward,
	:StartingAt = 1,
	:EndingAt = 8,
	:NStep = 2
])

? oWalker.Positions() #--> [ 1, 3, 5, 8 ]
/*
# Now, if you do not provide a paramter, Softanza gives a default value to it:

oWalker = new stzWalker([ :EndingAt = 8, :Jump = 2 ])
? oWalker.Positions() #--> [ 1, 3, 5, 8 ]
? oWalker.StartingPosition() #--> 1	(Set automatically by Softanza)

oWalker = new stzWalker([ :EndingAt = 8 ])
? oWalker.Positions() #--> [ 1, 2, 3, 4, 5, 6, 7, 8 ]
? oWalker.StartingPosition() 	#--> 1	(Set automatically by Softanza)
? oWalker.Jump() 		#--> 1 (Idem)

# Even when, you provide a large value for a param, Softanza corrects it
oWalker = new stzWalker([ :StartingAt = 1, :EndingAt = 8, :Jump = 32 ])
? oWalker.Positions() 	#--> [ 1, 2, 3, 4, 5, 6, 7, 8 ]
? oWalker.Jump() 	#--> 1	(Set automatically by Softanza)

# When nothing is provided, a "hanicaped" walker is created:

oWalker = new stzWalker([])
? oWalker.Positions() #--> [ 1 ]
? oWalker.StartingPosition() #--> 1	(Given automatically by Softanza)
? oWalker.EndPosition() #--> 1		(Idem)
? oWalker.Jump() #--> 0 (Can't walk)	(Idem)
*/

proff()
/*-------------------

o1 = new stzWalker([ :Name = :Walker2, :StartingAt = 5, :EndingAt = 3, :Jump = 31 ])

o1 {
	? Name()			# !--> "Walker1"

	? StartPosition()	# !--> 1

	? EndPosition()		# !--> 10

	? Jump()			# !--> 2		# Same as NumberOfPositionsInAJump()

	? NumberOfPositions() + NL	# !--> 4
	? Positions()		# !--> [ 1, 4, 7, 10 ]

	//NthPosition(3)		# !--> 7

	//PositionsW( :Where = 'Q(@position).IsPrimeNumber()' )
				# !--> [ 1, 7 ]

}
