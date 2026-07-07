load "../../stzBase.ring"
load "../_narrated.ring"

# THE SOFTANZA Q-LADDER (global wrapping functions).
#   Q(p)   -> the BASIC object by type (list -> stzList, number -> stzNumber, ...)
#   QQ(p)  -> the FIRST LOGICAL secondary type (list of strings -> stzListOfStrings)
#   QQQ(p) -> the MOST SPECIFIC type the content maps to (list of chars ->
#             stzListOfChars). QQQ is content-driven, not a fixed rung.
#   QRT(p, :type) / Q(p).ToStzXxx() -> explicit (preferred for solid code).

Scenario("Q -> basic object")
	Then("a list wraps to the basic stzList",
		classname(Q([1, 2, 3])), "stzlist")
	Then("a number wraps to stzNumber",
		classname(Q(42)), "stznumber")
EndScenario()

Scenario("QQ -> first logical secondary type")
	Then("a list of numbers -> stzListOfNumbers",
		classname(QQ([1, 2, 3])), "stzlistofnumbers")
	Then("a list of strings -> stzListOfStrings",
		classname(QQ(["one", "two"])), "stzlistofstrings")
	Then("a list of pairs -> stzListOfPairs",
		classname(QQ([1:2, 3:4])), "stzlistofpairs")
	# A char is a single-char STRING, so QQ stops at stzListOfStrings -- the more
	# specific stzListOfChars is QQQ's job, NOT QQ's.
	Then("a list of chars -> stzListOfStrings (NOT stzListOfChars)",
		classname(QQ(["a", "b", "c"])), "stzlistofstrings")
	Then("QQ still computes: a numbers list sums",
		QQ([3, 6, 9]).Sum(), 18)
EndScenario()

Scenario("QQQ -> the most specific type the content maps to")
	Then("a list of chars -> stzListOfChars (most specific)",
		classname(QQQ(["a", "b", "c"])), "stzlistofchars")
	Then("a list of multi-char strings stays stzListOfStrings",
		classname(QQQ(["one", "two"])), "stzlistofstrings")
	Then("a list of numbers stays stzListOfNumbers",
		classname(QQQ([1, 2, 3])), "stzlistofnumbers")
EndScenario()

Scenario("QQ on a string -> most-specific STRING-family type (no coercion)")
	# A string elevates to a string-family type; a single char is one.
	Then("Q of a string is the basic stzString",
		classname(Q("3")), "stzstring")
	Then("QQ of a single char '3' is stzChar, NOT stzNumber (that would be coercion)",
		classname(QQ("3")), "stzchar")
	Then("QQ of a single letter is stzChar too",
		classname(QQ("a")), "stzchar")
	# NOTE: multi-char number/list strings still coerce (stzNumber / stzList) until
	# stzNumberInString / stzListInString classes exist -- deliberately unchanged.
	Then("QQ of a multi-char number string still coerces to stzNumber (for now)",
		classname(QQ("19")), "stznumber")
EndScenario()

Scenario("QRT -> explicit type (the solid-code choice when ambiguous)")
	Then("QRT builds the exact requested type",
		classname(QRT(["a", "b", "c"], :stzListOfChars)), "stzlistofchars")
	Then("and its ops are available",
		QRT([3, 6, 9], :stzListOfNumbers).Max(), 9)
EndScenario()

Summary()
