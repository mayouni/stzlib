# Narrative
# --------
# Scenario 3: Serialization (future)
#
# Extracted from stzgraphquerytest.ring, block #28.

load "../../../stzBase.ring"


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

StzGraphQueryQ(oGraph) {
	Match([:node = "n"])
	Select("n.id")

	# Serilising the 
	cJSON = JsonXT(Definition())
	write("txtfiles/myquery.json", cJSON)

	# Later...
	cLoaded = read("txtfiles/myquery.json")
	SetDefinition(JsonToList(cLoaded))
	Execute()
	? @@( Result() )
}
#--> [ [ [ "n.id", "alice" ] ], [ [ "n.id", "bob" ] ], [ [ "n.id", "carol" ] ], [ [ "n.id", "dave" ] ] ]

#TODO Add ToJson() and FromJson()
#TODO Add a specific *.stzqwry file format

pf()
# Executed in 0.03 second(s) in Ring 1.26
