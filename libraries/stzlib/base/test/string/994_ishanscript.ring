load "../../stzBase.ring"
load "../_narrated.ring"

# IsHanScript, singly and over a list. Archive block #994.

Scenario("Friends in Han")
	Then("a Han text", StzTextQ("朋友们").IsHanScript(), TRUE)
	Then("all three are Han texts",
		Q([ "你好", "亲", "朋友们" ]).Are([ :HanScript, :Texts ]), TRUE)
EndScenario()

Summary()
