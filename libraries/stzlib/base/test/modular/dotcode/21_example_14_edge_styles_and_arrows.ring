# Narrative
# --------
# # EXAMPLE 14: Edge Styles and Arrows        #
#
# Extracted from stzdotcodetest.ring, block #21.

load "../../../stzBase.ring"

# Learn: Edge styling, arrow types, labels  #
#-------------------------------------------#

pr()

Dot = XDot()
Dot.SetCode('
digraph EdgeStyles {
    graph [rankdir=TB, bgcolor=white, nodesep=0.8]
    node [shape=box, style="rounded,filled", fillcolor=lightblue, fontname="Arial"]
    edge [fontname="Arial", fontsize=10]
    
    A [label="Node A"]
    B [label="Node B"]
    C [label="Node C"]
    D [label="Node D"]
    E [label="Node E"]
    F [label="Node F"]
    G [label="Node G"]
    H [label="Node H"]
    
    # Different arrow styles
    A -> B [label="normal", arrowhead=normal]
    A -> C [label="dot", arrowhead=dot]
    A -> D [label="diamond", arrowhead=diamond]
    
    B -> E [label="bold", style=bold, penwidth=2]
    C -> E [label="dashed", style=dashed]
    D -> E [label="dotted", style=dotted]
    
    # Bidirectional arrows
    E -> F [label="both", dir=both, arrowhead=normal, arrowtail=diamond]
    E -> G [label="back only", dir=back]
    E -> H [label="none", dir=none]
    
    # Special styling
    F -> H [label="red, thick", color=red, penwidth=3]
    G -> H [label="blue, curved", color=blue, style=curved]
}
')

Dot.SetOutputFormat("svg")
Dot.ExecuteAndView()

pf()
# Executed in 0.46 second(s) in Ring 1.24
