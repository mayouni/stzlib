load "../../stzBase.ring"
load "../_narrated.ring"

# The KeepingTime flag and its setter. Archive block #490.

Scenario("Toggling time-keeping")
	Then("off by default", KeepingTime(), FALSE)
	SetKeepingTimeTo(TRUE)
	Then("on after the setter", KeepingTime(), TRUE)
	SetKeepingTimeTo(FALSE)
EndScenario()

Summary()
