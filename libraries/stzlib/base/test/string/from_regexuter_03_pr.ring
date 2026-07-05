load "../../stzBase.ring"
load "../_narrated.ring"

# The numbers INSIDE a string can be transformed in place: MultiplyByN
# et al apply one factor to every number; the XT twins take one factor
# per number. Extracted from stzregexutertest.ring, block #3.

Scenario("Calculating on the numbers in a string")
	o1 = new stzString("The total is 42 dollars and 13 cents.")
	o1.MultiplyByN(2)
	Then("both doubled", o1.Content(), "The total is 84 dollars and 26 cents.")
	o1.DivideByN(2)
	Then("both halved back", o1.Content(), "The total is 42 dollars and 13 cents.")
	o1.AddN(8)
	Then("both plus eight", o1.Content(), "The total is 50 dollars and 21 cents.")
	o1.RetrieveN(12)
	Then("both minus twelve", o1.Content(), "The total is 38 dollars and 9 cents.")
EndScenario()

Scenario("A different sum for each number")
	o2 = new stzString("The total is 42 dollars and 13 cents.")
	o2.MultiplyByNXT([2, 3])
	Then("42 by 2, 13 by 3", o2.Content(), "The total is 84 dollars and 39 cents.")
	o2.DivideByNXT([ 2, 3 ])
	Then("divided back", o2.Content(), "The total is 42 dollars and 13 cents.")
	o2.AddNXT([ 8, 7 ])
	Then("42 plus 8, 13 plus 7", o2.Content(), "The total is 50 dollars and 20 cents.")
	o2.RetrieveNXT([40, 10])
	Then("50 minus 40, 20 minus 10", o2.Content(), "The total is 10 dollars and 10 cents.")
EndScenario()

Summary()
