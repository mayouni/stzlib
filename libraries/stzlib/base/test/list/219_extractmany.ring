# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #219.

load "../../stzBase.ring"

pr()

	o1 = new stzList([ "A", "B", "_", "C", "*" ])
	? o1.ExtractMany(["_", "*"]) # Or ExtractThese()
	#--> ["_", "*"]
	
	? o1.Content()
	#--> #--> [ "A", "B", "C" ]

StopProfiler()

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.20
