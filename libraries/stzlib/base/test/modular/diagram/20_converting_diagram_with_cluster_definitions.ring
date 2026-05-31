# Narrative
# --------
# Converting diagram with cluster definitions
#
# Extracted from stzdiagramtest.ring, block #20.

load "../../../stzBase.ring"


pr()

oDiag = new stzDiagram("ClusterTest")
oDiag.AddNodeXTT("api", "API", [ :type = "process", :color = "success" ])
oDiag.AddNodeXTT("db", "DB", [ :type = "storage", :color = "success" ])
oDiag.AddClusterXTT("domain", "Service Domain", ["api", "db"], "lightblue")

? oDiag.stzdiag()
#-->
'
diagram "ClusterTest"

properties
    theme: light
    layout: topdown

nodes
    api
        label: "API"
        type: process
        color: #008000

    db
        label: "DB"
        type: storage
        color: #008000

clusters
    domain
        label: "Service Domain"
        nodes: [api, db]
        color: #4D4DC9
'

oDiag.View()

pf()
# Executed in 1.10 second(s) in Ring 1.25
