oKB = new stzKnowledgeGraph("menu")
oKB.ImportKnow('knowledge "menu"' + char(10) + char(10) + "facts" + char(10) + "    margherita | kind-of | pizza" + char(10) + "    pizza | kind-of | food" + char(10) + char(10) + "ontology" + char(10) + "    kind-of | transitive" + char(10))
? oKB.Prove([ "margherita", "kind-of", "food" ])[:narration]
