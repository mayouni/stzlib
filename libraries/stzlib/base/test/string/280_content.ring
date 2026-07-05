load "../../stzBase.ring"
load "../_narrated.ring"

# SpacifyXT multi-PHASE: the last :LastNChars form a tail zone, the
# rest a head zone; each is grouped with the first separator using its
# own step + direction, and the two are joined by the :AndThen
# separator. Archive block #280.

Scenario("Head backward-3, tail forward-2, joined by a dot")
	o1 = new stzString("9999999999999999")
	o1.SpacifyXT(
		:Separator = [ " ", :AndThen = "." , :LastNChars = 7 ],
		:Step      = [ 3, :AndThen = 2 ],
		:Direction = [ :Backward, :AndThen = :Forward ]
	)
	Then("two zones", o1.Content(), "999 999 999.99 99 99 9")
EndScenario()

Summary()
