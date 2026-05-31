# Narrative
# --------
# Adding performance properties to nodes
#
# Extracted from stzdiagramtest.ring, block #11.

load "../../../stzBase.ring"


pr()

oDiag = new stzDiagram("Annotated")
oDiag.AddNodeXTT("process", "Process", [ :type = "process", :color = "primary" ])

oPerf = new stzDiagramAnnotator(:Performance)
oPerf.Annotate("process", ["latency" = 150, "unit" = "ms"])

oDiag.AddAnnotation(oPerf)

? len(oDiag.Annotations()) #--> 1
? len(oPerf.NodesData()) #--> 1

pf()
# Executed in 0.02 second(s) in Ring 1.24
