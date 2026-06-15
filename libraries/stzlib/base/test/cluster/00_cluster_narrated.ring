load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for the cluster layer -- stzLoadBalancer
# (cluster registry + routing stats) and stzClusterNode (metrics + health).
# Deterministic.

Scenario("Load balancer defaults")
    Given("a fresh load balancer")
    o = new stzLoadBalancer()
    st = o.GetRoutingStats()
    Then("no requests yet", st[:total_requests], 0)
    Then("no clusters yet", st[:clusters_count], 0)
    Then("4 routing rules by default", st[:routing_rules], 4)
EndScenario()

Scenario("Register and find clusters")
    Given("a load balancer with one nlp cluster")
    o = new stzLoadBalancer()
    o.RegisterCluster("nlp", [ "node-1", "node-2" ])
    Then("clusters_count is 1", o.GetRoutingStats()[:clusters_count], 1)
    f = o.FindCluster("nlp")
    Then("the found cluster's type is nlp", f[:type], "nlp")
    Then("it has 2 nodes", len(f[:nodes]), 2)
    Then("an unknown cluster resolves to NULL", (o.FindCluster("unknown") = NULL), TRUE)
    When("the same type is registered again with more nodes")
    o.RegisterCluster("nlp", [ "node-1", "node-2", "node-3" ])
    Then("it replaces (no growth in count)", o.GetRoutingStats()[:clusters_count], 1)
    Then("the node set is now 3", len(o.FindCluster("nlp")[:nodes]), 3)
EndScenario()

Scenario("Node metrics, overload and health")
    Given("a math cluster node")
    n = new stzClusterNode("math", "math-1")
    n.UpdateMetrics(50, 10, 100)
    Then("a light load is not overloaded", n.IsOverloaded(), FALSE)
    When("metrics rise sharply")
    n.UpdateMetrics(90, 60, 250)
    Then("it reports overloaded", n.IsOverloaded(), TRUE)
    aH = n.GetHealthStatus()
    Then("health node_id is math-1", aH[:node_id], "math-1")
    Then("health cluster_type is math", aH[:cluster_type], "math")
    Then("health load is 90", aH[:load], 90)
EndScenario()

Summary()
