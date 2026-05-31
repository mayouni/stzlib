# Narrative
# --------
# #  Example 9: Order Processing Workflow  #
#
# Extracted from stzdotcodetest.ring, block #15.

load "../../../stzBase.ring"

#----------------------------------------#

pr()

Dot = GraphvizQ()

Dot.@('

digraph OrderWorkflow {
    # Overall graph styling
    graph [
        fontname="Arial",
        rankdir=LR,  # Left-to-right for process flow
        splines=spline,  # Smooth curves for natural flow
        ranksep=0.8
    ];

    # Default node styles
    node [
        fontname="Arial",
        shape=box,
        style="rounded,filled",
        colorscheme=ylgn9
    ];

    # Default edge styles
    edge [
        fontname="Arial",
        penwidth=2
    ];

    # Nodes with progressive colors
    Start [shape=circle, label="Order Received", fillcolor=1, fontcolor=white];
    Verify [label="Verify Payment", fillcolor=3];
    Pack [label="Pack Items", fillcolor=5];
    Ship [label="Ship Order", fillcolor=7];
    Decision [shape=diamond, label="In Stock?", fillcolor=9, fontcolor=white];
    EndSuccess [shape=doublecircle, label="Delivered", fillcolor=1, fontcolor=white];
    EndFail [shape=doublecircle, label="Refund Issued", fillcolor=9, fontcolor=white];

    # Edges with labels
    Start -> Verify [label="Step 1"];
    Verify -> Decision [label="Step 2"];
    Decision -> Pack [label="Yes"];
    Pack -> Ship [label="Step 3"];
    Ship -> EndSuccess [label="Complete"];
    Decision -> EndFail [label="No", style=dashed, color=red];

    # Cluster for core process
    subgraph cluster_main {
        label="Order Fulfillment";
        style=dashed;
        color=gray;
        Verify; Decision; Pack; Ship;
    }
}
')

Dot.SetOutputFormat("png")
Dot.ExecAndView()

pf()
# Executed in 0.59 second(s) in Ring 1.24
