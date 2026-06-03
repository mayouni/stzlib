# Narrative
# --------
# # EXAMPLE 20: Network Topology             #
#
# Extracted from stzdotcodetest.ring, block #27.

load "../../stzBase.ring"

# Learn: Undirected graphs, edge styling   #
#------------------------------------------#

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

Dot.SetOutputFormat("svg")
Dot.ExecuteAndView()
? Dot.Duration()
#--> 0.97

pf()
# Executed in 0.56 second(s) in Ring 1.24
