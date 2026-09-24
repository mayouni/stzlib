oZ = new stzKnowledgeGraph("zindara")
oZ.ImportKnow('knowledge "zindara"' + char(10) + char(10) + "facts" + char(10) + "    amina | sells | bread" + char(10) + "    ibrahim | sells | cloth" + char(10))
? @@( oZ.Query([ "amina", "sells", "?o" ]) )
