# Narrative
# --------
# All enhancements together
#
# Extracted from stzgraphextest.ring, block #24.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("Ultimate")
oGraph {
	AddNodeXT(:u1, "UserA", ["age" = 30, "role" = "admin"])
	AddNodeXT(:u2, "USERB", ["age" = 25, "role" = "user"])
	AddNodeXT(:u3, "userC", ["age" = 35, "role" = "ADMIN"])
	AddEdgeXT(:u1, :u2, "Manages")
	AddEdgeXT(:u2, :u3, "reports")
}

# Pattern with:
# - Property constraints (age > 28)
# - Case sensitivity (@cs:)
# - Alternation (Manages|reports)
# - Negation (@!)
oGx = new stzGraphex("{@Node{age:>:28} -> (@Edge(Manages)|@Edge(reports)) -> @!Node(error)}", oGraph)
oGx.EnableDebug()

? "=== Combined Test ==="
? "Match result: " + oGx.Match(oGraph)
? "Explanation: " + @@(oGx.Explain())
? "Cache stats: " + @@(oGx.CacheStats())

pf()
