# Narrative
# --------
# Import Error - Missing Connection Node
#
# Extracted from stzdiagramtest.ring, block #42.

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("MainFlow")
oDiag.AddNodeXTT("start", "Begin", [ :type = "start", :color = "success" ])

cBadImport = '
diagram "BadFlow"

nodes
    process
        label: "Work"
        type: process
        color: #0000FF

    end
        label: "Finish"
        type: endpoint
        color: #008000

edges
    process -> end
'

oDiag.ImportDiag(cBadImport)
#--> ERROR MESSAGE:
# Import failed: First node 'process' not found in current diagram.
# Either add node 'process', or clear the diagram with RemoveAllNodes()

pf()
#--> Executed in 0.03 second(s) in Ring 1.24

#================#
#  NODE REMOVAL  #
#================#
