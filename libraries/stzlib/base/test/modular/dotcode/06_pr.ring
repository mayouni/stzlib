# Narrative
# --------
# pr()
#
# Extracted from stzdotcodetest.ring, block #6.

load "../../../stzBase.ring"


dot = new stzDotCode()

Dot.SetCode('
digraph G {
    # All processes: blue boxes
    node [shape=box, fillcolor=lightblue]
    process1; process2; process3
    
    # All decisions: gold diamonds
    node [shape=diamond, fillcolor=gold]
    decision1; decision2
    
    # All endpoints: circles
    node [shape=circle, fillcolor=green]
    start; end
}
')

Dot.RunAndView()

pf()
