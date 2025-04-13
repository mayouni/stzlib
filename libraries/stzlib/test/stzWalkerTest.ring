load "../max/stzmax.ring"



/*--- Using negative steps

pr()


oWalker = new stzWalker(5, 25, [ -2, 1, 4, -3, 7 ])
oWalker {

        # Negative steps walker setup

        ? StartPosition()
	#--> 5
        ? EndPosition()
	#--> 25

        ? @@( oWalker.Steps() )
	#--> [ -2, 1, 4, -3, 7 ]

        ? Direction()
	#--> forward (since 5 < 25)

        ? @@( Walkables() )
	#--> [ 5, 3, 4, 8, 15, 16, 20, 21, 25 ]

        ? CurrentPosition() + NL
	#--> 5

        # Walking through positions with mixed negative/positive steps

        ? @@( Walk() )
	#--> [ 5, 3 ] 	(first step is -2)

        ? CurrentPosition() + NL
	#--> 3

        # Walking multiple steps

        ? @@( WalkNSteps(3) )
	#--> [ 3, 4, 8, 15 ]

        ? CurrentPosition()
	#--> 15
}

pf()

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
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.02 second(s) in Ring 1.21

/*---

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
# Executed in 0.02 second(s) in Ring 1.22

/*===

pr()

oWalker = new stzWalker( 5, -5, 2 )
? oWalker.Content()
#--> [ 5, 3, 1, -1, -3, -5 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
# Executed in 0.01 second(s) in Ring 1.21

/*===

pr()

oWalker = new stzWalker( :StartingAt = 1, :EndingAt = 8, :Step = 9 )
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

	? @@( History() ) # Or Walks()
	#--> [ [ 3, 5 ], [ 5, 7, 9 ] ]

	? @@( WalkedPositions() )
	#--> [ 3, 5, 7, 9 ]

}

pf()
# Executed in almost 0 second(s) in Ring 1.22
# Executed in 0.02 second(s) in Ring 1.21

/*---

pr()

w = new stzWalker(1, 10, 2)

# Statically getting the walkables positions
# (without performing any movement of the walker)

? @@( w.Walkables() )	# Or Positions()
#--> [ 1, 3, 5, 7, 9 ]

? @@( w.Unwalkables() )
#--> [ 2, 4, 6, 8, 10 ]

# Now, we will perform an effectove walking
# (the Walker will move across the positions)

# first, let's get the default position

? w.Position() + NL # Or CurrentPosition()
#--> 1

# Walk through all the positions

while w.CanWalk()
	w.Walk()
	? w.Position()
end
#--> [ 3, 5, 7, 9 ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*----

pr()

oWalker = new stzWalker(1, 10, 2)

# All positions

? oWalker.NumberOfPositions()
#--> 10

? @@( oWalker.Positions() )
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

# Walkable positions

? @@( oWalker.Walkables() )
#--> [ 1, 3, 5, 7, 9 ]

# Unwalkable positions

? @@( oWalker.UnWalkables() )
#--> [ 2, 4, 6, 8, 10 ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*----

pr()

oWalker = new stzWalker(1, 12, 2)
oWalker {

	? @@( Walkables() )
	#--> [ 1, 3, 5, 7, 9, 11 ]
	
	? CurrentPosition()
	#--> 1
	
	? @@( WalkN(2) )
	#--> [ 1, 3, 5 ]
	
	? CurrentPosition()
	#--> 5

	? @@( RemainingWalkables() )
	#--> [ 7, 9, 11 ]

	WalkN(2) # You can type ? to see the walked steps ~> [ 5, 7, 9 ]
	? CurrentPosition()
	#--> 9
	
	? @@( HowManyRemainingWalkables() )
	#--> 1
	
	? @@( RemainingWalkables() )
	#--> [ 11 ]

	? @@( WalkN(1) )
	#--> [ 9, 11 ]

	// Walk()
	#--> ERROR: Can't walk! No more walkable positions!

}

pf()
# Executed in almost 0 second(s) in Ring 1.22
# Executed in 0.02 second(s) in Ring 1.21

/*----

pr()

oWalker = new stzWalker(12, 1, 2)
oWalker {

	? Direction()
	#--> backward

	? @@( Walkables() )
	#--> [ 12, 10, 8, 6, 4, 2 ]

	? CurrentPosition()
	#--> 2

	? @@( RemainingWalkables() )
	#--> [ 10, 8, 6, 4, 2 ]

	? @@( WalkNSteps(2) ) # Or WalkN()
	#--> [ 12, 10, 8 ]

	? CurrentPosition() # Or Position()
	#--> 8

	? @@( RemainingWalkables() )
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

	? @@( WalkN(1) ) # Or simplie Walk()
	#--> [ 4, 2 ]

	? @@( RemainingWalkables() )
	#--> [ ]

	// Walk()
	#--> ERROR: Can't walk! No more walkable positions!
}

pf()
# Executed in almost 0 second(s) in Ring 1.22
# Executed in 0.02 second(s) in Ring 1.21

/*===

pr()

w = new stzWalker(3, 12, 2)

? w.Position()
#--> 3

? @@( w.Walkables() )
#--> [ 3, 5, 7, 9, 11 ]

? @@( w.WalkNSteps(2) )
#--> [ 3, 5, 7 ]

? w.Position()
#--> 7

// w.WalkTo(8)
#--> ERROR: Can't walk! The position provided is not walkable.

? @@( w.WalkTo(5) )
#--> [ 7, 5 ]

? w.Position() + NL
#--> 5

? "--" + NL

? @@( w.WalkToFirst() )
#--> [ 5, 3 ]

? @@( w.WalkToLast() )
#--> [ 3, 5, 7, 9, 11 ]

? w.Position() + NL
#--> 11

? @@( w.WalkBetween(5, 9) )
#--> [ 5, 7, 9 ]

? w.Position() + NL
#--> 9

? @@( w.WalkBetween(9, 5) )
#--> [ 9, 7, 5 ]

? w.Position()
#--> 5

pf()
# Executed in 0.01 second(s) in Ring 1.22

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
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

w = new stzWalker(2, 9, 2)

? @@( w.Walkables() )
#--> [ 2, 4, 6, 8 ]

? @@( w.WalkTo(4) )
#--> [ 2, 4 ]

? w.Position()
#--> 4

? @@( w.WalkFromEnd() )
#--> [ 8, 6, 4 ]

? @@( w.WalkFromStart() )
#--> [ 2, 4 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*====

pr()

w = new stzWalker(3, 10, 2)

? @@( w.Walkables() ) + NL
#--> [ 3, 5, 7, 9 ]

? @@( w.Walk() )
#--> [ 3, 5 ]

# Walk from the last position to the current position

? @@( w.WalkFromLast() )
#--> [ 9, 7, 5 ]

? @@( w.WalkedPositions() ) + NL
#--> [ 3, 5, 7, 9 ]

? @@NL( w.Walks() ) + NL # Or w.History()
#--> [
#	[ 3, 5 ],
#	[ 9, 7, 5 ]
# ]

? @@( w.FirstWalk() )
#--> [ 3, 5 ]

? @@( w.NthWalk(2) )
#--> [ 9, 7, 5 ]

? @@( w.LastWalk() )
#--> [ 9, 7, 5 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*=== VARIANT STEPS

/*--- Basic variant steps (using a list of step sizes)

pr()

oWalker = new stzWalker(1, 15, [ 2, 3, 1 ]) 
oWalker {

	? @@( Walkables() )
	#--> [ 1, 3, 6, 7, 9, 12, 13, 15 ]
	# Steps: +2, +3, +1, +2, +3, +1, +2

	? CurrentPosition()
	#--> 1

	? @@( WalkN(3) )
	#--> [ 1, 3, 6, 7 ]

}

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Walking backwards with variant steps

pr()

oWalker = new stzWalker(20, 5, [ 4, 2, 1 ])
oWalker {

	? @@( Walkables() )
	#--> [ 20, 16, 14, 13, 9, 7, 6 ]
	# Steps: -4, -2, -1, -4, -2, -1

	? CurrentPosition()
	#--> 20

	? @@( WalkN(4) )
	#--> [ 20, 16, 14, 13, 9 ]
}

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Using variant steps with WalkBetween

pr()

oWalker = new stzWalker(5, 25, [ 3, 5, 2 ])
oWalker {

	? @@( Walkables() )
	#--> [ 5, 8, 13, 15, 18, 23, 25 ]

	? CurrentPosition()
	#--> 5

	? @@( WalkBetween(8, 23) )
	#--> [ 8, 13, 15, 18, 23 ]

	? CurrentPosition()
	#--> 23

}

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Checking walking history with variant steps

pr()

oWalker = new stzWalker(100, 70, [ 7, 3, 5 ])
oWalker {

	? @@( Walkables() )
	#--> [ 100, 93, 90, 85, 78, 75, 70 ]

	? CurrentPosition()
	#--> 100

	? @@( Walk() )
	#--> [ 100, 93 ]

	? @@( Walk() )
	#--> [ 93, 90 ]

	? @@( Walks() )
	#--> [ [ 100, 93 ], [ 93, 90 ] ]

	? @@( WalkedPositions() )
	#--> [ 100, 93, 90 ]

}

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Remaining walkable positions with variant steps

pr()

oWalker = new stzWalker(10, 35, [ 5, 3, 7 ])
oWalker {

	? @@( Walkables() )
	#--> [ 10, 15, 18, 25, 30, 33 ]

	? CurrentPosition()
	#--> 10

	? @@( Walk() )
	#--> [ 10, 15 ]

	? @@( RemainingWalkables() )
	#--> [ 18, 25, 30, 33 ]

	? NumberOfRemainingWalkables()
	#--> 4

}

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*=== DIRECTIONAL WALKING

/*--- Basic direction with forward and backward walking

pr()

oWalker = new stzWalker(:From = 5, :To = 25, :Step = 5)
oWalker {

	# Initial walker setup
	? @@( Walkables() )
	#--> [ 5, 10, 15, 20, 25 ]

	? StartPosition()
	#--> 5

	? EndPosition()
	#--> 25

	? Direction()
	#--> forward

	? CurrentPosition() + NL
	#--> 5

	? "---" + NL

	# Walking forward by default

	? @@( Walk() )	# Moves from position 5 to position 10
	#--> [ 5, 10 ]

	? CurrentPosition() + NL
	#--> 10

	? "---" + NL

	# Explicitly walking backward

	? @@( WalkBackward() )
	#--> [ 10, 5 ]

	? CurrentPosition()
	#--> 5

	? Direction() + NL
	#--> backward

	? "---" + NL

	# Walking forward with multiple steps

	? @@( WalkNForward(2) )
	#--> [ 5, 10, 15 ]

	? CurrentPosition()
	#--> 15

	? Direction() + NL
	#--> forward

	? "---" + NL

	# Walking to a specific position (changes direction automatically)

	? @@( WalkTo(5) )
	#--> [ 15, 10, 5 ]

	? CurrentPosition()
	#--> 5

	? Direction()
	#--> backward
}

pf()
# Executed in 0.06 second(s) in Ring 1.22

/*--- Using variable steps with direction

pr()

oWalker = new stzWalker(5, 25, [ 3, 5, 2 ])
oWalker {

	# Walker setup

	? StartPosition()
	#--> 5

	? EndPosition()
	#--> 25

	? @@( Steps() )
	#--> [ 3, 5, 2 ]

	? Direction()
	#--> forward

	?  @@( Walkables() )
	#--> [ 5, 8, 13, 15, 18, 23, 25 ]

	? CurrentPosition() + NL
	#--> 5

	? "---" + NL

	# Walking between positions

	? @@( WalkBetween(23, 8) )
	#--> [ 23, 18, 15, 13, 8 ]

	? CurrentPosition()
	#--> 8

	? Direction() + NL
	#--> backward

	? "---" + NL

	# Setting direction explicitly

	SetDirection(:Forward)
	? Direction()
	#--> forward

	? @@( oWalker.Walk() )
	#--> [ 8, 13 ]

	? CurrentPosition() + NL
	#--> 13

	? "---" + NL

	# Reversing direction

	ReverseDirection()
	? Direction()
	#--> backward

	? @@(oWalker.Walk())
	#--> [ 13, 8 ]

	? CurrentPosition()
	#--> 8

}

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*---

pr()

pf()

/*--- Backward initial direction

pr()

oWalker = new stzWalker(25, 5, 4)
oWalker {

	# Backward walker setup

	? StartPosition()
	#--> 25

	? EndPosition()
	#--> 5

	? Direction()
	#--> backward

	? @@( Walkables() )
	#--> [ 25, 21, 17, 13, 9, 5 ]

	? CurrentPosition()
	#--> 25

	? @@( RemainingWalkables() )
	#--> [ 21, 17, 13, 9, 5 ]

	? "---" + NL

	# Walking in backward default direction

	? @@(Walk())
	#--> [ 25, 21 ]

	? CurrentPosition() + NL
	#--> 21

	# Checking remaining walkables (in backward direction)
	? @@(RemainingWalkables()) + NL
	#--> [ 17, 13, 9, 5 ]

	? "---" + NL

	# Changing direction to forward despite backward configuration()

	? CurrentPosition()
	#--> 21

	SetDirection(:Forward)
	? Direction()
	#--> forward

	# Can still walk?
	? @IF( :It = CanWalk(), :Say = "YES", :Otherwise = "NO" )
	#--> YES

	? @@(oWalker.RemainingWalkables())
	#--> [ 25 ]

}

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Complex walking scenario with direction changes

pr()

oWalker = new stzWalker(:start = 10, :end = 30, :step = [2, 3, 5])
oWalker {

	? @@(oWalker.Walkables())
	#--> [ 10, 12, 15, 20, 22, 25, 30 ]

	? CurrentPosition() + NL
	#--> 10

	? @@( WalkNSteps(3) )
	#--> [ 10, 12, 15, 20 ]

	? CurrentPosition()
	#--> 20

	? Direction() + NL
    	#--> forward

	# Walking to a position backward

	? @@( WalkTo(10) )
	#--> [ 20, 15, 12, 10 ]

	? CurrentPosition()
	#--> 10

	? Direction() + NL
    	#--> backward

	# Walking from current to another position

	? @@( WalkBetween(10, 20) )
	#--> [ 10, 12, 15, 20 ]

	? CurrentPosition()
	#--> 20

	? Direction() + NL
    	#--> forward

	# Walking history

	? @@NL( Walks() ) # Or History()
	#--> [
	# 	[ 10, 12, 15, 20 ],
	# 	[ 20, 15, 12, 10 ],
	# 	[ 10, 12, 15, 20 ]
	# ]

	? @@( WalkedPositions() )
	#--> [ 10, 12, 15, 20 ]

}

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Using constant step with direction changes

pr()

oWalker = new stzWalker(1, 20, 3)
oWalker {

	? @@(oWalker.Walkables())
	#--> [ 1, 4, 7, 10, 13, 16, 19 ]

	? CurrentPosition() + NL
	#--> 1

	# Walking forward twice

	? @@( Walk() )
	#--> [ 1, 4 ]

	? @@( Walk() )
	#--> [ 4, 7 ]

	? CurrentPosition() + NL
	#--> 7

	# Changing direction and walking backward

	SetDirection(:Backward)
	? @@( Walk() )
	#--> [ 7, 4 ]

	? CurrentPosition()
	#--> 4

	? Direction() + NL
	#--> backward

	# Reverse direction and walk again

	ReverseDirection()
	? Direction()
	#--> forward

	? @@( Walk() )
	#--> [ 4, 7 ]

	? CurrentPosition() + NL
	#--> 7

	# Try walking to position 16

	? @@( WalkTo(16) )
	#--> [ 7, 10, 13, 16 ]

	? CurrentPosition()
	#--> 16

	? Direction() + NL
	#--> forward

}

pf()
# Executed in almost 0 second(s) in Ring 1.22

#=== EDGE CASES FOR NEGATIVE AND POSITIVE STEPS

/*--- Empty sequence due to self-cancelling steps

pr()

oWalker = new stzWalker(10, 20, [3, -3])

# Walking 3 steps and then -3 is not considering a walking
# pattern in Softanza and only the firts 3 step is considered

? @@( oWalker.Steps() )
#--> 3

# Hence it's like oWalker = nex stzWalker(10, 20, 3)

? @@( oWalker.Walkables() )
#--> [ 10, 13, 16, 19 ]

? oWalker.CurrentPosition()
#--> 10

# Walking one step

? @@( oWalker.Walk() )
#--> [ 10, 13 ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Oscillation with mixed steps around start position

pr()

oWalker = new stzWalker(10, 20, [ 2, -1 ])

? @@( oWalker.Walkables() )
#--> [ 10, 12, 14, 16, 18, 20 ]

? oWalker.CurrentPosition()
#--> 10

? @@( oWalker.Walk() )
#--> [ 10, 12 ]

? @@( oWalker.Walk() )
#--> [ 12, 14 ]

? @@( oWalker.Walk() )
#--> [ 14, 16 ]

? oWalker.CurrentPosition()
#--> 16

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Negative steps taking us backward beyond start //////////

pr()

# Trying to go backward beyond start

oWalker = new stzWalker(10, 20, [-5, 2]) #TODO shoumd raise an error becaue -5 --> outiside!

? @@( oWalker.Walkables() )

# Check if position 5 is walkable
? oWalker.IsWalkable(5)

? oWalker.CurrentPosition()
? @@( oWalker.Walk() )
? oWalker.CurrentPosition()

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Mixed steps with large values

pr()

oWalker = new stzWalker(100, 120, [15, -10, 7])

? @@( oWalker.Walkables() )
#--> [ 100, 115, 105, 112, 119 ]

? @@( oWalker.WalkNSteps(3) )
#--> [ 100, 115, 105, 112 ]

? oWalker.CurrentPosition()
#--> 112

pf()
# Executed in 0.03 second(s) in Ring 1.22

/*--- Boundary condition - reaching end exactly

pr()

# Reaching end exactly

oWalker = new stzWalker(5, 25, [5, 10, 5])

? @@( oWalker.Walkables() )
#--> [ 5, 10, 20, 25 ]

? @@( oWalker.WalkToLast() )
#--> [ 5, 10, 20, 25 ]

? @@( oWalker.Walk() )
#--> ERROR: Can't walk! No more walkable positions in the current direction.

pf()

/*--- Alternating small and large steps

pr()

oWalker = new stzWalker(10, 50, [1, -2, 10, -5])

?  @@( oWalker.Walkables() ) + NL
#--> [ 10, 11, 9, 19, 14, 15, 25, 26, 36, 37, 47, 48, 49, 50 ]

# Walk sequence of 5 steps

for i = 1 to 5
	? @@( oWalker.Walk() )
next
#-->
# [ 10, 11 ]
# [ 11, 9 ]
# [ 9, 19 ]
# [ 19, 14 ]
# [ 14, 15 ]

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Skipping over the end position
*/
pr()

oWalker = new stzWalker(5, 25, [8, 12])

? @@( oWalker.Walkables() )
#--> [ 5, 13, 21 ]

while oWalker.CanWalk()
    ? @@( oWalker.Walk() )
end
#--> [ 5, 13 ]
#--> [ 13, 21 ]

? oWalker.CurrentPosition()
#--> 21

? oWalker.IsWalkable(25)
#--> 0

pf()
# Executed in 0.01 second(s) in Ring 1.22
