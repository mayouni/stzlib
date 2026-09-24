# Prints every course with its faculty.
oU = new stzKnowledgeGraph("university")
oU.KnowRelation("informatique", "offered-by", "faculty-of-science")
oU.KnowRelation("mathematiques", "offered-by", "faculty-of-science")
oU.KnowRelation("droit", "offered-by", "faculty-of-law")
? @@( oU.Query([ "?c", "offered-by", "?f" ]) )
