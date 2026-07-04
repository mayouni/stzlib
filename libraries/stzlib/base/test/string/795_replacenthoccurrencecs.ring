load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceNthOccurrenceCS with the dial off, then finding in Arabic.
# Archive block #795.

Scenario("The second TEXT, and three Arabic nusus")
	o1 = new stzString("This text is my text not your text, right?!")
	Then("2nd text becomes narration, case-blind",
		o1.ReplaceNthOccurrenceCSQ(2, "TEXT", :With = "narration",
			:Casesensitive = FALSE).Content(),
		"This text is my narration not your text, right?!")
	o2 = new stzString("هذا نصّ لا يشبه أيّ نصّ ويا له من نصّ يا صديقي")
	Then("all three",
		ListEq( o2.FindAll("نصّ"), [ 5, 21, 35 ] ), TRUE)
	Then("the first", o2.FindFirst("نصّ"), 5)
	Then("the last", o2.FindLast("نصّ"), 35)
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
