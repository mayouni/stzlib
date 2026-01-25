load "../stzbase.ring"

# stzGraphQuery - Natural Softanza Graph Query Tests

#-----------------------#
#  BASIC NODE MATCHING  #
#-----------------------#

/*--- Match all nodes

pr()

oGraph = new stzGraph("social")
oGraph {
	AddNodeXT("alice", "Person")
	AddNodeXT("bob", "Person")
	AddNodeXT("company_x", "Company")
	
	SetNodeProperty("alice", "age", 30)
	SetNodeProperty("bob", "age", 25)
}

# Query: Match all nodes
aResults = StzGraphQueryQ(oGraph).
	MatchQ(:nodes).
	Select("*")

? len(aResults)
#--> 3

? @@( aResults[1]["node"][:id] )
#--> "alice"

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Match nodes by label

pr()

oGraph = new stzGraph("social")
oGraph {
	AddNodeXT("alice", "Person")
	AddNodeXT("bob", "Person")
	AddNodeXT("company_x", "Company")
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:nodes, :labeled = "Person"]).
	Select("*")

? len(aResults)
#--> 2

? @@( aResults[1]["node"][:id] )
#--> "alice"

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Match nodes with properties

pr()

oGraph = new stzGraph("social")
oGraph {
	AddNodeXTT("alice", "Person", [:age = 30, :city = "Paris"])
	AddNodeXTT("bob", "Person", [:age = 25, :city = "London"])
	AddNodeXTT("carol", "Person", [:age = 30, :city = "Paris"])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:nodes, :where = [:age, "=", 30]]).
	Select("*")

? len(aResults) #--> 2

pf()
# Executed in 0.01 second(s) in Ring 1.25

#--------------------------#
#  RELATIONSHIP MATCHING   #
#--------------------------#

/*--- Match simple edge

pr()

oGraph = new stzGraph("social")
oGraph {
	AddNode("alice")
	AddNode("bob")
	AddNode("carol")
	
	ConnectXT("alice", "bob", "KNOWS")
	ConnectXT("bob", "carol", "KNOWS")
}

aResults = StzGraphQueryQ(oGraph).
	MatchEdgeQ([:from = "a", :to = "b", :labeled = "KNOWS"]).
	Select(["a", "b"])

? len(aResults)
#--> 2

? @@( aResults[1]["a"][:id] )
#--> "alice"

? @@( aResults[1]["b"][:id] )
#--> "bob"

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Match edge with properties

pr()

oGraph = new stzGraph("social")
oGraph {
	AddNode("alice")
	AddNode("bob")
	AddNode("carol")
	
	ConnectXTT("alice", "bob", "KNOWS", [:since = 2020])
	ConnectXTT("alice", "carol", "KNOWS", [:since = 2022])
}

aResults = StzGraphQueryQ(oGraph).
	MatchEdgeQ([:from = "a", :to = "b", :where = [:since, "=", 2020]]).
	Select(["a", "b"])

? len(aResults) 
#--> 1 #ERR returned 2

? @@( aResults[1]["b"][:id] )
#--> "bob"

pf()
# Executed in 0.01 second(s) in Ring 1.25

#-------------------#
#  WHERE FILTERING  #
#-------------------#

/*--- Filter with equals

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:salary = 50000])
	AddNodeXTT("bob", "Employee", [:salary = 60000])
	AddNodeXTT("carol", "Employee", [:salary = 50000])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:nodes, :labeled = "Employee"]).
	WhereQ([:salary, "=", 50000]).
	Select("*")

? len(aResults)
#--> 2

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Filter with comparison

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:salary = 50000])
	AddNodeXTT("bob", "Employee", [:salary = 60000])
	AddNodeXTT("carol", "Employee", [:salary = 70000])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ(:nodes).
	WhereQ([:salary, ">", 55000]).
	Select("*")

? len(aResults)
#--> 2

? @@( aResults[1]["node"][:id] )
#--> "bob"

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Filter with contains

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice_smith", "Person", [:name = "Alice Smith"])
	AddNodeXTT("bob_jones", "Person", [:name = "Bob Jones"])
	AddNodeXTT("alice_brown", "Person", [:name = "Alice Brown"])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ(:nodes).
	WhereQ([:name, :contains, "Alice"]).
	Select("*")

? len(aResults)
#--> 2

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Filter with AND condition

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:age = 30, :dept = "Engineering"])
	AddNodeXTT("bob", "Employee", [:age = 25, :dept = "Engineering"])
	AddNodeXTT("carol", "Employee", [:age = 30, :dept = "Sales"])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ(:nodes).
	WhereQ([:age, "=", 30, :and, :dept, "=", "Engineering"]).
	Select("*")

? len(aResults)
#--> 1

? @@( aResults[1]["node"][:id] )
#--> "alice"

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Filter with OR condition

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:dept = "Engineering"])
	AddNodeXTT("bob", "Employee", [:dept = "Sales"])
	AddNodeXTT("carol", "Employee", [:dept = "Engineering"])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ(:nodes).
	WhereQ([:dept, "=", "Sales", :or, :dept, "=", "Engineering"]).
	Select("*")

? len(aResults)
#--> 3

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Filter with function

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:salary = 50000])
	AddNodeXTT("bob", "Employee", [:salary = 60000])
	AddNodeXTT("carol", "Employee", [:salary = 70000])
}

StzGraphQueryQ(oGraph) {
	Match(:nodes)
	
	WhereF(func aBinding {
		if @HasKey(aBinding, "node")
			aNode = aBinding["node"]
			if @HasKey(aNode, :properties)
				aProps = aNode[:properties]
				if @HasKey(aProps, "salary")
					return aProps["salary"] > 55000
				ok
			ok
		ok
		return FALSE
	})
	
	aResults = Select("*")
	? len(aResults)
	#--> 2 
}

pf()
# Executed in 0.01 second(s) in Ring 1.25

#------------------------#
#  SELECT PROJECTIONS    #
#------------------------#

/*--- Select specific property

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:name = "Alice", :age = 30])
	AddNodeXTT("bob", "Employee", [:name = "Bob", :age = 25])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:node = "n"]).
	Select("n.name")

? len(aResults)
#--> 2

? @@( aResults[1]["n.name"] )
#--> "Alice"

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Select with alias

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:age = 30])
	AddNodeXTT("bob", "Employee", [:age = 25])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:node = "n"]).
	Select(["n.age", :as = "years"])

? @@( aResults[1]["years"] )
#--> 30

? @@( aResults ) #-->
#--> [ [ [ "years", 30 ] ], [ [ "years", 25 ] ] ]

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Select multiple fields

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:name = "Alice", :age = 30])
	AddNodeXTT("bob", "Employee", [:name = "Bob", :age = 25])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:node = "n"]).
	Select(["n.name", "n.age"])

? len(aResults)
#--> 2

? @@( aResults[1] )
#--> [["n.name", "Alice"], ["n.age", 30]]

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Select DISTINCT

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:dept = "Engineering"])
	AddNodeXTT("bob", "Employee", [:dept = "Sales"])
	AddNodeXTT("carol", "Employee", [:dept = "Engineering"])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:node = "n"]).
	DistinctQ().
	Select("n.dept")

? len(aResults)
#--> 2

pf()
# Executed in 0.01 second(s) in Ring 1.25

#---------------------#
#  ORDERING & LIMITS  #
#---------------------#

/*--- Order by ascending

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:age = 30])
	AddNodeXTT("bob", "Employee", [:age = 25])
	AddNodeXTT("carol", "Employee", [:age = 35])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:node = "n"]).
	OrderByQ("n.age", "asc").
	Select("n")

? @@( aResults[1]["n"][:id] )
#--> "bob"

? @@( aResults[3]["n"][:id] )
#--> "carol"

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Skip and Limit

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:rank = 1])
	AddNodeXTT("bob", "Employee", [:rank = 2])
	AddNodeXTT("carol", "Employee", [:rank = 3])
	AddNodeXTT("dave", "Employee", [:rank = 4])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:node = "n"]).
	OrderByQ("n.rank", "asc").
	SkipQ(1).
	LimitQ(2).
	Select("n")

? len(aResults)
#--> 2

? @@( aResults[1]["n"][:id] )
#--> "bob"

pf()
# Executed in 0.01 second(s) in Ring 1.25

#-------------------#
#  CREATE PATTERNS  #
#-------------------#

/*--- Create single node

pr()

oGraph = new stzGraph("test")

StzGraphQueryQ(oGraph) {
	CreateQ([:node, :labeled = "Person", :props = [:name = "Alice"]])
	Select("*")
	? GraphQ().NodeCount()
	#--> 1
}

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Create edge

pr()

oGraph = new stzGraph("test")
oGraph {
	AddNode("alice")
	AddNode("bob")
}

StzGraphQueryQ(oGraph) {
	MatchQ([:node = "a", :where = [:id, "=", "alice"]])
	MatchQ([:node = "b", :where = [:id, "=", "bob"]])
	CreateQ([:edge, :from = "a", :to = "b", :labeled = "KNOWS"])

	? len(Select("a"))
	#--> 1

	? GraphQ().EdgeCount()
	#--> 1
}

pf()
# Executed in 0.01 second(s) in Ring 1.25

#-------------------#
#  UPDATE PATTERNS  #
#-------------------#

/*--- Set property

pr()

oGraph = new stzGraph("test")
oGraph {
	AddNodeXTT("alice", "Person", [:age = 30])
}

StzGraphQueryQ(oGraph) {
	MatchQ([:node = "n", :where = [:id, "=", "alice"]])
	SetQ("n.age", [:to = 31])
	Select("n")
	
	? GraphObject().NodeProperty("alice", "age")
	#--> 31
}

pf()
# Executed in almost 0 second(s) in Ring 1.25
	
/*--- Set multiple properties

pr()

oGraph = new stzGraph("test")
oGraph {
	AddNodeXTT("alice", "Person", [:age = 30])
}

StzGraphQueryQ(oGraph) {
	MatchQ([:node = "n", :where = [:id, "=", "alice"]])
	SetQ("n.age", [:to = 31])
	SetQ("n.city", [:to = "Paris"])
	Select("n")
}

? oGraph.NodeProperty("alice", "age")
#--> 31

? oGraph.NodeProperty("alice", "city")
#--> "Paris"

pf()
# Executed in 0.01 second(s) in Ring 1.25

#-------------------#
#  DELETE PATTERNS  #
#-------------------#

/*--- Delete node

pr()

oGraph = new stzGraph("test")
oGraph {
	AddNode("alice")
	AddNode("bob")
}

StzGraphQueryQ(oGraph) {
	MatchQ([:node = "n", :where = [:id, "=", "alice"]])
	DeleteQ("n")
	Select("n")
}

? oGraph.NodeCount()
#--> 1

pf()
# Executed in almost 0 second(s) in Ring 1.25

#---------------------------#
#  COMPLEX PATTERN QUERIES  #
#---------------------------#

/*--- Find friends of friends

pr()

oGraph = new stzGraph("social")
oGraph {
	AddNode("alice")
	AddNode("bob")
	AddNode("carol")
	AddNode("dave")
	
	ConnectXT("alice", "bob", "FRIEND")
	ConnectXT("bob", "carol", "FRIEND")
	ConnectXT("bob", "dave", "FRIEND")
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:node = "a", :where = [:id, "=", "alice"]]).
	MatchEdgeQ([:from = "a", :to = "friend", :labeled = "FRIEND"]).
	MatchEdgeQ([:from = "friend", :to = "fof", :labeled = "FRIEND"]).
	Select("fof")

? len(aResults)
#--> 2 (carol and dave)

pf()
# Executed in 0.02 second(s) in Ring 1.25

#----------------------#
#  EXPLAIN QUERY PLAN  #
#----------------------#

/*--- Explain query execution plan

pr()

oGraph = new stzGraph("test")
oGraph.AddNodeXT("alice", "Person")

aExplanation = StzGraphQueryQ(oGraph).
	MatchQ([:nodes, :labeled = "Person"]).
	WhereQ([:age, ">", 25]).
	OrderByQ("age", "asc").
	LimitQ(10).

	Explain()

? @@NL(aExplanation)
#--> [
# 	[
# 		[ "step", "match" ],
# 		[
# 			"description",
# 			[
# 				"Scan all nodes, bind to variable 'node' with label 'Person'"
# 			]
# 		]
# 	],
# 	[
# 		[ "step", "where" ],
# 		[
# 			"description",
# 			[ "Filter bindings using: node.age > 25" ]
# 		]
# 	],
# 	[
# 		[ "step", "orderby" ],
# 		[
# 			"description",
# 			[ "Sort by: age ASC" ]
# 		]
# 	],
# 	[
# 		[ "step", "limit" ],
# 		[
# 			"description",
# 			[ "Return maximum 10 results" ]
# 		]
# 	]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.25

#-------------------------#
#  OPENCYPHER CONVERSION  #
#-------------------------#

/*--- Convert query to OpenCypher

pr()

oGraph = new stzGraph("test")

cCypher = StzGraphQueryQ(oGraph).
	MatchQ([:node = "n", :labeled = "Person"]).
	WhereQ([:age, ">", 25]).
	OrderByQ("n.age", "asc").
	LimitQ(10).
	ToOpenCypher()

? cCypher
# Output:
# MATCH (n:Person)
# WHERE n.age > 25
# ORDER BY n.age ASC
# LIMIT 10

pf()
# Executed in almost 0 second(s) in Ring 1.25
