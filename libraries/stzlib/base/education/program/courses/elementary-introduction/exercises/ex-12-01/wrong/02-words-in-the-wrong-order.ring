# Subject, relation, object: 'dish' is not a relation.
oKB = new stzKnowledgeGraph("menu")
oKB.KnowRelation("margherita", "dish", "is-a")
oKB.KnowRelation("tiramisu", "dish", "is-a")
? oKB.ExportToKnow()
