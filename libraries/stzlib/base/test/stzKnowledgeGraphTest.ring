load "../stzbase.ring"

#====================#
#  TRIPLE INTERFACE  #
#====================#

/*--- Adding facts (triples)

pr()

oKG = new stzKnowledgeGraph("Animals")
oKG {
	AddFact("Dogs", :IsA, "Animals")
	AddFact("Dogs", :Eats, "Food")
	AddFact("Cats", :IsA, "Animals")
	
	? @@NL( Facts() )
	#--> [
	#     ["Dogs", :IsA, "Animals"],
	#     ["Dogs", :Eats, "Food"],
	#     ["Cats", :IsA, "Animals"]
	#    ]
}

pf()

/*--- Removing facts

pr()

oKG = new stzKnowledgeGraph("Simple")
oKG {
	AddFact("X", :RelatesTo, "Y")
	AddFact("X", :DifferentFrom, "Z")
	
	# efore removal

	? @@NL( Facts() )
	#--> [
	# 	[ "X", "relatesto", "Y" ],
	# 	[ "X", "differentfrom", "Z" ]
	# ]

	RemoveFact("X", :DifferentFrom, "Z")
	
	# After removal

	? @@NL( Facts() )
	#--> [ ["X", :RelatesTo, "Y"] ]
}

pf()

#====================#
#  QUERY INTERFACE   #
#====================#

/*--- Query with variable subject

pr()

oKG = new stzKnowledgeGraph("Taxonomy")
oKG {
	AddFact("Dogs", :IsA, "Mammals")
	AddFact("Cats", :IsA, "Mammals")
	AddFact("Birds", :IsA, "Animals")
	
	# What is a Mammal?
	? @@( Query(["?x", :IsA, "Mammals"]) )
	#--> ["Dogs", "Cats"]
}

pf()

/*--- Query with variable object

pr()

oKG = new stzKnowledgeGraph("Food")
oKG {
	AddFact("Dogs", :Eats, "Meat")
	AddFact("Dogs", :Drinks, "Water")
	AddFact("Cats", :Eats, "Fish")
	
	# What does Dogs eat/drink?

	? @@( Query(["Dogs", :Eats, "?what"]) )
	#--> ["Meat"]
	
	? @@( Query(["Dogs", :Drinks, "?what"]) )
	#--> ["Water"]
}

pf()

/*--- Query both variables

pr()

oKG = new stzKnowledgeGraph("Relations")
oKG {
	AddFact("Alice", :Knows, "Bob")
	AddFact("Charlie", :Knows, "Diana")
	AddFact("Alice", :WorksWith, "Eve")
	
	# Who knows whom?

	? @@NL( Query(["?x", :Knows, "?y"]) )
	#--> [
	#     ["Alice", "Bob"],
	#     ["Charlie", "Diana"]
	#    ]
}

pf()

/*--- Query existence check

pr()

oKG = new stzKnowledgeGraph("Check")
oKG {
	AddFact("Earth", :OrbitsAround, "Sun")
	AddFact("Moon", :OrbitsAround, "Earth")
	
	# Does Earth orbit Sun?

	? Query(["Earth", :OrbitsAround, "Sun"])
	#--> TRUE
	
	# Does Sun orbit Earth?

	? Query(["Sun", :OrbitsAround, "Earth"])
	#--> FALSE
}

pf()

#======================#
#  ENTITY ANALYSIS     #
#======================#

/*--- Finding predicates of entity

pr()

oKG = new stzKnowledgeGraph("Person")
oKG {
	AddFact("Alice", :WorksAt, "Company")
	AddFact("Alice", :LivesIn, "City")
	AddFact("Alice", :Knows, "Bob")
	
	# What predicates does Alice have?

	? @@( Predicates("Alice") )
	#--> [:WorksAt, :LivesIn, :Knows]
}

pf()

/*--- Finding all relations of entity

pr()

oKG = new stzKnowledgeGraph("Network")
oKG {
	AddFact("Node1", :ConnectsTo, "Node2")
	AddFact("Node1", :HasProperty, "Active")
	AddFact("Node1", :PartOf, "System")
	
	# All relations of Node1

	? @@NL( Relations("Node1") )
	#--> [
	#     [:ConnectsTo, "Node2"],
	#     [:HasProperty, "Active"],
	#     [:PartOf, "System"]
	# ]
}

pf()

/*--- Finding similar entities

pr()

oKG = new stzKnowledgeGraph("Comparison")
oKG {
	AddFact("Dogs", :IsA, "Mammals")
	AddFact("Dogs", :HasLegs, "4")
	AddFact("Dogs", :Eats, "Meat")
	
	AddFact("Cats", :IsA, "Mammals")
	AddFact("Cats", :HasLegs, "4")
	AddFact("Cats", :Eats, "Meat")
	
	AddFact("Birds", :IsA, "Animals")
	AddFact("Birds", :HasLegs, "2")
	
	# Entities similar to Dogs

	? @@NL( SimilarTo("Dogs") )
	#--> [ ["Cats", 3], ["Birds", 2] ]
	# Cats shares 3 predicates, Birds shares 2 predicates
}

pf()

#=====================#
#  ONTOLOGY SUPPORT   #
#=====================#

/*--- Defining class hierarchy

pr()

oKG = new stzKnowledgeGraph("Taxonomy")
oKG {
	DefineClass("Mammals", "Animals")
	DefineClass("Dogs", "Mammals")
	DefineClass("Cats", "Mammals")
	
	# Class hierarchy as facts

	? @@NL( Facts() )
	#--> [
	#     ["Mammals", :SubClassOf, "Animals"],
	#     ["Dogs", :SubClassOf, "Mammals"],
	#     ["Cats", :SubClassOf, "Mammals"]
	# ]
}

pf()

/*--- Defining properties with constraints

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

/*--- Family tree knowledge graph

pr()

oKG = new stzKnowledgeGraph("Family")
oKG {
	AddFact("Alice", :ParentOf, "Bob")
	AddFact("Alice", :ParentOf, "Charlie")
	AddFact("Bob", :SiblingOf, "Charlie")
	AddFact("Bob", :ParentOf, "Diana")
	
	# Who are Alice's children?

	? @@( Query(["Alice", :ParentOf, "?child"]) )
	#--> ["Bob", "Charlie"]

	# Who is Bob's sibling?

	? @@( Query(["Bob", :SiblingOf, "?sibling"]) )
	#--> ["Charlie"]

	# Predicates about Bob:

	? @@( Predicates("Bob") )
	#--> [:SiblingOf, :ParentOf]
}

pf()

/*--- Company organization knowledge graph

pr()

oKG = new stzKnowledgeGraph("Company")
oKG {
	AddFact("Alice", :WorksIn, "Engineering")
	AddFact("Alice", :ReportsTo, "Manager1")
	AddFact("Bob", :WorksIn, "Engineering")
	AddFact("Bob", :ReportsTo, "Manager1")
	AddFact("Charlie", :WorksIn, "Sales")
	
	# Who works in Engineering?

	? @@( Query(["?who", :WorksIn, "Engineering"]) )
	#--> ["Alice", "Bob"]

	# Who reports to Manager1?

	? @@( Query(["?who", :ReportsTo, "Manager1"]) )
	#--> ["Alice", "Bob"]
	
	# Similar employees to Alice:

	? @@NL( SimilarTo("Alice") )
	#--> [["Bob", 2], [ "Charlie", 1 ]]
}

pf()

/*--- Scientific taxonomy

pr()

oKG = new stzKnowledgeGraph("Science")
oKG {
	DefineClass("Vertebrates", "Animals")
	DefineClass("Mammals", "Vertebrates")
	DefineClass("Reptiles", "Vertebrates")
	
	AddFact("Dogs", :IsA, "Mammals")
	AddFact("Cats", :IsA, "Mammals")
	AddFact("Snakes", :IsA, "Reptiles")
	
	# What are Vertebrates?
	? @@( Query(["?x", :SubClassOf, "Vertebrates"]) )
	#--> ["Mammals", "Reptiles"]
	
	# What are Mammals?
	? @@( Query(["?x", :IsA, "Mammals"]) )
	#--> ["Dogs", "Cats"]
}

pf()

#=============================#
#  INHERITS GRAPH ALGORITHMS  #
#=============================#

/*--- Using graph algorithms on knowledge graph

pr()

oKG = new stzKnowledgeGraph("Network")
oKG {
	AddFact("A", :ConnectsTo, "B")
	AddFact("B", :ConnectsTo, "C")
	AddFact("C", :ConnectsTo, "D")
	
	# Shortest path from A to D
	? @@( ShortestPath(:From = "A", :To = "D") )
	#--> ["A", "B", "C", "D"]
	
	# Is the knowledge graph connected?
	? IsConnected()
	#--> TRUE
	
	# Critical entities (articulation points)
	? @@( ArticulationPoints() )
	#--> ["B", "C"]
}

pf()

/*--- Combined: Knowledge + Structure analysis

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
*/
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
	? "Inferred " + nInferred + " new facts through transitivity"
	
	# Display all facts
	? NL + BoxRound("ALL FACTS (INCLUDING INFERRED") + NL
	aAllFacts = Facts()
	for i = 1 to min([15, len(aAllFacts)])
		aFact = aAllFacts[i]
		? aFact[1] + " " + aFact[2] + " " + aFact[3]
	next
	if len(aAllFacts) > 15
		? "... and " + (len(aAllFacts) - 15) + " more facts"
	ok
	
	# Query the knowledge graph
	? NL + BoxRound("QUERYING THE KNOWLEDGE GRAPH") + NL
	
	# Query 1: What are mammals?
	? "Query: What is a Mammal?"
	acMammals = Query(["?x", :IsA, "Mammals"])
	? "Answer: " + joinxt(acMammals, ", ")
	
	# Query 2: What do carnivores eat?
	? NL + "Query: What eats meat?"
	acCarnivores = Query(["?x", :Eats, "Meat"])
	? "Answer: " + joinxt(acCarnivores, ", ")
	
	# Query 3: What can fly?
	? NL + "Query: Which animals can fly?"
	acFlying = Query(["?x", :CanFly, "true"])
	? "Answer: " + joinxt(acFlying, ", ")
	
	# Analyze entity relationships
	? NL + BoxRound("ENTITY ANALYSIS") + NL
	? "Relationships of 'Dogs':"
	? @@NL( Relations("Dogs") )

	? NL + "Relationships of 'Lions':"
	? @@NL( Relations("Lions") )

	
	# Find similar entities
	? NL + BoxRound("SIMILARITY ANALYSIS") + NL
	? "Entities similar to 'Dogs':"
	? @@NL( SimilarTo("Dogs") )
	
	# Explain the knowledge graph
	? NL + BoxRound("KNOWLEDGE GRAPH EXPLANATION") + NL
	? @@NL( Explain() )
}

