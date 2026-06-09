# Narrative
# --------
# #  Example 2: Styled Graph  #
#
# Extracted from stzdotcodetest.ring, block #8.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

#---------------------------#

pr()

Dot = new stzdotCode()

Dot.SetCode('

digraph G {
    # Graph attributes
    graph [bgcolor=lightgray, rankdir=UD];

    # Node attributes (applied to all nodes by default)
    node [shape=box, style=filled, fontname="Helvetica", fillcolor=white];

    # Individual node definitions with specific attributes
    main [label="Start Process"];
    parse [label="Parse Input"];
    execute [shape=ellipse, fillcolor=lightblue];

    # Edge definitions with attributes
    main -> parse [label="Success", color=red];
    main -> execute [label="Execute Script", style=dashed];
    parse -> execute [label="Valid Data"];

} ')

Dot.SetOutputFormat("png")

Dot.Run()
Dot.View()

pf()
# Executed in 0.57 second(s) in Ring 1.24
