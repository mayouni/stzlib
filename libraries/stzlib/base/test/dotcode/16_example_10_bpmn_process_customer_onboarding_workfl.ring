# Narrative
# --------
# #  Example 10: BPMN Process (Customer Onboarding Workflow)  #
#
# Extracted from stzdotcodetest.ring, block #16.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

#-----------------------------------------------------------#

pr()

Dot = new stzDotCode()

Dot.SetCode('

digraph CustomerOnboarding {
    # Overall graph styling
    graph [
        fontname="Verdana",
        rankdir=LR,
        splines=ortho,
        nodesep=0.6,
        ranksep=1.2,
        label="Customer Onboarding BPMN"
    ];

    # Default node styles
    node [
        fontname="Verdana",
        style=filled,
        colorscheme=purples9
    ];

    # Edges
    edge [
        arrowhead=normal,
        penwidth=1.8
    ];

    # BPMN-specific shapes
    StartEvent [shape=circle, label="Start", fillcolor=1, fontcolor=black];
    Register [shape=rect, label=<<TABLE BORDER="0"><TR><TD>Register Account</TD></TR><TR><TD><FONT POINT-SIZE="10">User submits form</FONT></TD></TR></TABLE>>, fillcolor=3];
    VerifyEmail [shape=rect, label=<<TABLE BORDER="0"><TR><TD>Verify Email</TD></TR><TR><TD><FONT POINT-SIZE="10">Send confirmation</FONT></TD></TR></TABLE>>, fillcolor=5];
    Gateway [shape=diamond, label="Approved?", fillcolor=7, fontcolor=white];
    Activate [shape=rect, label="Activate Profile", fillcolor=3];
    Reject [shape=rect, label="Reject & Notify", fillcolor=9, fontcolor=white];
    EndEvent [shape=doublecircle, label="End", fillcolor=1, fontcolor=black];

    # Connections
    StartEvent -> Register;
    Register -> VerifyEmail;
    VerifyEmail -> Gateway;
    Gateway -> Activate [label="Yes"];
    Gateway -> Reject [label="No", style=dashed];
    Activate -> EndEvent;
    Reject -> EndEvent;

    # Pools (clusters) for lanes
    subgraph cluster_user {
        label="User Lane";
        style=filled;
        fillcolor="#f3e5f5";  # Light purple
        Register; Activate;
    }

    subgraph cluster_system {
        label="System Lane";
        style=filled;
        fillcolor="#f3e5f5";
        VerifyEmail; Gateway; Reject;
    }
}
')

Dot.SetOutputFormat("svg")
Dot.ExecuteAndView()

pf()
# Executed in 0.46 second(s) in Ring 1.24
