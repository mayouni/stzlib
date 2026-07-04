load "../../stzBase.ring"
load "../_narrated.ring"

# Undo and Redo walk the mutation journal; InsertXT places text by
# anchor. Archive block #913.

Scenario("Editing with second thoughts")
	o1 = Q("Softanza is awosme!")
	o1.Replace("awosme", :with = "wonderful")
	Then("replaced", o1.Content(), "Softanza is wonderful!")
	o1.Undo()
	Then("undone", o1.Content(), "Softanza is awosme!")
	o1.Redo()
	Then("redone", o1.Content(), "Softanza is wonderful!")
	o1.InsertXT("really ", :Before = "wonderful")
	Then("emphasized", o1.Content(), "Softanza is really wonderful!")
	o1.Undo()
	Then("emphasis withdrawn", o1.Content(), "Softanza is wonderful!")
EndScenario()

Summary()
