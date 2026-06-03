# Narrative
# --------
# Export to DOT
#
# Extracted from stzorgcharttest.ring, block #38.

load "../../stzBase.ring"


pr()

oOrg = new stzOrgChart("TechCo")
oOrg {
    AddExecutiveXT("ceo", "CEO")
    AddManagerXT("vp1", "VP")
    ReportsTo("vp1", "ceo")
    
    cDot = Dot()
    # Returns Graphviz DOT format
    
    WriteToDotFileInFolder("txtfiles")
    ? read("../_data/techco.dot")
}
#-->
'
digraph "TechCo" {
    graph [rankdir=TB, bgcolor=white, fontname="helvetica", fontsize=12, splines=spline, nodesep=1, ranksep=1, ordering=out]
    node [fontname="helvetica", fontsize=12]
    edge [fontname="helvetica", fontsize=12, color="#808080", style=solid, penwidth=1, arrowhead=normal, arrowtail=none]

    ceo [label="CEO", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]
    vp1 [label="VP", shape=box, style="rounded,solid,filled", style="rounded,solid,filled", fillcolor="#FFFFFF", fontcolor="black", color="#808080"]

    ceo -> vp1

}
'

pf()

#===================#
#  EXPLAIN FEATURE  #
#===================#
