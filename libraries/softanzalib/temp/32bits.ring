load "stzlib.ring"

pron()

nNum1 = 0
nNum2 = 1
nNum3 = 3

if ( ( ( (nNum2 <= 0) and (nNum3 < nNum1) ) or ( nNum2 = 0 ) ) or

    ( (nNum2 > 0) and (nNum3 > nNum1) ) )

	? "RING_VM_JUMP"
ok

#~~>

	nNum2 = 0 # At any case (OR)
	
	nNum2 < 0
		nNum3 > nNum1
	
	nNum2 > 0
		nNum3 > nNum1

#~~>

	nNum2 = 0 OR nNum3 > nNum1

proff()

/*	
pron()

nNum1 = -909929
nNum2 = 0
nNum3 = -1000

if nNum2 <= 0
	if ( ( NOT (nNum3 >= nNum1) ) OR ( nNum2 = 0 ) )
		? "RING_VM_JUMP"
	ok

else
	if ( NOT (nNum3 <= nNum1) )
		? "RING_VM_JUMP"
	ok
ok

? "--"

if nNum2 = 0 OR (nNum1 < nNum3)
	? "RING_VM_JUMP"
ok


proff()

/*=====

pron()

? Round(2.398)
#--> 2.40

? RoundXT(2.398) # Uses the current round (2 by default, defined by decimals())
		 # XT ~> To preserve the round, number is returned in a string!
#--> "2.40"

? CurrentRound()
#--> 2

? RoundXT([ 2.3988, :To = 3 ]) # XT ~> To preserve the round, number is returned in a string!
#--> "2.400"

? CurrentRound()
#--> 2

proff()
# Executed in 0.09 second(s)

/*-----

pron()

? Q(2.5).RoundedToXT(3)
#--> '2.500'

? Q(2.75).RoundedToXT(0)
#--> '3'

? Q(2).RoundedTo(3)
#--> '2'

? Q(2).RoundedToXT(3)
#--> '2.000'

? Q(12).RoundedToXT(0)
#--> "12"

proff()
# Executed in 0.05 second(s)
