load "../../stzBase.ring"
load "../_narrated.ring"

# StzRaise raises with the given message. Archive block #593.

Scenario("A simple raise")
	bRaised = FALSE
	cMsg = ""
	try
		StzRaise("Simple error message!")
	catch
		bRaised = TRUE
		cMsg = cCatchError
	done
	Then("it raises", bRaised, TRUE)
	Then("with the message", Q(cMsg).Contains("Simple error message!"), TRUE)
EndScenario()

Summary()
