#===========================================#
#  stzDotCode - Graphviz Integration Examples
#===========================================#
load "../stzbase.ring"

pr()

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

/*------------------
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
? Duration()
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

/*-----------------------------------------
#  Example 6: HTML-like Labels - Enhanced
#------------------------------------------

pr()

Dot = XDot()
Dot.SetCode('
digraph DataCard {
    graph [
        bgcolor="#F5F5F5"
        pad=0.5
    ]
    
    node [shape=plaintext]
    
    user_card [label=<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="8" BGCOLOR="white">
        <TR>
            <TD BGCOLOR="#1976D2" COLSPAN="2">
                <FONT COLOR="white" POINT-SIZE="14"><B>User Profile</B></FONT>
            </TD>
        </TR>
        <TR>
            <TD ALIGN="LEFT" BGCOLOR="#E3F2FD"><B>Name</B></TD>
            <TD ALIGN="LEFT" BGCOLOR="white">John Doe</TD>
        </TR>
        <TR>
            <TD ALIGN="LEFT" BGCOLOR="#E3F2FD"><B>Email</B></TD>
            <TD ALIGN="LEFT" BGCOLOR="white">john.doe@company.com</TD>
        </TR>
        <TR>
            <TD ALIGN="LEFT" BGCOLOR="#E3F2FD"><B>ID</B></TD>
            <TD ALIGN="LEFT" BGCOLOR="white">EMP-12345</TD>
        </TR>
        <TR>
            <TD ALIGN="LEFT" BGCOLOR="#E3F2FD"><B>Role</B></TD>
            <TD ALIGN="LEFT" BGCOLOR="white">Senior Developer</TD>
        </TR>
        <TR>
            <TD BGCOLOR="#4CAF50" COLSPAN="2">
                <FONT COLOR="white"><B>Status: Active</B></FONT>
            </TD>
        </TR>
    </TABLE>>]
}
')

Dot.SetOutputFile("enhanced_06_html_card.svg")
Dot.ExecuteAndView()

pf()
# Executed in 1.55 second(s) in Ring 1.24

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
#  Example 9: Order Processing Flow
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

/*--------------------------
#  Example 12: DSEQUENCE DIAGRAM
#---------------------------

pr()

Dot = new stzDotCode()
Dot.SetCode('

digraph SEQ_DIAGRAM {
    graph [overlap=true, splines=line, nodesep=1.0, ordering=out];
    edge [arrowhead=none];
    node [shape=none, width=0, height=0, label=""];

    {
        rank=same;
        node[shape=rectangle, height=0.7, width=2];
        api_a[label="API A"];
        api_b[label="API B"];
        api_c[label="API C"];
    }
    // Draw vertical lines
    {
        edge [style=dashed, weight=6];
        api_a -> a1 -> a2 -> a3;
        a3 -> a4 [penwidth=5, style=solid];
        a4 -> a5;
    }
    {
        edge [style=dashed, weight=6];
        api_b -> b1 -> b2 -> b3 -> b4;
        b4 -> b5 [penwidth=5; style=solid];
    }
    {
        edge [style=dashed, weight=6];
        api_c -> c1;
        c1-> c2 [penwidth=5, style=solid];
        c2 -> c3 -> c4 -> c5;
    }
    // Draws activations
    { rank=same; a1 -> b1 [label="activate()"]; b1 -> c1 [arrowhead=normal]; }
    { rank=same; a2 -> b2 [style=invis]; b2 -> c2 [label="refund()", arrowhead=normal, dir=back]; }
    { rank=same; a3 -> b3 [arrowhead=normal, dir=back, label="place_order()"]; b3 -> c3; }
    { rank=same; a4 -> b4 [label="distribute()", arrowhead=normal]; }
    { rank=same; a5 -> b5 [style=invis]; b5 -> c5 [label="bill_order()", arrowhead=normal]; }
}

')

Dot.Execute()
Dot.View()

#NOTE
# There are some important hints on how this was achieved:

# Each component have a list of nodes which have no shape,
# no height and no width.
#
# Each line must be at the same rank, otherwise DOT will position
# them accordingly to their automatic ranking.

# In order to make things straight, all directions are the same:
# from a to b to c. If you invert some of them, DOT will make a mess.
# The trick to achieve the right direction on the arrow is to use dir
# edge attribute.

# Weight attribute on edges is very important to keep vertical
# lines straight. They must outnumber the biggest rank. If you need
# to create a diagram where a rank will go as deep as 100, your weight
# must be 101 at least or it will be impossible to have a straight
# dashed vertical line.

# In order to get a straigh horizontal line, you have to connect each
# node on the same rank. Otherwise, DOT will bend the line. For instance,
# connecting a1 to c1 is achieved by connecting a1 to b1 and b1 to c1.


pf()
# Executed in 1.01 second(s) in Ring 1.24

#===========================================#
#  Advanced Graphviz DOT Language Examples
#  Master Graphviz through progressive examples
#===========================================#
*
/*-----------------------------------------
# EXAMPLE 13: Node Shapes Gallery
# Learn: Different node shapes, styling basics
#-----------------------------------------

pr()

Dot = XDot()
Dot.SetCode('
digraph NodeShapes {
    graph [rankdir=LR, bgcolor=white, splines=ortho]
    node [style=filled, fontname="Arial"]
    
    # Basic shapes
    box [shape=box, fillcolor=lightblue, label="box"]
    circle [shape=circle, fillcolor=lightgreen, label="circle"]
    ellipse [shape=ellipse, fillcolor=lightyellow, label="ellipse"]
    diamond [shape=diamond, fillcolor=pink, label="diamond"]
    
    # Polygon shapes
    pentagon [shape=pentagon, fillcolor=lavender, label="pentagon"]
    hexagon [shape=hexagon, fillcolor=lightcoral, label="hexagon"]
    octagon [shape=octagon, fillcolor=lightgray, label="octagon"]
    
    # Special shapes
    record [shape=record, fillcolor=wheat, label="{Record|{Left|Right}}"]
    note [shape=note, fillcolor=lightyellow, label="note"]
    tab [shape=tab, fillcolor=lightsteelblue, label="tab"]
    
    # Flow chart shapes
    start [shape=circle, fillcolor=green, fontcolor=white, label="Start"]
    process [shape=box, fillcolor=skyblue, label="Process"]
    decision [shape=diamond, fillcolor=gold, label="Decision?"]
    end [shape=doublecircle, fillcolor=red, fontcolor=white, label="End"]
    
    # Connect them in logical groups
    {box, circle, ellipse, diamond} -> pentagon [style=invis]
    pentagon -> {hexagon, octagon} [style=invis]
    {record, note, tab} -> start [style=invis]
    start -> process -> decision -> end
}
')

Dot.SetOutputFile("01_node_shapes.svg")
Dot.ExecuteAndView()

pf()
# Executed in 1.45 second(s) in Ring 1.24

/*-----------------------------------------
# EXAMPLE 14: Edge Styles and Arrows
# Learn: Edge styling, arrow types, labels
#-----------------------------------------

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

Dot.SetOutputFile("02_edge_styles.svg")
Dot.ExecuteAndView()

pf()

/*-----------------------------------------
# EXAMPLE 15: Rank and Ordering Control
# Learn: rankdir, rank constraints, subgraph ranking
#-----------------------------------------

pr()

Dot = XDot()
Dot.SetCode('
digraph Hierarchy {
    graph [rankdir=TB, splines=ortho, nodesep=0.6, ranksep=0.8]
    node [shape=box, style="rounded,filled", fontname="Arial"]
    edge [color=gray40, arrowsize=0.8]
    
    # Force same rank for specific nodes
    {rank=same; CEO}
    {rank=same; VP_Sales, VP_Eng, VP_Ops}
    {rank=same; Sales_A, Sales_B, Dev_A, Dev_B, Ops_A, Ops_B}
    
    CEO [fillcolor=gold, fontcolor=black, label="CEO"]
    
    VP_Sales [fillcolor=lightcoral, label="VP Sales"]
    VP_Eng [fillcolor=lightblue, label="VP Engineering"]
    VP_Ops [fillcolor=lightgreen, label="VP Operations"]
    
    Sales_A [fillcolor=mistyrose, label="Sales Rep A"]
    Sales_B [fillcolor=mistyrose, label="Sales Rep B"]
    Dev_A [fillcolor=lightcyan, label="Developer A"]
    Dev_B [fillcolor=lightcyan, label="Developer B"]
    Ops_A [fillcolor=honeydew, label="Ops Staff A"]
    Ops_B [fillcolor=honeydew, label="Ops Staff B"]
    
    CEO -> {VP_Sales, VP_Eng, VP_Ops} [penwidth=2]
    VP_Sales -> {Sales_A, Sales_B}
    VP_Eng -> {Dev_A, Dev_B}
    VP_Ops -> {Ops_A, Ops_B}
}
')

Dot.SetOutputFile("03_hierarchy_ranks.svg")
Dot.ExecuteAndView()

pf()
# Executed in 1.50 second(s) in Ring 1.24

/*-----------------------------------------
# EXAMPLE 16: Clusters (Subgraphs)
# Learn: cluster subgraphs, styling, nesting
#-----------------------------------------

pr()

Dot = XDot()
Dot.SetCode('
digraph Clusters {
    graph [fontname="Arial", compound=true, splines=spline]
    node [shape=box, style="rounded,filled", fontname="Arial"]
    edge [fontname="Arial"]
    
    subgraph cluster_frontend {
        label="Frontend Layer"
        style=filled
        fillcolor=lightblue
        color=blue
        
        UI [label="User Interface", fillcolor=skyblue]
        Controller [label="Controller", fillcolor=skyblue]
        UI -> Controller
    }
    
    subgraph cluster_backend {
        label="Backend Layer"
        style=filled
        fillcolor=lightgreen
        color=green
        
        API [label="REST API", fillcolor=palegreen]
        Logic [label="Business Logic", fillcolor=palegreen]
        API -> Logic
    }
    
    subgraph cluster_data {
        label="Data Layer"
        style=filled
        fillcolor=lightyellow
        color=orange
        
        Cache [label="Redis Cache", fillcolor=khaki]
        DB [label="PostgreSQL", fillcolor=khaki]
        Cache -> DB [style=dashed, label="fallback"]
    }
    
    # Cross-cluster connections
    Controller -> API [lhead=cluster_backend, label="HTTP"]
    Logic -> Cache [lhead=cluster_data, label="query"]
}
')

Dot.SetOutputFile("04_clusters.svg")
Dot.ExecuteAndView()

pf()
# Executed in 1.35 second(s) in Ring 1.24

/*-----------------------------------------
# EXAMPLE 17: Record Shapes (Tables)
# Learn: Record nodes, ports, complex structures
#-----------------------------------------

pr()

Dot = XDot()
Dot.SetCode('
digraph Records {
    graph [rankdir=LR, bgcolor=white]
    node [fontname="Courier New", fontsize=10]
    
    # Struct-like records
    struct1 [shape=record, label="<f0> left|<f1> mid|<f2> right"]
    struct2 [shape=record, label="<f0> one|<f1> two"]
    struct3 [shape=record, label="<f0> hello|<f1> world"]
    
    # More complex record
    class [shape=record, style=filled, fillcolor=lightblue,
           label="{<name> User|<attrs> - id: int\l- name: string\l- email: string\l|<methods> + login()\l+ logout()\l}"]
    
    # Nested records (like linked list)
    node1 [shape=record, label="<data> 42|<next>"]
    node2 [shape=record, label="<data> 17|<next>"]
    node3 [shape=record, label="<data> 89|<next>"]
    
    # Connect to specific ports
    struct1:f0 -> struct2:f1
    struct1:f1 -> struct3:f0
    struct1:f2 -> struct2:f0
    
    # Linked list
    node1:next -> node2:data
    node2:next -> node3:data
    node3:next -> node1:data [style=dashed, label="circular"]
    
    # Separate the examples visually
    {struct1, struct2, struct3} -> class [style=invis]
    class -> node1 [style=invis]
}
')

Dot.SetOutputFile("05_records.svg")
Dot.ExecuteAndView()


pf()
# Executed in 1.56 second(s) in Ring 1.24

/*-----------------------------------------
# EXAMPLE 18: Color Schemes
# Learn: Color schemes, gradients, palettes
#-----------------------------------------

pr()

Dot = XDot()
Dot.SetCode('
digraph ColorSchemes {
    graph [rankdir=LR, bgcolor=gray95]
    node [shape=box, style="rounded,filled", fontname="Arial", width=1.2]
    
    # Blues scheme
    subgraph cluster_blues {
        label="Blues Palette"
        style=filled
        fillcolor=white
        
        node [colorscheme=blues9]
        b1 [fillcolor=1, label="1"]
        b3 [fillcolor=3, label="3"]
        b5 [fillcolor=5, label="5"]
        b7 [fillcolor=7, label="7", fontcolor=white]
        b9 [fillcolor=9, label="9", fontcolor=white]
        
        b1 -> b3 -> b5 -> b7 -> b9 [style=invis]
    }
    
    # Reds scheme
    subgraph cluster_reds {
        label="Reds Palette"
        style=filled
        fillcolor=white
        
        node [colorscheme=reds9]
        r1 [fillcolor=1, label="1"]
        r3 [fillcolor=3, label="3"]
        r5 [fillcolor=5, label="5"]
        r7 [fillcolor=7, label="7", fontcolor=white]
        r9 [fillcolor=9, label="9", fontcolor=white]
        
        r1 -> r3 -> r5 -> r7 -> r9 [style=invis]
    }
    
    # Greens scheme
    subgraph cluster_greens {
        label="Greens Palette"
        style=filled
        fillcolor=white
        
        node [colorscheme=greens9]
        g1 [fillcolor=1, label="1"]
        g3 [fillcolor=3, label="3"]
        g5 [fillcolor=5, label="5"]
        g7 [fillcolor=7, label="7", fontcolor=white]
        g9 [fillcolor=9, label="9", fontcolor=white]
        
        g1 -> g3 -> g5 -> g7 -> g9 [style=invis]
    }
}
')

Dot.SetOutputFile("06_color_schemes.svg")
Dot.ExecuteAndView()

? Dot.Duration()
#--> 0.92 second(s)

pf()
# Executed in 1.48 second(s) in Ring 1.24

/*-----------------------------------------
# EXAMPLE 19: State Machine
# Learn: Practical application of shapes and styles
#-----------------------------------------

pr()

Dot = XDot()
Dot.SetCode('
digraph StateMachine {
    graph [rankdir=LR, bgcolor=white, fontname="Arial"]
    node [fontname="Arial", style=filled]
    edge [fontname="Arial", fontsize=10]
    
    # Special states
    start [shape=circle, fillcolor=black, width=0.3, label=""]
    end [shape=doublecircle, fillcolor=black, width=0.3, label=""]
    
    # Regular states
    idle [shape=circle, fillcolor=lightblue, label="Idle"]
    processing [shape=circle, fillcolor=yellow, label="Processing"]
    waiting [shape=circle, fillcolor=orange, label="Waiting"]
    complete [shape=circle, fillcolor=lightgreen, label="Complete"]
    error [shape=circle, fillcolor=red, fontcolor=white, label="Error"]
    
    # Transitions
    start -> idle [label="init"]
    idle -> processing [label="start()"]
    processing -> waiting [label="wait_for_input()"]
    processing -> complete [label="success"]
    processing -> error [label="exception"]
    waiting -> processing [label="input_received()"]
    waiting -> error [label="timeout"]
    error -> idle [label="retry()", style=dashed]
    complete -> end [label="finalize"]
    
    # Self-loop
    idle -> idle [label="ping()", style=dotted]
}
')

Dot.SetOutputFile("07_state_machine.svg")
Dot.ExecuteAndView()
? Dot.Duration()
#--> 0.95

pf()
# Executed in 1.52 second(s) in Ring 1.24

/*-----------------------------------------
# EXAMPLE 20: Network Topology
# Learn: Undirected graphs, edge styling
#-----------------------------------------

pr()

Dot = XDot()
Dot.SetCode('
graph Network {
    graph [bgcolor=white, fontname="Arial"]
    node [shape=box, style="rounded,filled", fontname="Arial"]
    edge [fontname="Arial", fontsize=9]
    
    # Core routers
    R1 [label="Core Router 1", fillcolor=gold, shape=cylinder]
    R2 [label="Core Router 2", fillcolor=gold, shape=cylinder]
    
    # Distribution switches
    S1 [label="Switch 1", fillcolor=lightblue]
    S2 [label="Switch 2", fillcolor=lightblue]
    S3 [label="Switch 3", fillcolor=lightblue]
    
    # Servers
    WEB [label="Web Server", fillcolor=lightgreen, shape=box3d]
    APP [label="App Server", fillcolor=lightgreen, shape=box3d]
    DB [label="Database", fillcolor=red, fontcolor=white, shape=cylinder]
    
    # Workstations
    PC1 [label="PC-01", fillcolor=lightyellow, shape=component]
    PC2 [label="PC-02", fillcolor=lightyellow, shape=component]
    PC3 [label="PC-03", fillcolor=lightyellow, shape=component]
    
    # Core connections (high bandwidth)
    R1 -- R2 [label="10G", penwidth=3, color=darkgreen]
    
    # Distribution
    R1 -- {S1, S2} [label="1G", penwidth=2]
    R2 -- {S2, S3} [label="1G", penwidth=2]
    
    # Server connections
    S1 -- {WEB, APP} [label="1G"]
    S2 -- DB [label="1G"]
    
    # Workstation connections
    S3 -- {PC1, PC2, PC3} [label="100M", style=dashed]
}
')

Dot.SetOutputFile("08_network.svg")
Dot.ExecuteAndView()
? Dot.Duration()
#--> 0.97

pf()
# Executed in 1.55 second(s) in Ring 1.24

/*-----------------------------------------
# EXAMPLE 21: Decision Tree
# Learn: Tree structures, styling for clarity
#-----------------------------------------

pr()

Dot = XDot()
Dot.SetCode('
digraph DecisionTree {
    graph [rankdir=TB, bgcolor=white]
    node [fontname="Arial"]
    edge [fontname="Arial", fontsize=10]
    
    # Decision nodes
    node [shape=diamond, style=filled, fillcolor=lightyellow]
    root [label="Credit Score\n> 700?"]
    income [label="Annual Income\n> $50k?"]
    history [label="Payment History\nClean?"]
    
    # Outcome nodes
    node [shape=box, style="rounded,filled"]
    approve_instant [fillcolor=darkgreen, fontcolor=white, label="Approve\nInstantly"]
    approve_review [fillcolor=lightgreen, label="Approve with\nManual Review"]
    deny_income [fillcolor=orange, label="Deny\n(Low Income)"]
    deny_history [fillcolor=red, fontcolor=white, label="Deny\n(Bad History)"]
    deny_score [fillcolor=red, fontcolor=white, label="Deny\n(Low Score)"]
    
    # Tree structure
    root -> income [label="Yes", color=green]
    root -> history [label="No", color=red]
    
    income -> approve_instant [label="Yes", color=green]
    income -> deny_income [label="No", color=red]
    
    history -> approve_review [label="Yes", color=green]
    history -> deny_history [label="No", color=red]
    
    root -> deny_score [label="< 600", color=darkred, style=bold]
}
')

Dot.SetOutputFile("09_decision_tree.svg")
Dot.ExecuteAndView()

pf()
# Executed in 1.49 second(s) in Ring 1.24

/*-----------------------------------------
# EXAMPLE 22: Timeline/Gantt-style
# Learn: Creative use of ranks and shapes
#-----------------------------------------

pr()

Dot = XDot()
Dot.SetCode('
digraph Timeline {
    graph [rankdir=LR, bgcolor=white, splines=line]
    node [fontname="Arial", shape=box, style="rounded,filled"]
    edge [arrowhead=none, penwidth=2]
    
    # Time markers
    {rank=same; t1, t2, t3, t4, t5}
    node [shape=plaintext, fillcolor=none]
    t1 [label="Week 1"]
    t2 [label="Week 2"]
    t3 [label="Week 3"]
    t4 [label="Week 4"]
    t5 [label="Week 5"]
    
    t1 -> t2 -> t3 -> t4 -> t5 [style=invis]
    
    # Tasks
    node [shape=box, style="rounded,filled"]
    
    {rank=same; t1, planning}
    planning [fillcolor=lightblue, label="Planning\n& Design"]
    
    {rank=same; t2, dev1}
    dev1 [fillcolor=lightgreen, label="Development\nPhase 1"]
    
    {rank=same; t3, dev2}
    dev2 [fillcolor=lightgreen, label="Development\nPhase 2"]
    
    {rank=same; t4, testing}
    testing [fillcolor=yellow, label="Testing\n& QA"]
    
    {rank=same; t5, deploy}
    deploy [fillcolor=orange, label="Deployment\n& Launch"]
    
    # Dependencies
    planning -> dev1 [penwidth=2, color=gray40]
    dev1 -> dev2 [penwidth=2, color=gray40]
    dev2 -> testing [penwidth=2, color=gray40]
    testing -> deploy [penwidth=2, color=gray40]
}
')

Dot.SetOutputFile("10_timeline.svg")
Dot.ExecuteAndView()

pf()

#===========================================#
#  Professional BPMN Order Processing Flow
#===========================================#

pr()

Dot = XDot()

Dot.SetCode('
digraph BPMN_OrderProcessing {
    graph [
        rankdir=TB
        bgcolor="white"
        fontname="Arial"
        splines=ortho
        pad=0.4
        nodesep=0.4
        ranksep=0.8
    ]
    
    node [fontname="Arial" fontsize=10]
    edge [fontname="Arial" fontsize=9 penwidth=1.5]
    
    # LANE HEADERS
    lane_sales [shape=plaintext label="Sales" fontsize=11]
    lane_finance [shape=plaintext label="Finance" fontsize=11]
    lane_warehouse [shape=plaintext label="Warehouse" fontsize=11]
    
    # LANE 1: Sales
    start [shape=circle label="" fillcolor=black width=0.35 fixedsize=true]
    receive_order [shape=box style="rounded,filled" fillcolor=white color=black label="Receive Order" width=1.5 height=0.5]
    {rank=same; lane_sales; start; receive_order}
    start -> receive_order
    
    # Divider 1
    div1a [shape=plaintext label=""]
    div1b [shape=plaintext label=""]
    div1c [shape=plaintext label=""]
    {rank=same; div1a; div1b; div1c}
    
    # LANE 2: Finance  
    check_credit [shape=box style="rounded,filled" fillcolor=white color=black label="Check Credit" width=1.3 height=0.5]
    credit_gateway [shape=diamond fillcolor=white color=black label="Credit\nok?" width=1.1 height=1.0]
    send_invoice [shape=box style="rounded,filled" fillcolor=white color=black label="Send Invoice" width=1.3 height=0.5]
    {rank=same; lane_finance; check_credit; credit_gateway; send_invoice}
    check_credit -> credit_gateway
    credit_gateway -> send_invoice [label="Yes" fontsize=8]
    
    # Divider 2
    div2a [shape=plaintext label=""]
    div2b [shape=plaintext label=""]
    div2c [shape=plaintext label=""]
    {rank=same; div2a; div2b; div2c}
    
    # LANE 3: Warehouse
    fulfill_order [shape=box style="rounded,filled" fillcolor=white color=black label="Fulfill Order" width=1.3 height=0.5]
    fulfill_gateway [shape=diamond fillcolor=white color=black label="Fulfilled\nok?" width=1.1 height=1.0]
    complete_end [shape=circle label="" fillcolor=black width=0.35 fixedsize=true]
    failed_end [shape=circle label="" fillcolor=black width=0.35 fixedsize=true]
    {rank=same; lane_warehouse; fulfill_order; fulfill_gateway; complete_end; failed_end}
    fulfill_order -> fulfill_gateway
    fulfill_gateway -> complete_end [label="Yes" fontsize=8 style=dashed]
    fulfill_gateway -> failed_end [label="No" fontsize=8 style=dashed]
    
    # Cross-lane flows
    receive_order -> check_credit
    send_invoice -> fulfill_order
    credit_gateway -> failed_end [label="No" fontsize=8 style=dashed constraint=false]
}
')

Dot.SetOutputFile("bpmn_order_processing.svg")
Dot.ExecuteAndView()

pf()

#===========================================#
#  BPMN Order Processing with Lane Colors
#===========================================#
*/
pr()

