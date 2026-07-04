load "../../stzBase.ring"
load "../_narrated.ring"

# PartsAndPartitionersUsingXT zips each part with the value that
# partitioned it. Archive block #735.

Scenario("Char types of a plate number")
	o1 = new stzString("AM23-X ")
	Then("five typed parts",
		ListEq( o1.PartsAndPartitionersUsingXT('StzCharQ(@char).CharType()'),
		[
			[ "AM", :Letter_Uppercase ],
			[ "23", :Number_DecimalDigit ],
			[ "-", :Punctuation_Dash ],
			[ "X", :Letter_Uppercase ],
			[ " ", :Separator_Space ]
		] ), TRUE)
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
