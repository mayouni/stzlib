# Narrative
# --------
# #TODO chech output!
#
# Extracted from stzccodetest.ring, block #10.

load "../../../stzBase.ring"


StartProfiler()

	o1 = new stzCCode('{ @item = @PreviousItem + 1 }')
	? o1.ExecutableSectionXT()
	#--> [ 2, :Last ]

StopProfiler()
# Executed in 0.07 second(s) in Ring 1.23
# Executed in 0.12 second(s) in Ring 1.21
# Executed in 0.26 second(s) in Ring 1.17
