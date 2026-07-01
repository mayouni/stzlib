load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceMany with an empty substring in the list is a safe no-op. Archive #261.

Scenario("ReplaceMany with an empty substring is a no-op")
	Given('" isNumber( 0+  @item  ) "')
	o1 = new stzString(" isNumber( 0+  @item  ) ")
	o1.ReplaceMany([ "" ], 'any')
	Then("the content is unchanged", o1.Content(), " isNumber( 0+  @item  ) ")
EndScenario()

Summary()
