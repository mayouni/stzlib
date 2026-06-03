# Narrative
# --------
# #  Example 5: Modern Design  #
#
# Extracted from stzdotcodetest.ring, block #11.

load "../../stzBase.ring"

#----------------------------#

pr()

Dot = XDot()  # Using the XDot() function

Dot.SetCode('

digraph ModernDesign {
    # Overall graph styling
    graph [
        fontname="Helvetica",
        rankdir=LR, 		# Left-to-right layout
        ranksep=0.8 		# Increase spacing between ranks
    ];

    # Default node styles (add colorscheme here)
    node [
        fontname="Helvetica",
        shape=box,
        style="rounded,filled",
        colorscheme="rdylgn11"
    ];

    # Default edge styles
    edge [
        fontname="Helvetica",
        headport=w,	# Connect to the west side
        tailport=e	# Connect from the east side
    ];

    # Node definitions with color from scheme and adjusted text color for readability
    "Start" [fillcolor=1, fontcolor=white];
    "Process A" [fillcolor=3];
    "Process B" [fillcolor=5];
    "End" [fillcolor=1, fontcolor=white];
    
    # Edge definitions with specific styling
    "Start" -> "Process A" [label="First Step"];
    "Process A" -> "Process B" [label="Intermediate Step", style="dashed,bold"];
    "Process B" -> "End" [label="Final Step", style=solid, penwidth=2];
}
')

Dot.SetOutputFormat("svg")
Dot.RunAndView()

pf()
# Executed in 0.46 second(s) in Ring 1.24
