# Narrative
# --------
# #  Example 8: Oraganization Chart  #
#
# Extracted from stzdotcodetest.ring, block #14.

load "../../../stzBase.ring"

#----------------------------------#

#NOTE Softanza has a dedicated stzOrgChart class, check it.

pr()

Dot = XDot()

Dot.SetCode('

digraph OrgChart {
    # Overall graph styling
    graph [
        fontname="Helvetica",
        rankdir=TB,	# Top-to-bottom for hierarchies
        splines=ortho,	# Straight, right-angle edges
        ranksep=1.0,
        nodesep=0.5
    ];

    # Default node styles
    node [
        fontname="Helvetica",
        shape=rect,
        style="rounded,filled",
        colorscheme=blues9,
        penwidth=1.5
    ];

    # Default edge styles
    edge [
        arrowhead=normal,
        penwidth=1.5
    ];

    # Nodes with colors and labels (darker for higher levels)
    CEO [label="CEO\nJohn Doe", fillcolor=8, fontcolor=white];
    CTO [label="CTO\nJane Smith", fillcolor=6];
    CFO [label="CFO\nAlex Lee", fillcolor=6];
    DevLead [label="Dev Lead\nSam Kim", fillcolor=4];
    QALead [label="QA Lead\nPat Chen", fillcolor=4];
    Accountant [label="Accountant\nRiley Wong", fillcolor=2];
    Auditor [label="Auditor\nTaylor Green", fillcolor=2];

    # Edges for hierarchy
    CEO -> {CTO, CFO};
    CTO -> {DevLead, QALead};
    CFO -> {Accountant, Auditor};

    # Clusters for departments
    subgraph cluster_tech {
        label="Technology Dept";
        style=filled;
        fillcolor="#f0f8ff";  # Light blue background
        CTO; DevLead; QALead;
    }

    subgraph cluster_finance {
        label="Finance Dept";
        style=filled;
        fillcolor="#f0f8ff";
        CFO; Accountant; Auditor;
    }
}
')

Dot.SetOutputformat("svg")
Dot.RunAndView()

pf()
# Executed in 0.55 second(s) in Ring 1.24
