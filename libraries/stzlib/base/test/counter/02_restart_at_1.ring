# Narrative
# --------
# Same counter idea, expressed with `:WhenYouReach` (alias for the
# inclusive boundary). When the counter reaches 5 it restarts at 1, so
# the active values are 1..4 cycled. CountToXT returning the 7th element
# of a 9-step run lands on the 3rd value of the second cycle = 3.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

o1 = new stzCounter([
	:StartAt = 1,
	:WhenYouReach = 5,
	:RestartAt = 1
])

? @@( o1.CountTo(9) )
#--> [ 1, 2, 3, 4, 1, 2, 3, 4, 1 ]

? o1.CountToXT(9, :ReturnNth = 7)
#--> 3

pf()
# Reference timings:
# - 0.01s in Ring 1.23
# - 0.05s in Ring 1.21
