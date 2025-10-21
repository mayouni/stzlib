load "../stzbase.ring"

/*---

pr()

oTargetGraph = new stzGraph("Sample")
oTargetGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "Process")
	AddNodeXT(:c, "End")

	AddEdgeXT(:a, :b, "flows")
	AddEdgeXT(:b, :c, "completes")
}

# Test 1: Valid alternation
oGraphex = new stzGraphex("{@Node(Start) -> (@Edge(flows)|@Edge(completes)) -> @Node(End)}", oTargetGraph)
oGraphex.EnableDebug()
? oGraphex.Match(oTargetGraph)
#--> should return TRUE (matches flows path)

pf()

/*---

# Test 2: Single edge in parentheses

pr()

oTargetGraph = new stzGraph("Sample")
oTargetGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "Process")
	AddNodeXT(:c, "End")

	AddEdgeXT(:a, :b, "flows")
	AddEdgeXT(:b, :c, "completes")
}

oGraphex2 = new stzGraphex("{@Node(Start) -> (@Edge(flows)) -> @Node(Process)}", oTargetGraph)
? oGraphex2.Match(oTargetGraph)  # → TRUE

pf()

/*---

pr()

# Test 3: Set without semicolons

oTargetGraph = new stzGraph("Sample")
oTargetGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "Process")
	AddNodeXT(:c, "End")

	AddEdgeXT(:a, :b, "flows")
	AddEdgeXT(:b, :c, "completes")
}

oGraphex3 = new stzGraphex("{@Node{Start} -> @Edge -> @Node}", oTargetGraph)
? oGraphex3.Match(oTargetGraph)  # → TRUE (matches {Start} as single value)

pf()

/*---

pr()

# Test 4: Empty alternation with debug mode

oTargetGraph = new stzGraph("Sample")
oTargetGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "Process")
	AddNodeXT(:c, "End")

	AddEdgeXT(:a, :b, "flows")
	AddEdgeXT(:b, :c, "completes")
}

oGraphex4 = new stzGraphex("{@Node(Start) -> (@Edge(flows)|) -> @Node}", oTargetGraph)
oGraphex4.EnableDebugMode()
? oGraphex4.Match(oTargetGraph)  # → Warning: Empty alternation part... TRUE

pf()

#========================#
#  BASIC NODE MATCHING   #
#========================#

/*--- Match single node type

pr()

# Pattern matches any graph with at least one node

oGraph = new stzGraph("Simple")
oGraph {
	AddNodeXT(:@a, "Task")
}

oGx = new stzGraphex("{@Node}", oGraph)
oGx.EnableDebug()
? oGx.Match(oGraph)
#--> TRUE

pf()

/*--- Match specific node label

pr()

# Pattern requires a node labeled "Start"

oGraph = new stzGraph("Workflow")
oGraph {
	AddNodeXT(:@a, "Start")
	AddNodeXT(:@b, "Process")
}

oGx = new stzGraphex("{@Node(Start)}", oGraph)
//oGx.SetDebug(TRUE)
? oGx.Match(oGraph)
#--> should return TRUE

pf()

/*--- Node label mismatch

pr()

# Pattern looks for "End" but graph only has "Start"

oGraph = new stzGraph("Workflow")
oGraph {
	AddNodeXT(:@a, "Start")
}

oGx = new stzGraphex("{@Node(End)}", oGraph)
oGx.EnableDebug()
? oGx.Match(oGraph)
#--> FALSE

pf()

#========================#
#  BASIC EDGE MATCHING   #
#========================#

/*--- Match node-edge-node sequence

pr()

# Pattern matches a simple two-node flow

oGraph = new stzGraph("Flow")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "End")
	AddEdgeXT(:a, :b, "connects")
}

oGx = new stzGraphex("{@Node(Start) -> @Edge(connects) -> @Node(End)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

/*--- Edge label mismatch

pr()

# Pattern expects "flows" but graph has "connects"

oGraph = new stzGraph("Flow")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "End")
	AddEdgeXT(:a, :b, "connects")
}

oGx = new stzGraphex("{@Node(Start) -> @Edge(flows) -> @Node(End)}", oGraph)
? oGx.Match(oGraph)
#--> FALSE

pf()

/*--- Any edge label

pr()

# Pattern accepts any edge label between nodes

oGraph = new stzGraph("Flow")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "End")
	AddEdgeXT(:a, :b, "anything")
}

oGx = new stzGraphex("{@Node(Start) -> @Edge -> @Node(End)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

#============================#
#  ALTERNATION PATTERNS      #
#============================#

/*--- Simple alternation - first branch

pr()

# Pattern matches either "flows" or "completes" edge

oGraph = new stzGraph("Workflow")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "Process")
	AddNodeXT(:c, "End")
	AddEdgeXT(:a, :b, "flows")
	AddEdgeXT(:b, :c, "completes")
}

oGx = new stzGraphex("{@Node(Start) -> (@Edge(flows)|@Edge(completes)) -> @Node}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

/*--- Simple alternation - second branch

pr()

# Graph has "completes" edge, matching second alternative

oGraph = new stzGraph("Workflow")
oGraph {
	AddNodeXT(:a, "Process")
	AddNodeXT(:b, "End")
	AddEdgeXT(:a, :b, "completes")
}

oGx = new stzGraphex("{@Node -> (@Edge(flows)|@Edge(completes)) -> @Node(End)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

/*--- Alternation with continuation

pr()

# Pattern has alternation in middle of sequence

oGraph = new stzGraph("Workflow")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "Middle")
	AddNodeXT(:c, "End")
	AddEdgeXT(:a, :b, "flows")
	AddEdgeXT(:b, :c, "next")
}

oGx = new stzGraphex("{@Node(Start) -> (@Edge(flows)|@Edge(skips)) -> @Node -> @Edge -> @Node(End)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

/*--- Multiple alternations

pr()

# Pattern with two separate alternation points

oGraph = new stzGraph("Complex")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "Mid")
	AddNodeXT(:c, "End")
	AddEdgeXT(:a, :b, "option1")
	AddEdgeXT(:b, :c, "choice2")
}

oGx = new stzGraphex("{@Node(Start) -> (@Edge(option1)|@Edge(option2)) -> @Node -> (@Edge(choice1)|@Edge(choice2)) -> @Node(End)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

#============================#
#  NEGATION PATTERNS         #
#============================#

/*--- Negative node matching

pr()

# Pattern excludes nodes labeled "Error"

oGraph = new stzGraph("Clean")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "Success")
	AddEdgeXT(:a, :b, "proceeds")
}

oGx = new stzGraphex("{@Node(Start) -> @Edge -> @!Node(Error)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

/*--- Negative edge matching

pr()

# Pattern excludes "fails" edges

oGraph = new stzGraph("Positive")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "End")
	AddEdgeXT(:a, :b, "succeeds")
}

oGx = new stzGraphex("{@Node(Start) -> @!Edge(fails) -> @Node(End)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

/*--- Negation fails when present #ERR

pr()

# Graph contains the excluded "Error" node

oGraph = new stzGraph("HasError")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "Error")
	AddEdgeXT(:a, :b, "fails")
}

oGx = new stzGraphex("{@Node(Start) -> @Edge -> @!Node(Error)}", oGraph)
? oGx.Match(oGraph)
#--> FALSE

pf()

#============================#
#  COMPLEX WORKFLOWS         #
#============================#


/*--- Multi-stage pipeline

pr()

# Pattern matches a 4-stage processing pipeline

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

oGx = new stzGraphex("{@Node(Input) -> @Edge(feeds) -> @Node(Validate) -> @Edge(approved) -> @Node(Process) -> @Edge -> @Node(Output)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

/*--- Branching workflow with alternations

pr()

# Pattern matches approval or rejection paths

oGraph = new stzGraph("Approval")
oGraph {
	AddNodeXT(:submit, "Submit")
	AddNodeXT(:review, "Review")
	AddNodeXT(:approved, "Approved")
	AddNodeXT(:rejected, "Rejected")
	AddEdgeXT(:submit, :review, "pending")
	AddEdgeXT(:review, :approved, "approve")
	AddEdgeXT(:review, :rejected, "reject")
}

oGx = new stzGraphex("{@Node(Submit) -> @Edge -> @Node(Review) -> (@Edge(approve)|@Edge(reject)) -> @Node}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

/*--- Error handling pattern

pr()

# Pattern detects error recovery flows

oGraph = new stzGraph("Resilient")
oGraph {
	AddNodeXT(:start, "Start")
	AddNodeXT(:task, "Task")
	AddNodeXT(:retry, "Retry")
	AddNodeXT(:success, "Success")
	AddEdgeXT(:start, :task, "begins")
	AddEdgeXT(:task, :retry, "fails")
	AddEdgeXT(:retry, :success, "recovers")
}

oGx = new stzGraphex("{@Node(Start) -> @Edge -> @Node(Task) -> (@Edge(fails)|@Edge(succeeds)) -> @Node}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

#============================#
#  PRACTICAL APPLICATIONS    #
#============================#

/*--- CI/CD pipeline validation

pr()

# Verify deployment pipeline structure

oGraph = new stzGraph("CICD")
oGraph {
	AddNodeXT(:code, "Code")
	AddNodeXT(:build, "Build")
	AddNodeXT(:test, "Test")
	AddNodeXT(:deploy, "Deploy")
	AddEdgeXT(:code, :build, "compiles")
	AddEdgeXT(:build, :test, "validates")
	AddEdgeXT(:test, :deploy, "releases")
}

oGx = new stzGraphex("{
	@Node(Code) -> @Edge(compiles) -> @Node(Build) ->
	@Edge(validates) -> @Node(Test) -> @Edge(releases) ->
	@Node(Deploy)}", oGraph)

? oGx.Match(oGraph)
#--> TRUE

pf()

/*--- State machine validation

pr()

# Check valid state transitions

oGraph = new stzGraph("StateMachine")
oGraph {
	AddNodeXT(:idle, "Idle")
	AddNodeXT(:running, "Running")
	AddNodeXT(:paused, "Paused")
	AddEdgeXT(:idle, :running, "start")
	AddEdgeXT(:running, :paused, "pause")
	AddEdgeXT(:paused, :running, "resume")
}

oGx = new stzGraphex("{
	@Node(Idle) ->
	@Edge(start) ->
	@Node(Running) ->
	(@Edge(pause)|@Edge(stop)) ->
	@Node
}", oGraph)

? oGx.Match(oGraph)
#--> TRUE

pf()

/*--- Dependency graph validation

pr()

# Ensure build dependencies are correct

oGraph = new stzGraph("Dependencies")
oGraph {
	AddNodeXT(:core, "Core")
	AddNodeXT(:utils, "Utils")
	AddNodeXT(:app, "App")
	AddEdgeXT(:core, :utils, "depends")
	AddEdgeXT(:utils, :app, "depends")
}

oGx = new stzGraphex("{
	@Node(Core) -> @Edge(depends) -> @Node(Utils) ->
	@Edge(depends) -> @Node(App) }", oGraph)

? oGx.Match(oGraph)
#--> TRUE

pf()

#============================#
#  EDGE CASES                #
#============================#

/*--- Empty graph

pr()

# Pattern cannot match empty graph

oGraph = new stzGraph("Empty")

oGx = new stzGraphex("{@Node}", oGraph)
? oGx.Match(oGraph)
#--> FALSE

pf()

/*--- Single node graph

pr()

# Pattern matches isolated node

oGraph = new stzGraph("Singleton")
oGraph {
	AddNodeXT(:only, "Alone")
}

oGx = new stzGraphex("{@Node(Alone)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

/*--- Disconnected components

pr()

# Pattern matches one component

oGraph = new stzGraph("Disconnected")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "End")
	AddNodeXT(:x, "Isolated")
	AddEdgeXT(:a, :b, "connects")
}

oGx = new stzGraphex("{@Node(Start) -> @Edge(connects) -> @Node(End)}", oGraph)
? oGx.Match(oGraph)
#--> TRUE

pf()

/*=== TESTS RETURNING FALSE

/*--- Path doesn't exist

pr()

oGraph = new stzGraph("Test")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "End")
	# No edge connecting them
}

oGx = new stzGraphex("{@Node(Start) -> @Edge -> @Node(End)}", oGraph)
? oGx.Match(oGraph)  #--> Should be FALSE (no path between Start and End)

pf()

/*--- Wrong edge label

pr()

oGraph = new stzGraph("Test")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "End")
	AddEdgeXT(:a, :b, "wrong_label")
}

oGx = new stzGraphex("{@Node(Start) -> @Edge(flows) -> @Node(End)}", oGraph)
? oGx.Match(oGraph)  #--> Should be FALSE (edge labeled 'wrong_label' not 'flows')

pf()

/*--- Missing required node

pr()

oGraph = new stzGraph("Test")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "Process")
}

oGx = new stzGraphex("{@Node(Start) -> @Edge -> @Node(End)}", oGraph)
? oGx.Match(oGraph)  #--> Should be FALSE (no 'End' node exists)

pf()

/*--- Negation violated (already tested) #ERR
*/
pr()

oGraph = new stzGraph("Test")
oGraph {
	AddNodeXT(:a, "Start")
	AddNodeXT(:b, "Error")
	AddEdgeXT(:a, :b, "fails")
}

oGx = new stzGraphex("{@Node(Start) -> @Edge -> @!Node(Error)}", oGraph)
? oGx.Match(oGraph)  #--> Should be FALSE (Error node present)

pf()
