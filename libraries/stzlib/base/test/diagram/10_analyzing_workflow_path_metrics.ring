# Narrative
# --------
# Analyzing workflow path metrics
#
# Extracted from stzdiagramtest.ring, block #10.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("MetricsTest")

oDiag.AddNodeXTT("start", "Start", [ :type = "start", :color = "success" ])
oDiag.AddNodeXTT("p1", "Step 1", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("p2", "Step 2", [ :type = "process", :color = "primary" ])

oDiag.AddNodeXTT("end", "End", [ :type = "endpoint", :color = "success" ])

oDiag.Connect("start", "p1")
oDiag.Connect("p1", "p2")
oDiag.Connect("p2", "end")

aMetrics = oDiag.ComputeMetrics()
? @@NL(aMetrics)
#-->
'
[
	[ "avgpathlength", 2 ],
	[ "maxpathlength", 3 ],
	[
		"bottlenecks",
		[ "p1", "p2" ]
	],
	[ "density", 25 ],
	[ "nodecount", 4 ],
	[ "edgecount", 3 ]
]
'

? aMetrics[:NodeCount] #--> 4
? aMetrics[:MaxPathLength] #--> 3

pf()
# Executed in 0.03 second(s) in Ring 1.24
