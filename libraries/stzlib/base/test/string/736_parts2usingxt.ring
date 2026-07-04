load "../../stzBase.ring"
load "../_narrated.ring"

# Parts2UsingXT is an alias of PartsAndPartitionersUsingXT -- and the
# { } block form may carry comments and newlines. Archive block #736.

Scenario("Char types of a mixed string")
	o1 = new stzString("Abc285XY&من")
	Then("six typed parts",
		ListEq( o1.Parts2UsingXT('{	# Or PartsAndPartitionersUsingXT()
			StzCharQ(@char).CharType()
		}'),
		[
			[ "A", :Letter_Uppercase ],
			[ "bc", :Letter_Lowercase ],
			[ "285", :Number_DecimalDigit ],
			[ "XY", :Letter_Uppercase ],
			[ "&", :Punctuation_Other ],
			[ "من", :Letter_Other ]
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
