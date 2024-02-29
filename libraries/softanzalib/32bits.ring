load "stzlib.ring"



/*=====
*/
pron()

? Round(2.398)
#--> 2.4

? RoundXT(2.398) # Uses the current round (2 by default, defined by decimals())
		 # XT ~> To preserve the round, number is returned in a string!
#--> 2.40

? CurrentRound()
#--> 2

? RoundXT([ 2.398, :To = 3 ]) # XT ~> To preserve the round, number is returned in a string!

proff()

/*-----
*/
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
