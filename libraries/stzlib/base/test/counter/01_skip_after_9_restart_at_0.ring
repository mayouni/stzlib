# Narrative
# --------
# stzCounter starts at 1, walks up step-by-step, and when the
# "after-you-skip" threshold is reached it wraps back to the restart
# value. Here: count starts at 1, advance until 9 inclusive (skip after
# emitting 9), then resume at 0. CountingXT can return the Nth or Last
# element of the sequence without producing the whole list.

load "../../stzBase.ring"

pr()

o1 = new stzCounter([
	:StartAt = 1,
	:AfterYouSkip = 9,	# or :WhenYouReach = 10
	:RestartAt = 0,
	:Step = 1
])

? @@( o1.Counting( :To = 13 ) ) + NL
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3 ]

? o1.CountingXT( :To = 13, :AndReturning = :Last)
#--> 3

? o1.CountXT( :To = 13, :AndReturnNth = 12)
#--> 2

pf()
# Reference timings:
# - 0.01s in Ring 1.23
# - 0.03s in Ring 1.21
