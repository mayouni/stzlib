oWorld = new stzKnowledgeGraph("shop")
oWorld.ImportKnow($cProjectFolder + "/world.zknw")
? @@( oWorld.Query([ "amina", "sells", "?o" ]) )
