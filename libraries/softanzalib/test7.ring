load "stzlib.ring"


pron()

		o1 = new stzString("...<<***>>...<<***>>...")

		? o1.FindAnyBetween("<<", ">>")
		#--> [ 6, 16 ]

		? o1.FindAnyBetweenS("<<", ">>", :StartingAt = 10)
		#--> [ 16 ]

proff()

/*---------
*/
StartProfiler()

? Q("^^♥♥♥^^").ContainsSubStringBoundedBy("♥♥♥", ["^^","^^"])
#--> TRUE

StopProfiler()
# Executed in 0.28 second(s)