#-->
'
╭──────────────────────────╮
│ APPLYING INFERENCE RULES │
╰──────────────────────────╯

Inferred 16 new facts through transitivity

╭───────────────────────────────╮
│ ALL FACTS (INCLUDING INFERRED │
╰───────────────────────────────╯

Mammals subclassof Animals
Birds subclassof Animals
Fish subclassof Animals
Reptiles subclassof Animals
Dogs isa Mammals
Cats isa Mammals
Lions isa Mammals
Eagles isa Birds
Parrots isa Birds
Salmon isa Fish
Sharks isa Fish
Snakes isa Reptiles
Dogs eats Meat
Dogs livesin Houses
Cats eats Meat
... and 21 more facts

╭──────────────────────────────╮
│ QUERYING THE KNOWLEDGE GRAPH │
╰──────────────────────────────╯

Query: What is a Mammal?
Answer: Dogs, Cats, Lions

Query: What eats meat?
Answer: Dogs, Cats, Lions, Eagles

Query: Which animals can fly?
Answer: Eagles, Parrots

╭─────────────────╮
│ ENTITY ANALYSIS │
╰─────────────────╯

Relationships of 'Dogs':
[
	[ "isa", "Mammals" ],
	[ "eats", "Meat" ],
	[ "livesin", "Houses" ],
	[ "friendof", "Humans" ],
	[ "(inferred)", "Animals" ]
]

Relationships of 'Lions':
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

Entities similar to 'Dogs':
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
		"Knowledge graph 'Animal Kingdom' contains 24 entities and 36 facts."
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
'

pf()


/*---
OUTPUT:

=== APPLYING INFERENCE RULES ===

Inferred 8 new facts through transitivity

=== ALL FACTS (INCLUDING INFERRED) ===

Mammals SubClassOf Animals
Birds SubClassOf Animals
Fish SubClassOf Animals
Reptiles SubClassOf Animals
Dogs IsA Mammals
Cats IsA Mammals
Lions IsA Mammals
Eagles IsA Birds
Parrots IsA Birds
Salmon IsA Fish
Sharks IsA Fish
Snakes IsA Reptiles
Dogs Eats Meat
Dogs LivesIn Houses
Cats Eats Meat
... and 15 more facts

=== QUERYING THE KNOWLEDGE GRAPH ===

Query: What is a Mammal?
Answer: Dogs, Cats, Lions

Query: What eats meat?
Answer: Dogs, Cats, Lions, Eagles

Query: Which animals can fly?
Answer: Eagles, Parrots

=== ENTITY ANALYSIS ===

Relationships of 'Dogs':
  IsA -> Mammals
  Eats -> Meat
  LivesIn -> Houses
  FriendOf -> Humans

Relationships of 'Lions':
  IsA -> Mammals
  Eats -> Meat
  LivesIn -> Savanna
  LivesWith -> Prides

=== SIMILARITY ANALYSIS ===

Entities similar to 'Dogs':
  Cats (overlap: 3 predicates)
  Lions (overlap: 2 predicates)
  Eagles (overlap: 1 predicates)

=== KNOWLEDGE GRAPH EXPLANATION ===

Knowledge graph 'Animal Kingdom' contains 22 entities and 30 facts.

Sample Facts:
  Mammals SubClassOf Animals
  Birds SubClassOf Animals
  Fish SubClassOf Animals
  Reptiles SubClassOf Animals
  Dogs IsA Mammals
  ... and 25 more facts

Entities:
  Mammals, Birds, Fish, Reptiles, Dogs, Cats, Lions, Eagles, Parrots, Salmon
  ... and 12 more

Predicates:
  SubClassOf, IsA, Eats, LivesIn, Hunts, CanFly, FriendOf, LivesWith

Patterns:
  Most connected entity: Dogs (4 relationships)
  Moderate connectivity (35% density)

Insights:
  Contains circular relationships (cycles detected)
  Inference rules generated new knowledge

=== GENERATING VISUALIZATION ===
[SVG visualization opens showing the knowledge graph]
