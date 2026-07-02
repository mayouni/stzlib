load "../../stzBase.ring"
load "../_narrated.ring"

# Three spellings of the same narrative chain ending: SpacifyItR()
# returns the result string directly; the Q form closes with AsWell()
# or with the @0(:AsWell) decorator. Archive block #500.

Scenario("Three endings, one result")
	Then("the R form returns the string",
		Q("__Ri__ng__").
			@("__").@RemoveItQ().AndThenQ().UppercaseQ().TheStringQ().AndQ().SpacifyItR(),
		"R I N G")
	Then("the AsWell ending",
		Q("__Ri__ng__").
			@("__").@RemoveItQ().AndThenQ().UppercaseQ().TheStringQ().AndQ().SpacifyItQ().AsWell(),
		"R I N G")
	Then("the @0 decorator ending",
		Q("__Ri__ng__").
			@("__").@RemoveItQ().AndThenQ().UppercaseQ().TheStringQ().AndQ().SpacifyItQ().@0(:AsWell),
		"R I N G")
EndScenario()

Summary()
