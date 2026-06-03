# Narrative
# --------
# Multi-stage with caching benchmark
#
# Extracted from stzgraphextest.ring, block #23.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Pipeline")
oGraph {
	AddNodeXT(:input, "Input")
	AddNodeXT(:validate, "Validate")
	AddNodeXT(:process, "Process")
	AddNodeXT(:output, "Output")
	AddEdgeXT(:input, :validate, "feeds")
	AddEdgeXT(:validate, :process, "approved")
	AddEdgeXT(:process, :output, "completes")
}

oGx = new stzGraphex("{@Node(Input) -> @Edge -> @Node(Validate) -> @Edge -> @Node(Process)}", oGraph)

? "First match:"
t1 = clock()
? oGx.Match(oGraph)
? "Time: " + (clock() - t1)

? "Cached match:"
t2 = clock()
? oGx.Match(oGraph)
? "Time: " + (clock() - t2)

? "Explain:"
? @@(oGx.Explain())

pf()

#============================#
#  COMBINED ENHANCEMENTS TEST
#============================#
