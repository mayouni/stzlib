load "../max/stzmax.ring"

/*---

pr()

# This function returns the list of walkable positions from nStart to nEnd
# based on the provided list of steps anSteps, avoiding infinite loops.
//func GetWalkablePositions nStart, nEnd, anSteps

nStart = 5
nEnd = 25
anSteps = [ -2, 1, 4, -3, 7 ]


    # --- Step 1. Find a cycle by accumulating steps until cumulative sum equals 0
    anCycle = []
    nSum = 0
    nCycleIndex = 0
    nLenSteps = len(anSteps)
    for i = 1 to nLenSteps
        nSum += anSteps[i]
        anCycle + anSteps[i]
        if nSum = 0 and i < nLenSteps
            nCycleIndex = i   # cycle detected at position i
            exit            # leave the cycle loop early
        end
    next

    # --- Step 2. Split the steps:
    # if a cycle was detected, use the steps before the closing element (last element of the cycle)
    # as the initial steps.
    initialSteps = [] 
    if nCycleIndex > 0
        # Use the steps up to (but not including) the one that closed the cycle.
        for i = 1 to nCycleIndex - 1
            initialSteps + anCycle[i]
        next
    else
        # If no cycle detected, use the full list as initial steps.
        initialSteps = anSteps
    end

    # The extra (or remaining) part consists of any steps after the cycle.
    remainingSteps = []
    if nCycleIndex > 0
        for i = nCycleIndex + 1 to nLenSteps
            remainingSteps + anSteps[i]
        next
    end

    # --- Step 3. Build the repeating pattern:
    # We want to preserve the “direction” that the user intended.
    # For our test case this will be: remainingSteps concatenated with
    # the positive portion of the initialSteps (skipping any negatives).
    repeatSteps = []
    # First add any remaining steps
    for i = 1 to len(remainingSteps)
        repeatSteps + remainingSteps[i]
    next
    # Then add the positive steps from the initial phase.
    for i = 1 to len(initialSteps)
        if initialSteps[i] > 0
            repeatSteps + initialSteps[i]
        end
    next

    # --- Step 4. Build the walkable positions.
    # First apply the initialSteps, then repeat the repeatSteps until we reach nEnd.
    n = nStart
    anWalkables = [ n ]
    # Apply the initial steps in order.
    for i = 1 to len(initialSteps)
        n = n + initialSteps[i]
        anWalkables + n
    next

    # Then use the repeatSteps pattern.
    nTimes = 0
    nLenRepeat = len(repeatSteps)
    while n < nEnd
        nTimes++
        if nTimes > 100
		exit
	ok
        for i = 1 to nLenRepeat
            candidate = n + repeatSteps[i]
            # In forward walks, if candidate overshoots nEnd, skip this step.
            if nStart < nEnd
                if candidate > nEnd
                    # skip this step, do nothing
                    loop
                ok
            else
                if candidate < nEnd then
                    loop
                ok
            end
            n = candidate
            anWalkables + n
            if n = nEnd
		exit 2
	    ok
        next
    end


    ? @@( anWalkables )


pf()

/*---

pr()

# Let's take the exxamle of:
nStart = 5
nEnd = 25

# And suppose the user introduced these steps

anSteps = [ -2, 1, 4, -3, 7 ]
nLenSteps = len(anSteps)

# Considering only the real steps by identifying
# potenial infinite walking loop

anRealSteps = []

nSum = 0
for i = 1 to nLenSteps

	
	nSum += anSteps[i]
	if nSum = 0
		exit
	ok
	
	anRealSteps + anSteps[i]
next

? @@(anRealSteps) # Note how the last [ -3, 7 ] steps are ignored
#--> [ -2, 1, 4 ]


# Now, Doing the job, by cycling through the real steps,
# sum them and yield the value, until the value goes out
# of the walkable limits, or when accedding a  high loop

nLenRealSteps = len(anRealSteps)
n = nStart
anWalkables = [n]

nTimes = 0

while true

	nTimes++
	if  nTimes > 100
		exit
	ok

	for i = 2 to nLenRealSteps
		n += anRealSteps[i]
		if n < nStart or n > nEnd
			exit
		ok
		anWalkables + n
	next

end

# Now we should have our walkable positions
? @@(anWalkables)
#--> [ 5, 6, 10, 11, 15, 16, 20, 21, 25 ]

# note that this is not totally correct, but the logic is good!

pf()

/*---

pr()

nStart = 5
nEnd = 25

anSteps = [ -2, 1, 4, -3 ]
nLenSteps = len(anSteps)

anWalkables = [ nStart ]
nCurrent = nStart
n = 0
i = 0

aStepVals = [ 5 ]

while TRUE
	n++
	if n > nEnd
		exit
	ok

	i++
	if i > nLenSteps
		i = 1
	ok

	nStep = anSteps[i]
? ">> @"+ nStep
? ">> " + @@(aStepVals) + NL
	nNew = nCurrent + nStep

? "!!! " + @@([ i, len(aStepVals)]) + nl

	nLenVal = len(aStepVals)
	
	if i > nLenVal
		aStepVals + nNew
	else
		if aStepVals[i] = nNew
			exit
		ok

		aStepVals[i] = nNew
	ok

	anWalkables + nNew
end

? @@(anWalkables)

pf()

/*--- Using negative steps
*/
pr()


oWalker = new stzWalker(5, 25, [ -2, 1, 4, -3, 7 ])
oWalker {

        # Negative steps walker setup

        ? StartPosition()
	#--> 5
        ? EndPosition()
	#--> 25

        ? @@( oWalker.Steps() )
	#--> [ -2, 1, 4, -3 ]
        ? Direction()
	#--> forward (since 5 < 25)

        ? @@( Walkables() )
	#--> [ 5, 3, 4, 8, 5, 9, 13, 10 ]
        ? CurrentPosition() + NL
	#--> 5

        # Walking through positions with mixed negative/positive steps

        ? @@( Walk() )      # Output: [ 5, 3 ] (first step is -2)
        ? CurrentPosition() + NL  # Output: 3

        # Walking multiple steps

        ? @@( WalkNSteps(3) )  # Output: [ 3, 4, 8, 5 ]

        ? CurrentPosition()  # Output: 5
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
