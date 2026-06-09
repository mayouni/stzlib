# Narrative
# --------
# Verifying edge labels in all formats
#
# Extracted from stzdiagramtest.ring, block #31.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("EdgeLabelTest")
oDiag.AddNodeXTT("a", "A", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("b", "B", [ :type = "process", :color = "primary" ])
oDiag.ConnectXT("a", "b", "important")

cStzOutput = oDiag.stzdiag()
cDotOutput = odiag.dot()
cMermaidOutput = oDiag.mermaid()

? contains(cStzOutput, "important")
#--> TRUE

? contains(cDotOutput, "important")
#--> TRUE

? contains(cMermaidOutput, "important")
#--> TRUE

pf()
# Executed in 0.03 second(s) in Ring 1.25

#-------------------------#
# TESTING VISUAL OPTIONS  #
#-------------------------#
