load "../stzbase.ring"

#============================#
#  ENHANCEMENT 1: PREFIX ORDERING TESTS
#============================#

/*--- Test longer token prefixes parsed correctly

pr()

oGraph = new stzGraph("Props")
oGraph {
	AddNodeXT(:a, "Start", ["type" = "entry", "priority" = 1])
	AddNodeXT(:b, "End", ["type" = "exit"])
	AddEdgeXT(:a, :b, "flows")
}

# Test @NodeProperty (longer prefix) vs @Node
oGx = new stzGraphex("{@NodeProperty(type)}", oGraph)
oGx.EnableDebug()
? oGx.Match(oGraph)
#--> Should parse as "nodeproperty" not "node"

pf()

/*--- Test @EdgeProperty vs @Edge

pr()

oGraph = new stzGraph("EdgeProps")
oGraph {
	AddNodeXT(:a, "A")
	AddNodeXT(:b, "B")
	AddEdgeXT(:a, :b, "connects", ["weight" = 5])
}

oGx = new stzGraphex("{@Node -> @EdgeProperty(weight) -> @Node}", oGraph)
? oGx.Match(oGraph)
#--> Should parse as "edgeproperty" not "edge"

pf()

/*--- Test @NodeCount vs @Node

pr()

oGraph = new stzGraph("Count")
oGraph {
	AddNodeXT(:a, "A")
	AddNodeXT(:b, "B")
	AddNodeXT(:c, "C")
}

oGx = new stzGraphex("{@NodeCount}", oGraph)
? oGx.Match(oGraph)
#--> Should parse as "nodecount"

pf()

#============================#
#  ENHANCEMENT 2: CASE SENSITIVITY TESTS
#============================#

/*--- Case-insensitive matching (default)

pr()

oGraph = new stzGraph("Mixed")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "PROCESS")
	AddNodeXT(:c, "end")
	AddEdgeXT(:a, :b, "Flows")
	AddEdgeXT(:b, :c, "COMPLETES")
}

# Without @cs:, should match any case
oGx = new stzGraphex("{@Node(start) -> @Edge(flows) -> @Node(process)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (case-insensitive by default)

pf()

/*--- Case-sensitive matching with @cs: flag

pr()

oGraph = new stzGraph("CaseSensitive")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "start")
	AddEdgeXT(:a, :b, "flows")
}

# With @cs:, exact case required
oGx = new stzGraphex("{@cs:@Node(Start)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (exact "Start" exists)

oGx2 = new stzGraphex("{@cs:@Node(start)}", oGraph)
? oGx2.Match(oGraph)
#--> TRUE (exact "start" exists)

oGx3 = new stzGraphex("{@cs:@Node(START)}", oGraph)
? oGx3.Match(oGraph)
#--> FALSE (no "START" node)

pf()

/*--- Mixed case sensitivity in pattern

pr()

oGraph = new stzGraph("Mixed")
oGraph {
	AddNodeXT(:a, "User")
	AddNodeXT(:b, "ADMIN")
	AddEdgeXT(:a, :b, "Promotes")
}

# Case-sensitive on first node, insensitive on second
oGx = new stzGraphex("{@cs:@Node(User) -> @Edge -> @Node(admin)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

#============================#
#  ENHANCEMENT 3: CACHING TESTS
#============================#

/*--- Cache performance test

pr()

# Create large graph
oGraph = new stzGraph("Large")
for i = 1 to 100
	cId = ":n" + i
	oGraph.AddNodeXT(cId, "Node" + i)
	if i > 1
		oGraph.AddEdgeXT(":n" + (i-1), cId, "next")
	ok
next

oGx = new stzGraphex("{@Node(Node1) -> @Edge(next) -> @Node(Node2)}", oGraph)

? "=== First Match (no cache) ==="
t1 = clock()
bResult1 = oGx.Match(oGraph)
t2 = clock()
? "Result: " + bResult1
? "Time: " + (t2 - t1)

? "=== Second Match (cached) ==="
t3 = clock()
bResult2 = oGx.Match(oGraph)
t4 = clock()
? "Result: " + bResult2
? "Time: " + (t4 - t3)
? "Speedup: " + ((t2-t1)/(t4-t3))

pf()

/*--- Cache stats and management

pr()

oGraph = new stzGraph("Test")
oGraph.AddNodeXT(:a, "A")

oGx = new stzGraphex("{@Node(A)}", oGraph)

? "Initial cache: " + @@(oGx.CacheStats())
? oGx.Match(oGraph)
? "After match: " + @@(oGx.CacheStats())

oGx.ClearCache()
? "After clear: " + @@(oGx.CacheStats())

oGx.SetCacheSize(50)
? "New max size: " + @@(oGx.CacheStats())

pf()

/*--- Cache with different graphs

pr()

oGraph1 = new stzGraph("G1")
oGraph1.AddNodeXT(:a, "Start")

oGraph2 = new stzGraph("G2")
oGraph2.AddNodeXT(:a, "Start")
oGraph2.AddNodeXT(:b, "End")

oGx = new stzGraphex("{@Node(Start)}", oGraph1)

? oGx.Match(oGraph1)  # Cached
? oGx.Match(oGraph2)  # Different graph signature
? "Cache entries: " + @@(oGx.CacheStats())

pf()

#============================#
#  ENHANCEMENT 4: PROPERTY CONSTRAINTS TESTS
#============================#

/*--- Property value comparison (greater than)

pr()

oGraph = new stzGraph("Users")
oGraph {
	AddNodeXT(:u1, "Alice", ["age" = 30])
	AddNodeXT(:u2, "Bob", ["age" = 20])
	AddNodeXT(:u3, "Charlie", ["age" = 35])
}

# Match nodes with age > 25
oGx = new stzGraphex("{@Node{age:>:25}}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (Alice and Charlie match)

pf()

/*--- Property value comparison (less than)

pr()

oGraph = new stzGraph("Products")
oGraph {
	AddNodeXT(:p1, "ItemA", ["price" = 10])
	AddNodeXT(:p2, "ItemB", ["price" = 50])
	AddNodeXT(:p3, "ItemC", ["price" = 5])
}

# Match items with price < 15
oGx = new stzGraphex("{@Node{price:<:15}}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (ItemA and ItemC match)

pf()

/*--- Property equality constraint

pr()

oGraph = new stzGraph("Roles")
oGraph {
	AddNodeXT(:u1, "User1", ["role" = "admin"])
	AddNodeXT(:u2, "User2", ["role" = "user"])
	AddNodeXT(:u3, "User3", ["role" = "admin"])
}

# Match admin users
oGx = new stzGraphex("{@Node{role:=:admin}}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

/*--- Multiple property constraints

pr()

oGraph = new stzGraph("Complex")
oGraph {
	AddNodeXT(:u1, "Alice", ["age" = 30, "score" = 85])
	AddNodeXT(:u2, "Bob", ["age" = 25, "score" = 90])
	AddNodeXT(:u3, "Charlie", ["age" = 35, "score" = 75])
}

# Match nodes: age > 26 AND score > 80
oGx = new stzGraphex("{@Node{age:>:26;score:>:80}}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (Alice matches both)

pf()

/*--- Property constraint with flow

pr()

oGraph = new stzGraph("Workflow")
oGraph {
	AddNodeXT(:a, "Task1", ["priority" = 1])
	AddNodeXT(:b, "Task2", ["priority" = 5])
	AddEdgeXT(:a, :b, "depends")
}

# Match high-priority task flow
oGx = new stzGraphex("{@Node{priority:>:3} -> @Edge -> @Node}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (Task2 has priority 5)

pf()

#============================#
#  ENHANCEMENT 5: DEBUG & EXPLAIN TESTS
#============================#

/*--- Explain method usage

pr()

oGraph = new stzGraph("Sample")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "End")
	AddEdgeXT(:a, :b, "flows")
}

oGx = new stzGraphex("{@Node(Start) -> @Edge(flows) -> @Node(End)}", oGraph)
? "=== Pattern Explanation ==="
? @@(oGx.Explain())

pf()

/*--- Standardized debug output

pr()

oGraph = new stzGraph("Debug")
oGraph {
	AddNodeXT(:a, "A")
	AddNodeXT(:b, "B")
	AddEdgeXT(:a, :b, "connects")
}

oGx = new stzGraphex("{@Node(A) -> @Edge -> @Node(B)}", oGraph)
oGx.EnableDebug()
? oGx.Match(oGraph)
#--> Shows consistent debug messages

pf()

#============================#
#  ENHANCEMENT 6: VALUE PRESERVATION TESTS
#============================#

/*--- Preserved case in labels

pr()

oGraph = new stzGraph("Case")
oGraph {
	AddNodeXT(:a, "StartNode")
	AddNodeXT(:b, "EndNode")
	AddEdgeXT(:a, :b, "FlowsTo")
}

# Label should preserve exact case
oGx = new stzGraphex("{@Node(StartNode) -> @Edge(FlowsTo) -> @Node(EndNode)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (case preserved correctly)

pf()

/*--- Parentheses content before lowercasing

pr()

oGraph = new stzGraph("Labels")
oGraph {
	AddNodeXT(:a, "CamelCaseLabel")
	AddNodeXT(:b, "UPPERCASE")
	AddEdgeXT(:a, :b, "MixedCase")
}

# All labels should be extracted before lowercasing
oGx = new stzGraphex("{@Node(CamelCaseLabel) -> @Edge(MixedCase) -> @Node(UPPERCASE)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

#============================#
#  ORIGINAL TESTS (UPDATED)
#============================#

/*--- Alternation with enhancement tracking

pr()

oTargetGraph = new stzGraph("Sample")
oTargetGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "Process")
	AddNodeXT(:c, "End")
	AddEdgeXT(:a, :b, "flows")
	AddEdgeXT(:b, :c, "completes")
}

oGraphex = new stzGraphex("{@Node(Start) -> (@Edge(flows)|@Edge(completes)) -> @Node(End)}", oTargetGraph)
oGraphex.EnableDebug()
? "Cache before: " + @@(oGraphex.CacheStats())
? oGraphex.Match(oTargetGraph)
? "Cache after: " + @@(oGraphex.CacheStats())

pf()

/*--- CI/CD with case sensitivity

pr()

oGraph = new stzGraph("CICD")
oGraph {
	AddNodeXT(:code, "code")  # lowercase
	AddNodeXT(:build, "BUILD")  # uppercase
	AddNodeXT(:test, "Test")  # mixed
	AddNodeXT(:deploy, "Deploy")
	AddEdgeXT(:code, :build, "compiles")
	AddEdgeXT(:build, :test, "validates")
	AddEdgeXT(:test, :deploy, "releases")
}

# Case-insensitive pattern
oGx = new stzGraphex("{@Node(Code) -> @Edge(compiles) -> @Node(Build)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (case-insensitive)

# Case-sensitive pattern
oGx2 = new stzGraphex("{@cs:@Node(BUILD) -> @Edge -> @Node(Test)}", oGraph)
? oGx2.Match(oGraph)
#--> TRUE (exact case match)

pf()

/*--- State machine with properties

pr()

oGraph = new stzGraph("StateMachine")
oGraph {
	AddNodeXT(:idle, "Idle", ["energy" = 0])
	AddNodeXT(:running, "Running", ["energy" = 100])
	AddNodeXT(:paused, "Paused", ["energy" = 50])
	AddEdgeXT(:idle, :running, "start")
	AddEdgeXT(:running, :paused, "pause")
}

# Match high-energy states
oGx = new stzGraphex("{@Node{energy:>:40}}", oGraph)
? oGx.Match(oGraph)
#--> TRUE (Running and Paused)

pf()

/*--- Negation with case sensitivity

pr()

oGraph = new stzGraph("Clean")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "Success")
	AddNodeXT(:c, "error")  # lowercase
	AddEdgeXT(:a, :b, "proceeds")
}

# Case-insensitive negation
oGx = new stzGraphex("{@Node(Start) -> @Edge -> @!Node(Error)}", oGraph)
? oGx.Match(oGraph)
#--> FALSE (matches "error" case-insensitively)

# Case-sensitive negation
oGx2 = new stzGraphex("{@cs:@Node(Start) -> @Edge -> @!Node(Error)}", oGraph)
? oGx2.Match(oGraph)
#--> TRUE ("Error" != "error" in case-sensitive mode)

pf()

/*--- Multi-stage with caching benchmark

pr()

oGraph = new stzGraph("Pipeline")
oGraph {
	AddNodeXT(:input, "Input")
	AddNodeXT(:validate, "Validate")
	AddNodeXT(:process, "Process")
	AddNodeXT(:output, "Output")
	AddEdgeXT(:input, :validate, "feeds")
	AddEdgeXT(:validate, :process, "approved")
	AddEdgeXT(:process, :output, "completes")
}

oGx = new stzGraphex("{@Node(Input) -> @Edge -> @Node(Validate) -> @Edge -> @Node(Process)}", oGraph)

? "First match:"
t1 = clock()
? oGx.Match(oGraph)
? "Time: " + (clock() - t1)

? "Cached match:"
t2 = clock()
? oGx.Match(oGraph)
? "Time: " + (clock() - t2)

? "Explain:"
? @@(oGx.Explain())

pf()

#============================#
#  COMBINED ENHANCEMENTS TEST
#============================#

/*--- All enhancements together

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
