# Narrative
# --------
# Converting diagram with annotations
#
# Extracted from stzdiagramtest.ring, block #21.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("AnnotationTest")
oDiag.AddNodeXTT("process", "MyProcess", [ :type = "process", :color = "primary" ])

oPerf = new stzDiagramAnnotator(:Performance)
oPerf.Annotate("process", ["latency" = 150])
oDiag.AddAnnotation(oPerf)

? oDiag.stzdiag()
#-->
'
diagram "annotationtest"

properties
    theme: light
    layout: topdown

nodes
    process
        label: "MyProcess"
        type: process
        color: primary

annotations
    performance
        process: null
'

pf()
