load "../../stzBase.ring"
load "../_narrated.ring"

# Lines() keeps the empties (a whitespace-only line counts as empty for
# NumberOfEmptyLines / RemoveEmptyLines). Archive block #511.

Scenario("Lines and empty lines")
	o1 = new stzString("
lfldfkdlfk
mlsdlk

llkslkflk
   
medmf")
	Then("the raw lines, empties included",
		ListEq( o1.Lines(),
			[ "", "lfldfkdlfk", "mlsdlk", "", "llkslkflk", "   ", "medmf" ] ), TRUE)
	Then("three of them are empty", o1.NumberOfEmptyLines(), 3)
	o1.RemoveEmptyLines()
	Then("removing them keeps the content lines",
		ListEq( Q(o1.Content()).Lines(),
			[ "lfldfkdlfk", "mlsdlk", "llkslkflk", "medmf" ] ), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
	if len(aA) != len(aE) return FALSE ok
	nLen = len(aA)
	for i = 1 to nLen
		if isList(aA[i]) and isList(aE[i])
			if NOT ListEq(aA[i], aE[i]) return FALSE ok
		else
			if aA[i] != aE[i] return FALSE ok
		ok
	next
	return TRUE
