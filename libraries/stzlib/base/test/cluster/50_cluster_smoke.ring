load "../../stzBase.ring"

# stzLoadBalancer construction + default routing
# (Ring quirk: `new ClassName` without parens skips init; use `new ClassName()`.)
oLB = new stzLoadBalancer()
aStats = oLB.GetRoutingStats()
? aStats[:total_requests] = 0
? aStats[:clusters_count] = 0
? aStats[:routing_rules] = 4

# RegisterCluster: new cluster added
oLB.RegisterCluster("nlp", [ "node-1", "node-2" ])
? oLB.GetRoutingStats()[:clusters_count] = 1
aFound = oLB.FindCluster("nlp")
? aFound != NULL
? aFound[:type] = "nlp"
? len(aFound[:nodes]) = 2

# FindCluster: unknown -> NULL
? oLB.FindCluster("unknown") = NULL

# RegisterCluster: same cType replaces nodes (no growth)
oLB.RegisterCluster("nlp", [ "node-1", "node-2", "node-3" ])
? oLB.GetRoutingStats()[:clusters_count] = 1
aFound = oLB.FindCluster("nlp")
? len(aFound[:nodes]) = 3

# stzClusterNode metric update + overload threshold
oNode = new stzClusterNode("math", "math-1")
oNode.UpdateMetrics(50, 10, 100)
? oNode.IsOverloaded() = FALSE
oNode.UpdateMetrics(90, 60, 250)
? oNode.IsOverloaded() = TRUE

aH = oNode.GetHealthStatus()
? aH[:node_id] = "math-1"
? aH[:cluster_type] = "math"
? aH[:load] = 90

? "DONE 13"
