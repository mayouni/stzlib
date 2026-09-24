oKB = new stzKnowledgeGraph("menu")
oKB.KnowRelation("margherita", "kind-of", "pizza")
oKB.KnowRelation("pizza", "kind-of", "food")
oKB.ConstrainRelation("kind-of", :Transitive)
? oKB.Prove([ "margherita", "kind-of", "food" ])[:narration]
