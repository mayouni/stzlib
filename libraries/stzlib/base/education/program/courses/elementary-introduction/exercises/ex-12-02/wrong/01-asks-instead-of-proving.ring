# A query says only what was recorded: nobody recorded 'food'.
oKB = new stzKnowledgeGraph("menu")
oKB.KnowRelation("margherita", "kind-of", "pizza")
oKB.KnowRelation("pizza", "kind-of", "food")
oKB.ConstrainRelation("kind-of", :Transitive)
? @@( oKB.Query([ "margherita", "kind-of", "?o" ]) )
