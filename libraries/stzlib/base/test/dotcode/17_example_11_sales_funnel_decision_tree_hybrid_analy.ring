# Narrative
# --------
# #  Example 11: Sales Funnel Decision Tree (Hybrid Analytics Flow)  #
#
# Extracted from stzdotcodetest.ring, block #17.

load "../../stzBase.ring"

#------------------------------------------------------------------#

pr()

Dot = XDot()

Dot.SetCode('

digraph SalesFunnel {
    # Overall graph styling
    graph [
        fontname="Verdana",
        rankdir=TB,
        splines=curved,  # Curved edges for dynamic feel
        ranksep=1.0
    ];

    # Default node styles
    node [
        fontname="Vardana",
        shape=record,
        style=filled,
        colorscheme=oranges9
    ];

    # Edges
    edge [
        fontname="Verdana",
        style=bold
    ];

    # Nodes as records with metrics
    Lead [label="{Lead Generation | 1000 leads}", fillcolor=1, fontcolor=black];
    Qualify [label="{Qualify Prospects | 600 qualified (60%)}", fillcolor=3];
    Demo [label="{Product Demo | 300 attended (50%)}", fillcolor=5];
    Proposal [label="{Send Proposal | 150 accepted (50%)}", fillcolor=7];
    Close [label="{Close Deal | 75 won (50%)}", fillcolor=9, fontcolor=white];
    Lost [label="{Lost Opportunities | Analyze reasons}", fillcolor=9, fontcolor=white];

    # Decision branches
    Lead -> Qualify [label="Step 1"];
    Qualify -> Demo [label="Yes"];
    Qualify -> Lost [label="No", style=dashed, color=gray];
    Demo -> Proposal [label="Interested"];
    Demo -> Lost [label="Declined"];
    Proposal -> Close [label="Accepted"];
    Proposal -> Lost [label="Rejected"];

    # Cluster for funnel stages
    subgraph cluster_funnel {
        label="Sales Funnel Analytics";
        style=rounded;
        color=orange;
        Lead; Qualify; Demo; Proposal; Close;
    }
}
')

Dot.SetOutputFormat("svg")
Dot.SetVerbose(1)
Dot.RunXT()

pf()
# Executed in 0.46 second(s) in Ring 1.24
