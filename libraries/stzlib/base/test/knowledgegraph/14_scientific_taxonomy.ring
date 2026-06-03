# Narrative
# --------
# Scientific taxonomy
#
# Extracted from stzknowledgegraphtest.ring, block #14.

load "../../stzBase.ring"


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
