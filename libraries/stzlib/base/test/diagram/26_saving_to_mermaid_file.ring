# Narrative
# --------
# Saving to Mermaid file
#
# Extracted from stzdiagramtest.ring, block #26.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("simple")
oDiag.AddNodeXTT("start", "Start", [ :type = "start", :color = "success" ])
oDiag.AddNodeXTT("decision", "Check", [ :type = "decision", :color = "warning" ])
oDiag.AddNodeXTT("process", "Process", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("end", "End", [ :type = "endpoint", :color = "success" ])

oDiag.Connect("start", "decision")
oDiag.ConnectXT("decision", "process", "Yes")
oDiag.Connect("process", "end")

if oDiag.WriteToMermaidInFolder("txtfiles")
	? read("../_data/simple.mmd")
ok

#-->
'
graph TD
    a[["A"]]
    b[["B"]]

    a --> b |leads|
'

pf()
