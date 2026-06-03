# Narrative
# --------
# Basic Import on Empty Diagram
#
# Extracted from stzdiagramtest.ring, block #39.

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("MainFlow")

cImported = '
diagram "ProcessFlow"

properties
    theme: pro
    layout: topdown

nodes
    start
        label: "Begin"
        type: start
        color: green+

    process
        label: "Work"
        type: process
        color: blue+

    end
        label: "Finish"
        type: endpoint
	color: orange
edges
    start -> process
    process -> end
'

oDiag.ImportDiag(cImported)
? oDiag.Code() + NL
? oDiag.NodeCount()
#--> 3

? oDiag.EdgeCount()
#--> 2

? oDiag.View()

pf()
#--> Executed in 0.58 second(s) in Ring 1.25
