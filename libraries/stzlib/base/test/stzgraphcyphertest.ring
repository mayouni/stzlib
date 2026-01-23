load "../stzbase.ring"

#============================================#
#  stzGraphCypher - Pattern Matching Tests  #
#  OpenCypher-style queries for stzGraph    #
#============================================#

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

# Query: MATCH (n) RETURN n
StzGraphCypherQ(oGraph) {
	Match([:node, "n"])
	Return_("n")

	? @@NL( Run() )
}
#-->
`
[
	[
		[
			"n",
			[
				[ "id", "alice" ],
				[ "label", "Person" ],
				[
					"properties",
					[
						[ "age", 30 ]
					]
				]
			]
		]
	],
	[
		[
			"n",
			[
				[ "id", "bob" ],
				[ "label", "Person" ],
				[
					"properties",
					[
						[ "age", 25 ]
					]
				]
			]
		]
	],
	[
		[
			"n",
			[
				[ "id", "company_x" ],
				[ "label", "Company" ],
				[ "properties", [  ] ]
			]
		]
	]
]
`

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Match nodes by label

pr()

oGraph = new stzGraph("social")
oGraph {
	AddNodeXT("alice", "Person")
	AddNodeXT("bob", "Person")
	AddNodeXT("company_x", "Company")
}

# Query: MATCH (n:Person) RETURN n
StzGraphCypherQ(oGraph) {
	Match([:node, "n", "Person"])
	Return_("n")
	aResults = Run()
}

? len(aResults)
#--> 2

? @@( aResults[1]["n"][:id] )
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

# Query: MATCH (n:Person {age: 30}) RETURN n
aResults = CypherQ(oGraph).
	MatchQ([:node, "n", [:age = 30]]).
	ReturnQ("n").
	Run()

? len(aResults)
#--> 2

? @@( aResults[1]["n"][:label] )
#--> "Person"

pf()
# Executed in almost 0 second(s) in Ring 1.25

#--------------------------#
#  RELATIONSHIP MATCHING   #
#--------------------------#

