# Narrative
# --------
# Retrieving annotations by type
#
# Extracted from stzdiagramtest.ring, block #12.

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("AnnotationTypes")
oDiag.AddNodeXTT("n1", "Node 1", [ :type = "process", :color = "primary" ])

oPerf = new stzDiagramAnnotator(:Performance)
oPerf.Annotate("n1", ["latency" = 100])
oDiag.AddAnnotation(oPerf)

oComp = new stzDiagramAnnotator(:Compliance)
oComp.Annotate("n1", ["status" = "certified"])
oDiag.AddAnnotation(oComp)

aPerf = oDiag.AnnotationsByType(:Performance)
aCompliance = oDiag.AnnotationsByType(:Compliance)

? len(aPerf) #--> 1
? len(aCompliance) #--> 1

pf()
# Executed in 0.03 second(s) in Ring 1.25

#--------------------------------#
#  ORGANIZING NODES IN CLUSTERS  #
#--------------------------------#
