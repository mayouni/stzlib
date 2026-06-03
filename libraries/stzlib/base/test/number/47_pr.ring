# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #47.

load "../../stzBase.ring"


	? DefaultRound()
	#--> 2

	? ActiveRound()
	#--> 2
	
	? 1.224
	#--> 1.22

	? 81.8
	#--> 81.80

	StzDecimals(7)

	? ActiveRound()
	#--> 7

	? 1.224
	#--> 1.2240000

	ResetRound()

	? ActiveRound()
	#--> 2

	? 1.224
	#--> 1.22

pf()
# Executed in 0.01 second(s)
