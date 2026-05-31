# Narrative
# --------
# Defining properties with constraints
#
# Extracted from stzknowledgegraphtest.ring, block #11.

load "../../../stzBase.ring"


pr()

oKG = new stzKnowledgeGraph("Schema")
oKG {
	DefineProperty(:Age, [
		:type = "number",
		:min = 0,
		:max = 150
	])
	
	DefineProperty(:Name, [
		:type = "string",
		:required = TRUE
	])
	
	# Ontology definitions

	? @@NL( Ontology() )
}
#-->
'
[
	[
		[ "property", "age" ],
		[
			"constraints",
			[
				[ "type", "number" ],
				[ "min", 0 ],
				[ "max", 150 ]
			]
		]
	],
	[
		[ "property", "name" ],
		[
			"constraints",
			[
				[ "type", "string" ],
				[ "required", 1 ]
			]
		]
	]
]
'

pf()

#===============================#
#  REAL-WORLD KNOWLEDGE GRAPHS  #
#===============================#
