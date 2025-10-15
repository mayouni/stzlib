#===========================================#
#  stzDotCode - Graphviz Integration Examples
#===========================================#
load "../stzbase.ring"

/*-------------------
#  Example 1: Basic
#-------------------

pr()

Dot = new stzDotCode()

Dot.SetCode('
	# This is my first Graphviz diagram
	digraph G {
	    a -> b;
	    b -> c;
	    a -> c;
	}
')

Dot.SetOutputFile("graph1.svg")
Dot.ExecuteAndView()

# Duration in seconds
? Dot.Duration()
#--> 0.72 second(s)

pf()
# Executed in 0.73 second(s) in Ring 1.24

/*-------------------------------#
#  Example 2: Styled Graph
#-------------------------------#

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

Dot.SetOutputFile("graph2.png")
Dot.SetOutputFormat("png")

Dot.Run()
Dot.View()

pf()
# Executed in 1.35 second(s) in Ring 1.24

/*--------------------------------
#  Example 3: System Architecture
#---------------------------------

pr()

Dot = XDot()  # Using the XDot() function

Dot.SetCode('
digraph {
  rankdir=LR
  node [shape=box]
  edge [headport=w, tailport=e]
  node [fontname="Courier New"]
  node [style=filled colorscheme=dark26]
  ranksep=0.8

  client [label="Client", color=1, group=main]
  lb [label="Load balancer", color=2, group=main]
  backend1 [label="Backend", color=3]
  backend2 [label="Backend", color=3, group=main]
  backend3 [label="Backend", color=3]
  db [label="DB", color=4]
  cache [label="Cache", color=5, group=main]
  streamer [label="Streamer", color=6, group=main]

  subgraph f {
    rank=same
    edge [style=invis, headport=s, tailport=n]
    backend1 -> backend2 -> backend3
  }

  client -> lb
  lb -> {backend1, backend2, backend3}
  {backend1, backend2, backend3} -> db
  {backend1, backend2, backend3} -> cache
  cache -> streamer [weight=1]
  streamer:n -> client:n [weight=0]
}
')

Dot.SetOutputFile("architecture.svg")
Dot.SetVerbose(1)
Dot.ExecuteAndView()

#--> The diagram is dispalyed in your default browser (or svg viewer)
#-->
'
Command: D:\Graphviz\bin\dot.exe -Tsvg temp\temp.dot -o output\architecture.svg > temp\dotlog.txt 2>&1
Output file: output\architecture.svg
Log: ""
'

pf()

#----------------------------------------
#  Example 4: Process Flow with Clusters
#----------------------------------------

Dot = GraphvizQ()  # Using the Graphviz() function

Dot.@('

digraph ProcessFlow {
    # Overall graph settings
    graph [bgcolor=white, fontname="Helvetica", labelloc=t, label="Two-Stage Process"];
    
    # Default node style
    node [shape=box, style="rounded,filled", fillcolor="lightgrey", fontname="Helvetica"];
    
    # Cluster for Stage 1
    subgraph cluster_stage1 {
        label = "Stage 1: Input and Processing";
        style = filled;
        color = "lightblue";
        
        start [label="Input File"];
        validate [label="Validate Data"];
        transform [label="Transform Data"];
        
        start -> validate;
        validate -> transform;
    }
    
    # Cluster for Stage 2
    subgraph cluster_stage2 {
        label = "Stage 2: Analysis and Output";
        style = filled;
        color = "lightgreen";
        
        analyze [label="Run Analysis"];
        report [label="Generate Report"];
        store [label="Store in DB"];
        
        transform -> analyze;
        analyze -> report;
        report -> store;
    }
    
    # Critical Path
    start -> store [style=bold, color=darkgreen, penwidth=2, label="Full Flow"];
}
')

Dot.SetOutputFile("process_flow.pdf")
Dot.SetOutputFormat("pdf")
Dot.Execute()

? "PDF created: " + Dot.OutputFile()
? "Duration: " + Dot.Duration() + " second(s)"
#--> PDF created: output\process_flow.pdf
#--> Duration: 0.78 second(s)

Dot.View()

pf()
# Executed in 3.38 second(s) in Ring 1.24

/*--------------------------#
#  Example 5: Modern Design
#---------------------------#

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

Dot.SetOutputFile("modern_design.svg")
Dot.RunAndView()

#TODO Check why colors are not printed

pf()
# Executed in 1.06 second(s) in Ring 1.24

/*-----------------------------
#  Example 6: HTML-like Labels
#------------------------------

Dot = new stzDotCode()

Dot.@('

digraph HTMLNode {
    node [shape=plaintext];
    
    table_node [label=<<table border="0" cellborder="1" cellspacing="0">
        <tr><td bgcolor="black"><font color="white"><b>User Details</b></font></td></tr>
        <tr><td port="name">John Doe</td></tr>
        <tr><td port="email">john.doe@example.com</td></tr>
        <tr><td port="id">ID: 12345</td></tr>
    </table>>];
}
')

Dot.SetOutputFile("html_node.png")
Dot.SetOutputFormat("png")
Dot.ExecAndShow()

pf()
# Executed in 3.64 second(s) in Ring 1.24

#-------------------------------#
#  Example 7: Error Handling
#-------------------------------#

pr()

Dot = new stzDotCode()

Dot.SetCode('
digraph Invalid {
    # Missing closing brace to demonstrate error handling
    a -> b
')  # Intentionally invalid DOT code

try
	Dot.Execute()
catch
	? "Caught error as expected:"
	? CatchError()
	? ""
	? "Log file content:"
	? Dot.Log()
done

? ""
? "Cleanup demonstration..."
Dot.CleanupAll()
? "Temporary files cleaned up."

pf()
# Executed in 0.34 second(s) in Ring 1.24

#---------------------------------
#  Example 8: Oraganization Chart
#---------------------------------

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

Dot.SetOutputFile("org_chart.svg")
Dot.RunAndView()

pf()
# Executed in 1.07 second(s) in Ring 1.24

#------------------------------------
#  Example 8: Order Processing Flow
#------------------------------------

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

Dot.SetOutputFile("order_workflow.png")
Dot.SetOutputFormat("png")
Dot.ExecAndShow()

pf()
# Executed in 1.40 second(s) in Ring 1.24

#-------------------------------------------------
#  Example 10: BPMN Process (Customer Onboarding)
#-------------------------------------------------

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
    StartEvent [shape=circle, label="Start", fillcolor=1, fontcolor=white];
    Register [shape=rect, label=<<TABLE BORDER="0"><TR><TD>Register Account</TD></TR><TR><TD><FONT POINT-SIZE="10">User submits form</FONT></TD></TR></TABLE>>, fillcolor=3];
    VerifyEmail [shape=rect, label=<<TABLE BORDER="0"><TR><TD>Verify Email</TD></TR><TR><TD><FONT POINT-SIZE="10">Send confirmation</FONT></TD></TR></TABLE>>, fillcolor=5];
    Gateway [shape=diamond, label="Approved?", fillcolor=7, fontcolor=white];
    Activate [shape=rect, label="Activate Profile", fillcolor=3];
    Reject [shape=rect, label="Reject & Notify", fillcolor=9, fontcolor=white];
    EndEvent [shape=doublecircle, label="End", fillcolor=1, fontcolor=white];

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

Dot.SetOutputFile("bpmn_onboarding.svg")
Dot.ExecuteAndView()

pf()
# Executed in ~0.95 second(s) in Ring 1.24

#-----------------------------------------------------------------
#  Example 11: Sales Funnel Decision Tree (Hybrid Analytics Flow)
#-----------------------------------------------------------------

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

Dot.SetOutputFile("sales_funnel.svg")
Dot.SetVerbose(1)
Dot.RunXT()

pf()
# Executed in ~1.05 second(s) in Ring 1.24

/*===

StzWorkflowQ() {

	AllBoxesAre = "Round"
	AllLinksAre = "Black"

	# Defining nodes
	Node("Start") { Color = [ "White", "DarkRed" ] }
	Node("Process A") { Color = [ "Black", "Orange" ] }
	Node("Process B") { Color = [ "Black", "Yellow" ] }
	Node("End") { Color = [ "Black", "DarkRed" ] }

	# Defining edges
	Edge("Start", "Process A") { :Label = "First Step" }
	Edge("Process A", "Process B") { :Label = "Intermediate Step" Line = "Dashed" }
	Edge("Process B", "End") { :Label = "Final Step" }

	Show()
}
