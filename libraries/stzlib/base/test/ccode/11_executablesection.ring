# Narrative
# --------
# StartProfiler()
#
# Extracted from stzccodetest.ring, block #11.

load "../../stzBase.ring"

pr()

	o1 = new stzCCode('{ This[ @i - 5 ] = This[ @i - 3 ] }')
	? o1.ExecutableSection()
	#--> [ 5, :Last ]

StopProfiler()

pf()
# Executed in 0.06 second(s) in Ring 1.23
# Executed in 0.09 second(s) in Ring 1.21
# Executed in 0.14 second(s) in Ring 1.17
