load "../../stzBase.ring"
load "../_narrated.ring"

# Digits() is the 0..9 list; the digit predicates differ by wrapper: Q(n).IsADigit
# tests a number, Q(s).IsADigitInString tests a string (single digit only), and
# QQ(s).IsADigit tests a stzChar. Archive block #95.

Scenario("The digit list and the digit predicates")
	Then("Digits() is 0..9", ListEq( Digits(), [ 0,1,2,3,4,5,6,7,8,9 ] ), TRUE)
	Then("Q(5).IsADigit (number) is TRUE", Q(5).IsADigit(), TRUE)
	Then("Q('3').IsADigitInString is TRUE", Q("3").IsADigitInString(), TRUE)
	Then("an empty string is not a digit", Q("").IsADigitInString(), FALSE)
	Then("'125' is not a single digit", Q("125").IsADigitInString(), FALSE)
	Then("QQ('3').IsADigit (stzChar) is TRUE", QQ("3").IsADigit(), TRUE)
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
