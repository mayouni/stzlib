# Narrative
# --------
# # EXAMPLE 15: Rank and Ordering Control               #
#
# Extracted from stzdotcodetest.ring, block #22.

load "../../../stzBase.ring"

# Learn: rankdir, rank constraints, subgraph ranking  #
#-----------------------------------------------------#

#NOTE A good example of how an orgchart should be rendered
#NOTE See stzDiagram and stzOrgChart classes

pr()

Dot = XDot()
Dot.SetCode('
digraph Hierarchy {
    graph [rankdir=TB, splines=ortho, nodesep=0.6, ranksep=0.8]
    node [shape=box, style="rounded,filled", fontname="Arial"]
    edge [color=gray40, arrowsize=0.8]
    
    # Force same rank for specific nodes
    {rank=same; CEO}
    {rank=same; VP_Sales, VP_Eng, VP_Ops}
    {rank=same; Sales_A, Sales_B, Dev_A, Dev_B, Ops_A, Ops_B}
    
    CEO [fillcolor=gold, fontcolor=black, label="CEO"]
    
    VP_Sales [fillcolor=lightcoral, label="VP Sales"]
    VP_Eng [fillcolor=lightblue, label="VP Engineering"]
    VP_Ops [fillcolor=lightgreen, label="VP Operations"]
    
    Sales_A [fillcolor=mistyrose, label="Sales Rep A"]
    Sales_B [fillcolor=mistyrose, label="Sales Rep B"]
    Dev_A [fillcolor=lightcyan, label="Developer A"]
    Dev_B [fillcolor=lightcyan, label="Developer B"]
    Ops_A [fillcolor=honeydew, label="Ops Staff A"]
    Ops_B [fillcolor=honeydew, label="Ops Staff B"]
    
    CEO -> {VP_Sales, VP_Eng, VP_Ops} [penwidth=2]
    VP_Sales -> {Sales_A, Sales_B}
    VP_Eng -> {Dev_A, Dev_B}
    VP_Ops -> {Ops_A, Ops_B}
}
')

Dot.SetOutputFormat("svg")
Dot.ExecuteAndView()

pf()
# Executed in 0.50 second(s) in Ring 1.24