Dot = XDot()

Dot.SetCode('
digraph BPMN_OrderProcessing {
    graph [
        rankdir=TB
        bgcolor="white"
        fontname="Arial"
        splines=ortho
        pad=0.4
        nodesep=0.4
        ranksep=0.8
    ]
    
    node [fontname="Arial" fontsize=10]
    edge [fontname="Arial" fontsize=9 penwidth=1.5]
    
    # LANE HEADERS
    lane_sales [shape=plaintext label="Sales" fontsize=11]
    lane_finance [shape=plaintext label="Finance" fontsize=11]
    lane_warehouse [shape=plaintext label="Warehouse" fontsize=11]
    
    # LANE 1: Sales
    start [shape=circle label="" fillcolor=black width=0.35 fixedsize=true]
    receive_order [shape=box style="rounded,filled" fillcolor=white color=black label="Receive Order" width=1.5 height=0.5]
    {rank=same; lane_sales; start; receive_order}
    start -> receive_order
    
    # Divider 1
    div1a [shape=plaintext label=""]
    div1b [shape=plaintext label=""]
    div1c [shape=plaintext label=""]
    {rank=same; div1a; div1b; div1c}
    
    # LANE 2: Finance  
    check_credit [shape=box style="rounded,filled" fillcolor=white color=black label="Check Credit" width=1.3 height=0.5]
    credit_gateway [shape=diamond fillcolor=white color=black label="Credit\nok?" width=1.1 height=1.0]
    send_invoice [shape=box style="rounded,filled" fillcolor=white color=black label="Send Invoice" width=1.3 height=0.5]
    {rank=same; lane_finance; check_credit; credit_gateway; send_invoice}
    check_credit -> credit_gateway
    credit_gateway -> send_invoice [label="Yes" fontsize=8]
    
    # Divider 2
    div2a [shape=plaintext label=""]
    div2b [shape=plaintext label=""]
    div2c [shape=plaintext label=""]
    {rank=same; div2a; div2b; div2c}
    
    # LANE 3: Warehouse
    failed_end [shape=circle label="" fillcolor=black width=0.35 fixedsize=true]
    fulfill_order [shape=box style="rounded,filled" fillcolor=white color=black label="Fulfill Order" width=1.3 height=0.5]
    fulfill_gateway [shape=diamond fillcolor=white color=black label="Fulfilled\nok?" width=1.1 height=1.0]
    complete_end [shape=circle label="" fillcolor=black width=0.35 fixedsize=true]
    {rank=same; lane_warehouse; failed_end; fulfill_order; fulfill_gateway; complete_end}
    fulfill_order -> fulfill_gateway
    fulfill_gateway -> complete_end [label="Yes" fontsize=8]
    fulfill_gateway -> failed_end [label="No" fontsize=8 style=dashed]
    
    # Cross-lane flows
    receive_order -> check_credit
    send_invoice -> fulfill_order
    credit_gateway -> failed_end [label="No" fontsize=8 style=dashed]
}
')

Dot.SetOutputFile("bpmn_order_processing.svg")
Dot.ExecuteAndView()

pf()
