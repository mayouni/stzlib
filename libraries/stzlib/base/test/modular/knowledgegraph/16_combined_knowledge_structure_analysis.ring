# Narrative
# --------
# Combined: Knowledge + Structure analysis
#
# Extracted from stzknowledgegraphtest.ring, block #16.

load "../../../stzBase.ring"


pr()

oKG = new stzKnowledgeGraph("Hybrid")
oKG {
	AddFact("Concept1", :RelatesTo, "Concept2")
	AddFact("Concept2", :RelatesTo, "Concept3")
	AddFact("Concept3", :RelatesTo, "Concept1")
	
	# Knowledge Analysis
	#-------------------

	# What does Concept1 relate to?
	? @@( Query(["Concept1", :RelatesTo, "?x"]) )
	#--> [ "Concept2" ]

	# Relations of Concept2
	? @@NL( Relations("Concept2") ) + NL
	#--> [ [ "relatesto", "Concept3" ] ]

	# Structural Analysis
	#--------------------

	# Clustering coefficient of Concept2
	? ClusteringCoefficient("Concept2")
	#--> 1 (forms a triangle)
	
	# Betweenness centrality of Concept2
	? BetweennessCentrality("Concept2")
	#--> 0.50

}

pf()

#-------------------------------------------#
# Example : Animal Kingdom Knowledge Graph  #
#-------------------------------------------#
pr()

oAnimalKG = new stzKnowledgeGraph("Animal Kingdom")
oAnimalKG {
	# Define taxonomic hierarchy
	AddFact("Mammals", :SubClassOf, "Animals")
	AddFact("Birds", :SubClassOf, "Animals")
	AddFact("Fish", :SubClassOf, "Animals")
	AddFact("Reptiles", :SubClassOf, "Animals")
	
	# Specific animals
	AddFact("Dogs", :IsA, "Mammals")
	AddFact("Cats", :IsA, "Mammals")
	AddFact("Lions", :IsA, "Mammals")
	AddFact("Eagles", :IsA, "Birds")
	AddFact("Parrots", :IsA, "Birds")
	AddFact("Salmon", :IsA, "Fish")
	AddFact("Sharks", :IsA, "Fish")
	AddFact("Snakes", :IsA, "Reptiles")
	
	# Behavioral facts
	AddFact("Dogs", :Eats, "Meat")
	AddFact("Dogs", :LivesIn, "Houses")
	AddFact("Cats", :Eats, "Meat")
	AddFact("Cats", :Hunts, "Mice")
	AddFact("Lions", :Eats, "Meat")
	AddFact("Lions", :LivesIn, "Savanna")
	AddFact("Eagles", :Eats, "Meat")
	AddFact("Eagles", :CanFly, "true")
	AddFact("Parrots", :Eats, "Seeds")
	AddFact("Parrots", :CanFly, "true")
	AddFact("Salmon", :LivesIn, "Rivers")
	AddFact("Sharks", :LivesIn, "Oceans")
	AddFact("Snakes", :Eats, "Rodents")
	
	# Social relationships
	AddFact("Dogs", :FriendOf, "Humans")
	AddFact("Cats", :FriendOf, "Humans")
	AddFact("Lions", :LivesWith, "Prides")
	
	# Apply inference rules
	AddInferenceRule("TRANSITIVITY")
	? BoxRound("APPLYING INFERENCE RULES") + NL
	nInferred = ApplyInference()
	? "Inferred " + nInferred + " new facts through transitivity" + NL
	
	# Display all facts
	? NL + BoxRound("ALL FACTS (INCLUDING INFERRED)") + NL
	? @@NL( Facts() )
	
	# Query the knowledge graph
	? NL + BoxRound("QUERYING THE KNOWLEDGE GRAPH") + NL
	
	? 'Query: What is a Mammal?'
	? @@NL( Query(["?x", :IsA, "Mammals"]) )
	
	? NL + 'Query: What eats meat?'
	? @@NL( Query(["?x", :Eats, "Meat"]) )
	
	? NL + 'Query: Which animals can fly?'
	? @@NL( Query(["?x", :CanFly, "true"]) )
	
	# Analyze entity relationships
	? NL + BoxRound("ENTITY ANALYSIS") + NL
	? 'Relationships of "Dogs":'
	? @@NL( Relations("Dogs") )
	
	? NL + 'Relationships of "Lions":'
	? @@NL( Relations("Lions") )
	
	# Find similar entities
	? NL + BoxRound("SIMILARITY ANALYSIS") + NL
	? 'Entities similar to "Dogs":'
	? @@NL( SimilarTo("Dogs") )
	
	# Explain the knowledge graph
	? NL + BoxRound("KNOWLEDGE GRAPH EXPLANATION") + NL
	? @@NL( Explain() )

}

