# Narrative
# --------
# Label automatic normalization
#
# Extracted from stzgraphtest.ring, block #2.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("")
oGraph {
	AddNodeXT("@name", "name of person")
	AddNodeXT("@age", "age of person")
	Connect("@name", "@age")

	? @@NL( Nodes() )
}
#--> Note how lables are normalised using "_" instead of spaces
'
[
	[
		[ "id", "@name" ],
		[ "label", "name_of_person" ],
		[ "properties", [  ] ]
	],
	[
		[ "id", "@age" ],
		[ "label", "age_of_person" ],
		[ "properties", [  ] ]
	]
]
'

pf()
# Executed in almost 0 second(s) in Ring 1.25
