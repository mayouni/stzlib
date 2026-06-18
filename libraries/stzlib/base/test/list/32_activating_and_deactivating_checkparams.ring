# Narrative
# --------
# #narration: activating and deactivating CheckParams()
#
# Extracted from stzlisttest.ring, block #32.

load "../../stzBase.ring"


pr()

# This narration shows how deactivating checking params could enhance
# performance. By default, the feature is on, and depending on the
# function you are using, more or less params semantics are checked.
	
# So, in the case:
	
	o1 = new stzList([ "ring", "ruby", "softanza", "ring", "php", "softanza" ])
	o1.ReplaceTheseItemsAtPositions([ 1, 3, 4, 5 ], [ "ring", "softanza" ] , :By = "♥♥♥")
	
	? o1.Content()
	#--> [ "♥♥♥", "ruby", "♥♥♥", "♥♥♥", "php", "softanza" ]
	
	# The execution takes about 0.18 seconds (on my machine)

	? ElapsedTime()
	# Executed in 0.18 second(s)

# But if you disable params checking and restartd the same code:

	CheckParamsOff()

	# And repeat the same job

	o1 = new stzList([ "ring", "ruby", "softanza", "ring", "php", "softanza" ])
	o1.ReplaceTheseItemsAtPositions([ 1, 3, 4, 5 ], [ "ring", "softanza" ] , "♥♥♥")
	
	? o1.Content()
	#--> [ "♥♥♥", "ruby", "♥♥♥", "♥♥♥", "php", "softanza" ]

	# It would take half of the time!

pf()
# Executed in 0.09 second(s)