/*--- Match simple relationship

pr()

oGraph = new stzGraph("social")
oGraph {
	AddNode("alice")
	AddNode("bob")
	AddNode("carol")
	
	ConnectXT("alice", "bob", "KNOWS")
	ConnectXT("bob", "carol", "KNOWS")
}

# Query: MATCH (a)-[r:KNOWS]->(b) RETURN a, b
aResults = CypherQ(oGraph).
	MatchQ([:rel, "a", "b", "KNOWS"]).
	ReturnQ(["a", "b"]).
	Run()

? len(aResults)
#--> 2

? @@( aResults[1]["a"][:id] )
#--> "alice"

? @@( aResults[1]["b"][:id] )
#--> "bob"

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Match path pattern

pr()

oGraph = new stzGraph("social")
oGraph {
	AddNode("alice")
	AddNode("bob")
	AddNode("carol")
	
	ConnectXT("alice", "bob", "MANAGES")
	ConnectXT("bob", "carol", "MANAGES")
}

# Query: MATCH (boss)-[r]->(employee) RETURN boss, employee
aResults = CypherQ(oGraph).
	MatchQ([:path, "boss", "r", "employee"]).
	ReturnQ(["boss", "employee"]).
	Run()

? len(aResults)
#--> 2

? @@( aResults[1]["boss"][:id] )
#--> "alice"

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Match relationship with properties

pr()

oGraph = new stzGraph("social")
oGraph {
	AddNode("alice")
	AddNode("bob")
	AddNode("carol")
	
	ConnectXTT("alice", "bob", "KNOWS", [:since = 2020])
	ConnectXTT("alice", "carol", "KNOWS", [:since = 2022])
}

# Query: MATCH (a)-[r:KNOWS {since: 2020}]->(b) RETURN a, b
aResults = CypherQ(oGraph).
	MatchQ([:rel, "a", "b", [:since = 2020]]).
	ReturnQ(["a", "b"]).
	Run()

? len(aResults)
#--> 1

? @@( aResults[1]["b"][:id] )
#--> "bob"

pf()
# Executed in almost 0 second(s) in Ring 1.25

#-------------------#
#  WHERE FILTERING  #
#-------------------#


pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:salary = 50000])
	AddNodeXTT("bob", "Employee", [:salary = 60000])
	AddNodeXTT("carol", "Employee", [:salary = 50000])
}

# Query: MATCH (n:Employee) WHERE n.salary = 50000 RETURN n
aResults = CypherQ(oGraph).
	MatchQ([:node, "n", "Employee"]).
	WhereQ([:equals, "n.salary", 50000]).
	ReturnQ("n").

	Run()

? len(aResults)
#--> 2

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Filter with comparison

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:salary = 50000])
	AddNodeXTT("bob", "Employee", [:salary = 60000])
	AddNodeXTT("carol", "Employee", [:salary = 70000])
}

# Query: MATCH (n) WHERE n.salary > 55000 RETURN n
aResults = CypherQ(oGraph).
	MatchQ([:node, "n"]).
	WhereQ([:gt, "n.salary", 55000]).
	ReturnQ("n").

	Run()

? len(aResults)
#--> 2

? @@( aResults[1]["n"][:id] )
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

# Query: MATCH (n) WHERE n.name CONTAINS "Alice" RETURN n
aResults = CypherQ(oGraph).
	MatchQ([:node, "n"]).
	WhereQ([:contains, "n.name", "Alice"]).
	ReturnQ("n").

	Run()

? len(aResults)
#--> 2

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Filter with AND condition

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:age = 30, :dept = "Engineering"])
	AddNodeXTT("bob", "Employee", [:age = 25, :dept = "Engineering"])
	AddNodeXTT("carol", "Employee", [:age = 30, :dept = "Sales"])
}

# Query: MATCH (n) WHERE n.age = 30 AND n.dept = "Engineering" RETURN n
aResults = CypherQ(oGraph).
	MatchQ([:node, "n"]).
	WhereQ([:and, 
		[:equals, "n.age", 30],
		[:equals, "n.dept", "Engineering"]
	]).
	ReturnQ("n").

	Run()

? len(aResults)
#--> 1

? @@( aResults[1]["n"][:id] )
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

# Query: MATCH (n) WHERE n.dept = "Sales" OR n.dept = "Engineering" RETURN n
aResults = CypherQ(oGraph).
	MatchQ([:node, "n"]).
	WhereQ([:or,
		[:equals, "n.dept", "Sales"],
		[:equals, "n.dept", "Engineering"]
	]).
	ReturnQ("n").

	Run()

? len(aResults)
#--> 3

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Filter with NOT condition

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:active = TRUE])
	AddNodeXTT("bob", "Employee", [:active = FALSE])
	AddNodeXTT("carol", "Employee", [:active = TRUE])
}

# Query: MATCH (n) WHERE NOT n.active = FALSE RETURN n
aResults = CypherQ(oGraph).
	MatchQ([:node, "n"]).
	WhereQ([:not, [:equals, "n.active", FALSE]]).
	ReturnQ("n").

	Run()

? len(aResults)
#--> 2

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

# Query: MATCH (n) WHERE n.salary > 55000 RETURN n (using function)
CypherQ(oGraph) {
	Match([:node, "n"])

	Where(func(aBinding) {
		if HasKey(aBinding, "n")
			aNode = aBinding["n"]
			if HasKey(aNode[:properties], "salary")
				return aNode[:properties]["salary"] > 55000
			ok
		ok
		return FALSE
	})

	Return_("n")
	aResults = Run()
	? len(aResults)
	#--> 3

	? @@NL(Explain())
}
#--> [
# 	[
# 		"match",
# 		[ "Scan all nodes, bind to variable 'n'" ]
# 	],
# 	[
# 		"where",
# 		[
# 			"Filter bindings using conditions: Always true"
# 		]
# 	],
# 	[
# 		"return",
# 		[ "Project fields: n" ]
# 	],
# 	[
# 		"complexity",
# 		[ "Node scans: 1" ]
# 	]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.25

#------------------------#
#  RETURN PROJECTIONS    #
#------------------------#

/*--- Return specific property

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:name = "Alice", :age = 30])
	AddNodeXTT("bob", "Employee", [:name = "Bob", :age = 25])
}

# Query: MATCH (n) RETURN n.name
aResults = CypherQ(oGraph).
	MatchQ([:node, "n"]).
	ReturnQ("n.name").

	Run()

? len(aResults)
#--> 2

? @@( aResults[1]["n.name"] )
#--> "Alice"

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Return with alias

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:age = 30])
	AddNodeXTT("bob", "Employee", [:age = 25])
}

# Query: MATCH (n) RETURN n.age AS years
aResults = CypherQ(oGraph).
	MatchQ([:node, "n"]).
	ReturnQ([:as, "n.age", "years"]).
	Run()

? @@(aResults)
#--> [ [ [ "years", 30 ] ], [ [ "years", 25 ] ] ]

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Return multiple fields

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:name = "Alice", :age = 30])
	AddNodeXTT("bob", "Employee", [:name = "Bob", :age = 25])
}

# Query: MATCH (n) RETURN n.name, n.age
aResults = CypherQ(oGraph).
	MatchQ([:node, "n"]).
	ReturnQ(["n.name", "n.age"]).
	Run()

? len(aResults)
#--> 2

? @@( aResults[1] )
#--> ["n.name" = "Alice", "n.age" = 30]

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Return DISTINCT

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:dept = "Engineering"])
	AddNodeXTT("bob", "Employee", [:dept = "Sales"])
	AddNodeXTT("carol", "Employee", [:dept = "Engineering"])
}

# Query: MATCH (n) RETURN DISTINCT n.dept
aResults = CypherQ(oGraph).
	MatchQ([:node, "n"]).
	DistinctQ().
	ReturnQ("n.dept").

	Run()

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

# Query: MATCH (n) RETURN n ORDER BY n.age ASC
aResults = CypherQ(oGraph).
	MatchQ([:node, "n"]).
	ReturnQ("n").
	OrderByQ("n.age", :asc).

	Run()

? @@( aResults[1]["n"][:id] )
#--> "bob"

? @@( aResults[3]["n"][:id] )
#--> "carol"

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Order by descending

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:salary = 50000])
	AddNodeXTT("bob", "Employee", [:salary = 60000])
	AddNodeXTT("carol", "Employee", [:salary = 70000])
}

# Query: MATCH (n) RETURN n ORDER BY n.salary DESC
aResults = CypherQ(oGraph).
	MatchQ([:node, "n"]).
	ReturnQ("n").
	OrderByQ("n.salary", :desc).

	Run()

? @@( aResults[1]["n"][:id] )
#--> "carol"

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Limit results

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNode("alice")
	AddNode("bob")
	AddNode("carol")
	AddNode("dave")
}

# Query: MATCH (n) RETURN n LIMIT 2
aResults = CypherQ(oGraph).
	MatchQ([:node, "n"]).
	ReturnQ("n").
	LimitQ(2).

	Run()

? len(aResults)
#--> 2

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Skip and Limit

pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:rank = 1])
	AddNodeXTT("bob", "Employee", [:rank = 2])
	AddNodeXTT("carol", "Employee", [:rank = 3])
	AddNodeXTT("dave", "Employee", [:rank = 4])
}

# Query: MATCH (n) RETURN n ORDER BY n.rank SKIP 1 LIMIT 2
aResults = CypherQ(oGraph).
	MatchQ([:node, "n"]).
	ReturnQ("n").
	OrderByQ("n.rank", :asc).
	SkipQ(1).
	LimitQ(2).

	Run()

? len(aResults)
#--> 2

? @@( aResults[1]["n"][:id] )
#--> "bob"

pf()
# Executed in 0.01 second(s) in Ring 1.25

#--------------------#
#  CREATE PATTERNS   #
#--------------------#

/*---

pr()

oGraph = new stzGraph("test")

oQuery = new stzGraphCypher(oGraph)
oQuery.Create([:node, "n", "Person", [:name = "Alice"]])
oQuery.Run()
oQuery.GraphObject()
? @@NL( oQuery.GraphQ().Nodes() )
? oQuery.GraphQ().NodeCount()
#--> 1
#ERR we got 0!

pf()

/*--- Create single node

pr()

oGraph = new stzGraph("test")

# Pattern 1: Access via GraphQ()
CypherQ(oGraph) {
	Create([:node, "n", "Person", [:name = "Alice"]])
	Run()
	? GraphQ().NodeCount()
	#--> 1
}

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Create relationship

pr()

oGraph = new stzGraph("test")
oGraph {
	AddNode("alice")
	AddNode("bob")
}

# Query: MATCH (a {id: "alice"}), (b {id: "bob"}) 
#        CREATE (a)-[:KNOWS]->(b)
CypherQ(oGraph) {
	Match([:node, "a", [:id = "alice"]])
	Match([:node, "b", [:id = "bob"]])
	Create([:rel, "a", "b", "KNOWS"])
	Run()

	? GraphQ().EdgeCount() #--> 1
}

pf()
# Executed in almost 0 second(s) in Ring 1.25

#------------------#
#  UPDATE PATTERNS #
#------------------#

/*--- Set property

pr()

oGraph = new stzGraph("test")
oGraph {
	AddNodeXTT("alice", "Person", [:age = 30])
}

# Query: MATCH (n {id: "alice"}) SET n.age = 31
CypherQ(oGraph) {
	Match([:node, "n", [:id = "alice"]])
	Set([:set, "n.age", 31])
	Run()
	? GraphObject().NodeProperty("alice", "age") #--> 31
}

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Set multiple properties

pr()

oGraph = new stzGraph("test")
oGraph {
	AddNodeXTT("alice", "Person", [:age = 30])
}

# Query: MATCH (n {id: "alice"}) SET n.age = 31, n.city = "Paris"
CypherQ(oGraph) {
	Match([:node, "n", [:id = "alice"]])
	Set([:set, "n.age", 31])
	Set([:set, "n.city", "Paris"])
	Run()
}

? oGraph.NodeProperty("alice", "age")
#--> 31

? oGraph.NodeProperty("alice", "city")
#--> "Paris"

pf()
# Executed in almost 0 second(s) in Ring 1.25

#------------------#
#  DELETE PATTERNS #
#------------------#

/*--- Delete node

pr()

oGraph = new stzGraph("test")
oGraph {
	AddNode("alice")
	AddNode("bob")
}

# Query: MATCH (n {id: "alice"}) DELETE n
CypherQ(oGraph) {
	Match([:node, "n", [:id = "alice"]])
	Delete("n")
	Run()
}

? oGraph.NodeCount()
#--> 1

pf()

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

# Query: MATCH (a {id: "alice"})-[:FRIEND]->()-[:FRIEND]->(fof) RETURN fof
# Note: This requires two relationship matches

CypherQ(oGraph) {
	Match([:node, "a", [:id = "alice"]])
	Match([:rel, "a", "friend", "FRIEND"])
	Match([:rel, "friend", "fof", "FRIEND"])
	Return_("fof")
	
	aResults = Run()
}

? len(aResults)
#--> 2 (carol and dave)

? @@NL( aResults )
#--> [
# 	[
# 		[
# 			"fof",
# 			[
# 				[ "id", "carol" ],
# 				[ "label", "carol" ],
# 				[ "properties", [  ] ]
# 			]
# 		]
# 	],
# 	[
# 		[
# 			"fof",
# 			[
# 				[ "id", "dave" ],
# 				[ "label", "dave" ],
# 				[ "properties", [  ] ]
# 			]
# 		]
# 	]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.25

/*--- Recommendation engine pattern

pr()

oGraph = new stzGraph("recommendations")
oGraph {
	AddNodeXT("alice", "User")
	AddNodeXT("bob", "User")
	AddNodeXT("movie1", "Movie")
	AddNodeXT("movie2", "Movie")
	AddNodeXT("movie3", "Movie")
	
	ConnectXT("alice", "movie1", "WATCHED")
	ConnectXT("alice", "movie2", "WATCHED")
	ConnectXT("bob", "movie1", "WATCHED")
	ConnectXT("bob", "movie3", "WATCHED")
}

# Get alice's watched movies
aAliceMovies = CypherQ(oGraph).
	MatchQ([:node, "alice", [:id = "alice"]]).
	MatchQ([:rel, "alice", "m", "WATCHED"]).
	ReturnQ("m.id").
	Run()

acAliceIds = []
for i = 1 to len(aAliceMovies)
	acAliceIds + aAliceMovies[i]["m.id"]
next

# Find recommendations
oCypher = CypherQ(oGraph)
oCypher.Match([:node, "alice", [:id = "alice"]])
oCypher.Match([:rel, "alice", "common", "WATCHED"])
oCypher.Match([:rel, "other", "common", "WATCHED"])
oCypher.Match([:rel, "other", "rec", "WATCHED"])

oCypher.Where([:and,
	[:not, [:equals, "other.id", "alice"]],
	[:not, ["in", "rec.id", acAliceIds]]
])

oCypher.Return_("rec")
oCypher.Distinct()

aResults = oCypher.Run()

? len(aResults) #--> 1
? @@NL(aResults)
#--> [
# 	[
#  		[
# 			"rec",
# 			[
# 				[ "id", "movie3" ],
# 				[ "label", "Movie" ],
# 				[ "properties", [  ] ]
# 			]
# 		]
# 	]
# ]

# EXPLNANATION OF THE QUERY PLAN
? ""
? @@NL( oCypher.Explain() )
#--> [
	[
		"match",
		[
			"Scan all nodes, bind to variable 'alice' with properties {id: "alice"}",
			"Match relationships: (alice)-[]->(common) of type 'WATCHED'",
			"Match relationships: (other)-[]->(common) of type 'WATCHED'",
			"Match relationships: (other)-[]->(rec) of type 'WATCHED'"
		]
	],
	[
		"where",
		[
			'Filter bindings using conditions: (NOT (other.id = "alice") AND NOT (rec.id IN ["movie1", "movie2"]))'
		]
	],
	[
		"return",
		[ "Apply DISTINCT filter", "Project fields: rec" ]
	],
	[
		"complexity",
		[ "Node scans: 1", "Edge scans: 3" ]
	]
]

pf()
# Executed in 0.05 second(s) in Ring 1.25

/*--- Organizational hierarchy depth

pr()

oGraph = new stzGraph("org")
oGraph {
	AddNode("ceo")
	AddNode("vp")
	AddNode("manager")
	AddNode("employee")
	
	ConnectXT("ceo", "vp", "MANAGES")
	ConnectXT("vp", "manager", "MANAGES")
	ConnectXT("manager", "employee", "MANAGES")
}

#NOTE The query only matches direct paths (one hop).
# For transitive closure (all subordinates), you need
# to match multiple path depths or use recursive logic.
# Current approach only gets direct reports (ceo → vp).

#TODO For a general solution, Cypher typically uses variable-length
# paths [:MANAGES*], which would require extending the pattern matcher.

# Find all people managed by CEO (direct and indirect)
aResults = CypherQ(oGraph).
	MatchQ([:node, "ceo", [:id = "ceo"]]).
	MatchQ([:rel, "ceo", "subordinate", "MANAGES"]).
	ReturnQ("subordinate").
	Run()

? "Direct reports: " + len(aResults)

# For multi-level, match multiple paths
aAll = []

# Level 1: CEO -> subordinate
a1 = CypherQ(oGraph).
	MatchQ([:node, "ceo", [:id = "ceo"]]).
	MatchQ([:rel, "ceo", "sub", "MANAGES"]).
	ReturnQ("sub.id").
	Run()

# Level 2: CEO -> mid -> subordinate  
a2 = CypherQ(oGraph).
	MatchQ([:node, "ceo", [:id = "ceo"]]).
	MatchQ([:rel, "ceo", "mid", "MANAGES"]).
	MatchQ([:rel, "mid", "sub", "MANAGES"]).
	ReturnQ("sub.id").
	Run()

# Level 3: CEO -> mid1 -> mid2 -> subordinate
a3 = CypherQ(oGraph).
	MatchQ([:node, "ceo", [:id = "ceo"]]).
	MatchQ([:rel, "ceo", "m1", "MANAGES"]).
	MatchQ([:rel, "m1", "m2", "MANAGES"]).
	MatchQ([:rel, "m2", "sub", "MANAGES"]).
	ReturnQ("sub.id").
	Run()

# Total subordinates
? (len(a1) + len(a2) + len(a3))
#--> 3 (vp, manager, employee through direct paths)

pf()
# Executed in 0.03 second(s) in Ring 1.25

#============================#
#  OPENCYPHER IMPORT/EXPORT  #
#============================#

/*--- Export to OpenCypher format

pr()

oGraph = new stzGraph("test")
oGraph {
	AddNodeXT("alice", "Person")
	AddNodeXT("bob", "Person")
	SetNodeProperty("alice", "age", 30)
}

# Build query
oQuery = CypherQ(oGraph)
oQuery {
	Match([:node, "n", "Person"])
	Where([:gt, "n.age", 25])
	Return_("n")
	OrderBy("n.age", :desc)
	Limit(10)

	? ToOpenCypher()
}
#-->
`
MATCH (n:Person)
WHERE n.age > 25
RETURN n
ORDER BY n.age DESC
LIMIT 10
`

pf()
# Executed in almost 0 second(s) in Ring 1.25

/*--- Load from OpenCypher
*/
pr()

