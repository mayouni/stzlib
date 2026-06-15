load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzTree -- a named hierarchical tree
# of nodes and leaf items. Deterministic.

Scenario("Nodes, items and a specific node")
    Given("a 3-branch tree with a nested node11")
    o = Tree()
    Then("Nodes lists every named node in order", ListEq(o.Nodes(), [ "root", "node1", "node11", "node2", "node3" ]), TRUE)
    Then("Items flattens every leaf in order", ListEq(o.Items(), [ "X","A","B","C","D","X",1,2,3,"X",4,5 ]), TRUE)
    Then("Node(:node11) returns that node's items", ListEq(o.Node(:node11), [ "A","B","C","D","X" ]), TRUE)
EndScenario()

Scenario("Counts")
    Given("the same tree")
    o = Tree()
    Then("there are 5 nodes", len(o.Nodes()), 5)
    Then("there are 12 items", len(o.Items()), 12)
EndScenario()

Scenario("Branch paths")
    Given("the same tree")
    o = Tree()
    Then("Branches lists each node's full path", ListEq(o.Branches(), [ "[:root]", "[:root][:node1]", "[:root][:node1][:node11]", "[:root][:node2]", "[:root][:node3]" ]), TRUE)
EndScenario()

Summary()

func Tree()
    return new stzTree(:root = [
        :node1 = [ "X", :node11 = [ "A", "B", "C", "D", "X" ] ],
        :node2 = [ 1, 2, 3 ],
        :node3 = [ "X", 4, 5 ]
    ])

func ListEq aA, aE
    if len(aA) != len(aE) return FALSE ok
    nLen = len(aA)
    for i = 1 to nLen
        if isList(aA[i]) and isList(aE[i])
            if NOT ListEq(aA[i], aE[i]) return FALSE ok
        else
            if aA[i] != aE[i] return FALSE ok
        ok
    next
    return TRUE
