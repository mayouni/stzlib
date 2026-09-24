# Prints every seller and every ware.
oZ = new stzKnowledgeGraph("zindara")
oZ.KnowRelation("amina", "sells", "bread")
oZ.KnowRelation("ibrahim", "sells", "cloth")
? @@( oZ.Query([ "?s", "sells", "?o" ]) )
