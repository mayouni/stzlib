# Narrative
# --------
# pr()
#
# Extracted from stzdotcodetest.ring, block #5.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

Dot = new stzDotCode()

Dot.SetCode('
digraph EdgeStyles {
    graph [rankdir=TB, nodesep=0.8]
    node [shape=box, style="rounded,filled", fillcolor=lightblue]
    
    A [label="Node A"]
    B [label="Node B"]
    C [label="Node C"]
    D [label="Node D"]
    
    # Normal solid edge
    A -> B [label="Normal"]
    
    # Dashed: optional or weak connection
    A -> C [label="Optional", style=dashed]
    
    # Bold: strong or primary path
    A -> D [label="Primary", style=bold, penwidth=3]
}
')

Dot.RunAndView()

pf()
