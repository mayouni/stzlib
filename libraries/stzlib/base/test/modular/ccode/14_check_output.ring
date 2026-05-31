# Narrative
# --------
# #TODO Check output!
#
# Extracted from stzccodetest.ring, block #14.

load "../../../stzBase.ring"


StartProfiler()

	o1 = new stzCCode('{ This[ @NextPosition ] = This[ @CurrentPosition ] + "O" }')
	? o1.ExecutableSectionXT()
	#--> [ 1, -1 ]

StopProfiler()
# Executed in 0.07 second(s) in Ring 1.23
# Executed in 0.12 second(s) in Ring 1.21
# Executed in 0.28 second(s) in Ring 1.17
