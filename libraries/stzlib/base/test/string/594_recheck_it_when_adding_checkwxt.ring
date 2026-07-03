load "../../stzBase.ring"
load "../_narrated.ring"

# The structured StzRaise hash form ([:Where, :What, :Why, :Todo])
# formats each part into the message. Archive block #594.

Scenario("A structured raise")
	bRaised = FALSE
	cMsg = ""
	try
		StzRaise([
			:Where	= "stzString.ring",
			:What 	= "Describes what happend",
			:Why  	= "Describes why it happened",
			:Todo 	= "Posposes an action to solve the error"
		])
	catch
		bRaised = TRUE
		cMsg = cCatchError
	done
	Then("it raises", bRaised, TRUE)
	Then("the What is in the message", Q(cMsg).Contains("Describes what happend"), TRUE)
	Then("the Why is in the message", Q(cMsg).Contains("Describes why it happened"), TRUE)
	Then("the Todo is in the message", Q(cMsg).Contains("Posposes an action"), TRUE)
EndScenario()

Summary()
