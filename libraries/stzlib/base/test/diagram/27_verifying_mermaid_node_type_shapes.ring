# Narrative
# --------
# Verifying Mermaid node type shapes
#
# Extracted from stzdiagramtest.ring, block #27.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("MermaidShapesTest")
oDiag.AddNodeXTT("s", "Node S", [ :type = "start", :color = "success" ])
oDiag.AddNodeXTT("d", "Node D", [ :type = "decision", :color = "warning" ])
oDiag.AddNodeXTT("e", "Node E", [ :type = "endpoint", :color = "success" ])

# CAPTURED FROM A RUN, NOT AUTHORED. The promise below is a REGRESSION
# BASELINE taken on haro 21317660327e7241, engine stzlib c2b930b71,
# 2026-11-23. The arrow was left empty by whoever wrote this file, so nobody
# has ever judged the value: it records what the code DOES, not what it
# SHOULD do. If it and the code disagree later, read BOTH -- the promise may
# be the defect. (That is how 192 came to be promised for a draw from a list
# not containing it; see listofnumbers/36_anynumberbefore.ring.)
? oDiag.Mermaid()
#--> graph TD
#--> s(["Node S"])
#--> d{{"Node D"}}
#--> e(["Node E"])
'
graph TD
    s(["Node S"])
    d{{"Node D"}}
    e(["Node E"])
'

pf()
