# Narrative
# --------
# # EXAMPLE 16: Clusters (Subgraphs)            #
#
# Extracted from stzdotcodetest.ring, block #23.

load "../../../stzBase.ring"

# Learn: cluster subgraphs, styling, nesting  #
#---------------------------------------------#

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

Dot.SetOutputFormat("svg")
Dot.ExecuteAndView()

pf()
# Executed in 0.50 second(s) in Ring 1.24
