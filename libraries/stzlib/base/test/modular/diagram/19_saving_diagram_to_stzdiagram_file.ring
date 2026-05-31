# Narrative
# --------
# Saving diagram to .stzdiagram file
#
# Extracted from stzdiagramtest.ring, block #19.

load "../../../stzBase.ring"


pr()

oDiag = new stzDiagram("simple")
? oDiag.Name()
#--> sample

oDiag.AddNodeXTT("a", "Node A", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("b", "Node B", [ :type = "process", :color = "primary" ])
oDiag.ConnectXT("a", "b", "flows")

? oDiag.SaveInFolder("txtfiles") # or SaveToFile() without param to save it in current folder
? read("txtfiles/" + oDiag.Name() + ".stzdiag") #--> TRUE
#-->
'
diagram "SaveTest"

properties
    theme: null
    layout: null

nodes
    a
        label: "Node A"
        type: process
        color: primary

    b
        label: "Node B"
        type: process
        color: primary

edges
    a -> b
        label: "flows"
'

pf()
# Executed in 0.05 second(s) in Ring 1.25