#-->
`
╭──────────────────────────╮
│ APPLYING INFERENCE RULES │
╰──────────────────────────╯

Inferred 16 new facts through transitivity


╭────────────────────────────────╮
│ ALL FACTS (INCLUDING INFERRED) │
╰────────────────────────────────╯

[
	[ "Mammals", "subclassof", "Animals" ],
	[ "Birds", "subclassof", "Animals" ],
	[ "Fish", "subclassof", "Animals" ],
	[ "Reptiles", "subclassof", "Animals" ],
	[ "Dogs", "isa", "Mammals" ],
	[ "Cats", "isa", "Mammals" ],
	[ "Lions", "isa", "Mammals" ],
	[ "Eagles", "isa", "Birds" ],
	[ "Parrots", "isa", "Birds" ],
	[ "Salmon", "isa", "Fish" ],
	[ "Sharks", "isa", "Fish" ],
	[ "Snakes", "isa", "Reptiles" ],
	[ "Dogs", "eats", "Meat" ],
	[ "Dogs", "livesin", "Houses" ],
	[ "Cats", "eats", "Meat" ],
	[ "Cats", "hunts", "Mice" ],
	[ "Lions", "eats", "Meat" ],
	[ "Lions", "livesin", "Savanna" ],
	[ "Eagles", "eats", "Meat" ],
	[ "Eagles", "canfly", "true" ],
	[ "Parrots", "eats", "Seeds" ],
	[ "Parrots", "canfly", "true" ],
	[ "Salmon", "livesin", "Rivers" ],
	[ "Sharks", "livesin", "Oceans" ],
	[ "Snakes", "eats", "Rodents" ],
	[ "Dogs", "friendof", "Humans" ],
	[ "Cats", "friendof", "Humans" ],
	[ "Lions", "liveswith", "Prides" ],
	[ "Dogs", "(inferred)", "Animals" ],
	[ "Cats", "(inferred)", "Animals" ],
	[ "Lions", "(inferred)", "Animals" ],
	[ "Eagles", "(inferred)", "Animals" ],
	[ "Parrots", "(inferred)", "Animals" ],
	[ "Salmon", "(inferred)", "Animals" ],
	[ "Sharks", "(inferred)", "Animals" ],
	[ "Snakes", "(inferred)", "Animals" ]
]

╭──────────────────────────────╮
│ QUERYING THE KNOWLEDGE GRAPH │
╰──────────────────────────────╯

Query: What is a Mammal?
[ "Dogs", "Cats", "Lions" ]

Query: What eats meat?
[
	"Dogs",
	"Cats",
	"Lions",
	"Eagles"
]

Query: Which animals can fly?
[ "Eagles", "Parrots" ]

╭─────────────────╮
│ ENTITY ANALYSIS │
╰─────────────────╯

Relationships of "Dogs":
[
	[ "isa", "Mammals" ],
	[ "eats", "Meat" ],
	[ "livesin", "Houses" ],
	[ "friendof", "Humans" ],
	[ "(inferred)", "Animals" ]
]

Relationships of "Lions":
[
	[ "isa", "Mammals" ],
	[ "eats", "Meat" ],
	[ "livesin", "Savanna" ],
	[ "liveswith", "Prides" ],
	[ "(inferred)", "Animals" ]
]

╭─────────────────────╮
│ SIMILARITY ANALYSIS │
╰─────────────────────╯

Entities similar to "Dogs":
[
	[ "Cats", 4 ],
	[ "Lions", 4 ],
	[ "Eagles", 3 ],
	[ "Parrots", 3 ],
	[ "Salmon", 3 ],
	[ "Sharks", 3 ],
	[ "Snakes", 3 ]
]

╭─────────────────────────────╮
│ KNOWLEDGE GRAPH EXPLANATION │
╰─────────────────────────────╯

[
	[ "type", "Knowledge Graph" ],
	[
		"structure",
		'Knowledge graph "Animal Kingdom" contains 24 entities and 36 facts.'
	],
	[
		"facts",
		[
			"Mammals subclassof Animals",
			"Birds subclassof Animals",
			"Fish subclassof Animals",
			"Reptiles subclassof Animals",
			"Dogs isa Mammals",
			"... and 31 more facts"
		]
	],
	[
		"entities",
		[
			"Entities: Mammals, Animals, Birds, Fish, Reptiles, Dogs, Cats, Lions, Eagles, Parrots",
			"... and 14 more"
		]
	],
	[
		"predicates",
		[
			"Predicates used: subclassof, isa, eats, livesin, hunts, canfly, friendof, liveswith, (inferred)"
		]
	],
	[
		"ontology",
		[ "No formal ontology defined" ]
	],
	[
		"patterns",
		[
			"Most connected entity: Dogs (5 relationships)",
			"Graph is sparse (6.52% density)"
		]
	],
	[
		"insights",
		[
			"Contains circular relationships (cycles detected)",
			"Many isolated entities - may need more connections"
		]
	]
]
`
# Executed in 0.10 second(s) in Ring 1.24

pf()
