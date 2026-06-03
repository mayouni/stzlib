# Narrative
# --------
# #  Example 4: Process Flow with Clusters  #
#
# Extracted from stzdotcodetest.ring, block #10.

load "../../stzBase.ring"

#-----------------------------------------#

pr()

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

Dot.SetOutputFormat("pdf")
Dot.Execute()

? "PDF created: " + Dot.OutputFile()
? Dot.Duration()
#--> PDF created: output\process_flow.pdf
#--> Duration: 0.78 second(s)

Dot.View()

pf()
# Executed in 0.53 second(s) in Ring 1.24
# Executed in 3.38 second(s) in Ring 1.24 (before using stzSystemCall class
