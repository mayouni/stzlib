# Narrative
# --------
# #TODO Check output!
#
# Extracted from stzccodetest.ring, block #15.
#ERR panic: @memcpy arguments alias

load "../../stzBase.ring"

pr()

StartProfiler()

	o1 = new stzCCode('{
		Q(This[ @NextPosition ]).HasDifferentCaseThen( This[ @CurrentPosition ] )
	}')

	? o1.ExecutableSectionXT()
	#--> [ 1, -1 ]

StopProfiler()

pf()
# Executed in 0.07 second(s) in Ring 1.23
# Executed in 0.13 second(s) in Ring 1.21
# Executed in 0.29 second(s) in Ring 1.17
