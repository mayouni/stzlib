# Asks, prints the gaps twice, answers nothing.
oRest = new stzKnowledgeGraph("restaurant")
oRest.Know("margherita", "dish").Know("tiramisu", "dish")
oRest.AddConversationQ("setup").SetGoal(StzGoalQ().RequireEach("dish", "contains"))
? len( oRest.GapsIn("setup") )
oRest.AskInXT("setup")
? len( oRest.GapsIn("setup") )
