load "../../stzBase.ring"
load "../_narrated.ring"

# InsertXT(str, :EachNChars = n) inserts str after every n chars, counting
# from the START, with no trailing insert after the final (possibly partial)
# group. (The archive leaves an explicit :Forward-option form as #TODO.)
# Archive block #308.

Scenario("Inserting a separator each 3 chars")
	Given('"99999999999" (11 nines)')
	o1 = new stzString("99999999999")
	o1.InsertXT("_", :EachNChars = 3)
	Then("groups of three from the start", o1.Content(), "999_999_999_99")
EndScenario()

Summary()
