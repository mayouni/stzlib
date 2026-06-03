# Narrative
# --------
# Same shape as block 02, but the restart value is now 2 instead of 1.
# After the first cycle 1,2,3,4 the counter wraps to 2,3,4 and keeps
# cycling on the shorter range. The 7th element of the 9-step run is
# the 4th member of the second cycle (2,3,4,2) = 4.

load "../../stzBase.ring"

pr()

o1 = new stzCounter([
	:StartAt = 1,
	:WhenYouReach = 5,
	:RestartAt = 2
])

? @@( o1.CountTo(9) )
#--> [ 1, 2, 3, 4, 2, 3, 4, 2, 3 ]

? o1.CountToXT(9, :ReturnNth = 7)
#--> 4

pf()
# Reference timings:
# - 0.01s in Ring 1.23
# - 0.04s in Ring 1.21
