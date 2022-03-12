load "stzlib.ring"

/*-------------------

o1 = new stzWalker([])

o1 {
	? Name() # --> :Walker0

	? NumberOfPositions() # --> 2

	? StartPosition() # --> 1
	? EndPosition() # --> 2

	? NStep() # --> 1	

	? Positions() # --> [ 1, 2 ]

	? WalkedPositions() # --> [ 1, 2 ]
	? UnwalkedPositions() # --> [ 1, 2 ]

}

/*------------------- TODO: test this!
*/
# Softanza tends to be permissive as part of its FELXIBILITY design goal.
# Let's show this by an example.

# A Walker is defined by its starting position, ending position, and number of
# positions per step, like this:

oWalker = new stzWalker([ :StartingAt = 1, :EndingAt = 8, :Step = 2 ])
? oWalker.Positions() # --> [ 1, 3, 5, 8 ]
/*
# Now, if you do not provide a paramter, Softanza gives a default value to it:

oWalker = new stzWalker([ :EndingAt = 8, :Jump = 2 ])
? oWalker.Positions() # --> [ 1, 3, 5, 8 ]
? oWalker.StartingPosition() # --> 1	(Set automatically by Softanza)

oWalker = new stzWalker([ :EndingAt = 8 ])
? oWalker.Positions() # --> [ 1, 2, 3, 4, 5, 6, 7, 8 ]
? oWalker.StartingPosition() 	# --> 1	(Set automatically by Softanza)
? oWalker.Jump() 		# --> 1 (Idem)

# Even when, you provide a large value for a param, Softanza corrects it
oWalker = new stzWalker([ :StartingAt = 1, :EndingAt = 8, :Jump = 32 ])
? oWalker.Positions() 	# --> [ 1, 2, 3, 4, 5, 6, 7, 8 ]
? oWalker.Jump() 	# --> 1	(Set automatically by Softanza)

# When nothing is provided, a "hanicaped" walker is created:

oWalker = new stzWalker([])
? oWalker.Positions() # --> [ 1 ]
? oWalker.StartingPosition() # --> 1	(Given automatically by Softanza)
? oWalker.EndPosition() # --> 1		(Idem)
? oWalker.Jump() # --> 0 (Can't walk)	(Idem)

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