oGraph = new stzGraph("test")
oGraph {
	AddNodeXTT("alice", "Person", [:age = 30])
	AddNodeXTT("bob", "Person", [:age = 25])
	AddNodeXTT("carol", "Person", [:age = 35])
}

cCypherQuery = "
MATCH (n:Person)
WHERE n.age > 25
RETURN n
LIMIT 2
"

oQuery = new stzGraphCypher(oGraph)
oQuery.LoadFromOpenCypher(cCypherQuery)
aResults = oQuery.Run()

? len(aResults)
#--> 2
#ERR Got 0!

pf()

#========================#
#  REAL-WORLD USE CASES  #
#========================#

/*--- Social network: Mutual friends

pr()

oGraph = new stzGraph("social")
oGraph {
	AddNode("alice")
	AddNode("bob")
	AddNode("carol")
	AddNode("dave")
	
	# Alice's friends
	ConnectXT("alice", "bob", "FRIEND")
	ConnectXT("alice", "carol", "FRIEND")
	
	# Dave's friends
	ConnectXT("dave", "bob", "FRIEND")
	ConnectXT("dave", "carol", "FRIEND")
}

# Find mutual friends between Alice and Dave
aResults = CypherQ(oGraph).

	MatchQ([:rel, "alice", "mutual", "FRIEND"]).
	MatchQ([:rel, "dave", "mutual", "FRIEND"]).

	WhereQ([:and,
		[:equals, "alice.id", "alice"],
		[:equals, "dave.id", "dave"]
	]).

	ReturnQ("mutual").
	Run()

? len(aResults)
#--> 2 (bob and carol)
#ERR Got 0!

pf()

/*--- E-commerce: Product recommendations

pr()

oGraph = new stzGraph("ecommerce")
oGraph {
	AddNodeXT("user1", "Customer")
	AddNodeXT("user2", "Customer")
	AddNodeXT("prod_a", "Product")
	AddNodeXT("prod_b", "Product")
	AddNodeXT("prod_c", "Product")
	
	ConnectXTT("user1", "prod_a", "BOUGHT", [:rating = 5])
	ConnectXTT("user1", "prod_b", "BOUGHT", [:rating = 4])
	ConnectXTT("user2", "prod_a", "BOUGHT", [:rating = 5])
	ConnectXTT("user2", "prod_c", "BOUGHT", [:rating = 5])
}

# Find highly-rated products bought by similar users
aResults = CypherQ(oGraph).

	MatchQ([:rel, "user1", "common_prod", "BOUGHT"]).
	MatchQ([:rel, "user2", "common_prod", "BOUGHT"]).
	MatchQ([:rel, "user2", "recommendation", "BOUGHT"]).

	WhereQ([:and,
		[:and,
			[:equals, "user1.id", "user1"],
			[:not, [:equals, "user2.id", "user1"]]
		],
		[:not, [:equals, "recommendation.id", "common_prod.id"]]
	]).

	ReturnQ("recommendation").
	DistinctQ().

	Run()

? len(aResults)
#--> 1 (prod_c)
#ERR Got 0!

pf()
# Executed in 0.08 second(s) in Ring 1.25

/*--- Knowledge graph: Multi-hop reasoning

pr()

oGraph = new stzGraph("knowledge")
oGraph {
	AddNodeXT("paris", "City")
	AddNodeXT("france", "Country")
	AddNodeXT("europe", "Continent")
	
	ConnectXT("paris", "france", "LOCATED_IN")
	ConnectXT("france", "europe", "PART_OF")
	
	SetNodeProperty("paris", "population", 2200000)
}

# Find continent of cities with population > 1M
aResults = CypherQ(oGraph).

	MatchQ([:rel, "city", "country", "LOCATED_IN"]).
	MatchQ([:rel, "country", "continent", "PART_OF"]).

	WhereQ([:gt, "city.population", 1000000]).

	ReturnQ(["city", "continent"]).
	Run()

? @@( aResults[1]["city"][:id] )
#--> "paris"

? @@( aResults[1]["continent"][:id] )
#--> "europe"

#ERR: Can't access the list item, Object is not list

pf()

/*--- Supply chain: Critical path analysis

pr()

oGraph = new stzGraph("supply_chain")
oGraph {
	AddNodeXT("supplier", "Location")
	AddNodeXT("factory", "Location")
	AddNodeXT("warehouse", "Location")
	AddNodeXT("customer", "Location")
	
	ConnectXTT("supplier", "factory", "SHIPS_TO", [:time = 2])
	ConnectXTT("factory", "warehouse", "SHIPS_TO", [:time = 3])
	ConnectXTT("warehouse", "customer", "SHIPS_TO", [:time = 1])
}

# Find complete supply chain paths
aResults = CypherQ(oGraph).

	MatchQ([:path, "start", "r1", "mid1"]).
	MatchQ([:path, "mid1", "r2", "mid2"]).
	MatchQ([:path, "mid2", "r3", "end"]).

	WhereQ([:equals, "start.id", "supplier"]).

	ReturnQ(["start", "mid1", "mid2", "end"]).
	Run()

? len(aResults)
#--> 1 (complete path from supplier to customer)
#ERR Got 0!
