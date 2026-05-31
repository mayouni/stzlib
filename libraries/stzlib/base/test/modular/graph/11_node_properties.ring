# Narrative
# --------
# Node Properties
#
# Extracted from stzgraphtest.ring, block #11.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("PropsTest")
oGraph {
	AddNodeXTT("n1", "Node 1", [:priority = 10, :status = "active"])
	
	? NodeProperty("n1", "priority")
	#--> 10
	
	SetNodeProperty("n1", "owner", "alice")
	? NodeProperty("n1", "owner")
	#--> "alice"
	
	? @@( Properties() )
	#--> ["priority", "status", "owner"]

	? @@NL( PropertiesXT() )
	#-->
	'
	[
		[
			"priority",
			[ 10 ]
		],
		[
			"status",
			[ "active" ]
		],
		[
			"owner",
			[ "alice" ]
		]
	]
'
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
