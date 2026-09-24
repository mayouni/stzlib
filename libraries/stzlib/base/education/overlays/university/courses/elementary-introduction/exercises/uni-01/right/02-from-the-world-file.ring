oU = new stzKnowledgeGraph("university")
oU.ImportKnow('knowledge "u"' + char(10) + char(10) + "facts" + char(10) + "    informatique | offered-by | faculty-of-science" + char(10) + "    mathematiques | offered-by | faculty-of-science" + char(10) + "    droit | offered-by | faculty-of-law" + char(10))
? @@( oU.Query([ "?c", "offered-by", "faculty-of-science" ]) )
