# Narrative
# --------
# #narration #perf
#
# Extracted from stzccodetest.ring, block #12.

load "../../stzBase.ring"


StartProfiler()

# Whenever possible, write a conditional code using only the This[]
# and @i keywords. This will always lead to a better performance:

	o1 = new stzCCode('{ This[@i] = -This[@i] }')
	? o1.ExecutableSection()
	#--> [ 1, :Last ]
	# Executed in 0.04 second(s)

	o1 = new stzCCode('{ @number = -@number }')
	? o1.ExecutableSectionXT()
	#--> [ 1, :Last ]
	# Executed in 0.07 second(s)

StopProfiler()
# Executed in 0.08 second(s) in Ring 1.23
