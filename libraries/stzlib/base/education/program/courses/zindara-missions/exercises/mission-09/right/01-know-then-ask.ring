oZ = new stzKnowledgeGraph("zindara")
oZ.KnowRelation("amina", "sells", "bread")
oZ.KnowRelation("ibrahim", "sells", "cloth")
? @@( oZ.Query([ "amina", "sells", "?o" ]) )
