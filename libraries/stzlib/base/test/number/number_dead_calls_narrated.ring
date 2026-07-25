load "../../stzBase.ring"
load "../_narrated.ring"

# stzNumber had 15 method calls that resolved to NOTHING -- no method on the class,
# none inherited, no global func -- so each raised R14 "Calling Method without
# definition" the moment its code path was reached. They were found by an audit,
# not by a user: extract every This.X( from the class, extract every def X from the
# class plus its ancestors plus every global func, and diff the two sets.
#
# A broken alias raises only when someone finally calls it, which is why a class
# with a long alias tail can carry them for years. This suite calls every one of
# them, so they cannot go quiet again.
#
# THE PATTERN WORTH KNOWING: most were not random typos. The CANONICAL method was
# misspelled and its aliases called the CORRECT spelling -- so the alias was
# right and the definition was wrong. IsStriclyLess (missing a "t") had six
# aliases, all calling IsStrictlyLess, all raising.

Scenario("the canonical name was misspelled; its aliases were right all along")
	oN = new stzNumber(5)

	Then("the correctly-spelled name now exists", oN.IsStrictlyLess(9), TRUE)
	Then("...and answers correctly the other way", oN.IsStrictlyLess(2), FALSE)
	Then("all six of its alternative forms work", oN.IsStrictlyLessThan(9), TRUE)
	Then("...including this one", oN.IsStrictlySmallerOrEqualTo(9), TRUE)
	Then("...and this one", oN.IsStrictlyEqualOrLessThan(9), TRUE)
	Then("...and the deliberately misspelled one", oN.IsStrictlySmallerThqn(9), TRUE)
	Then("the historical misspelling still works, so old callers are safe",
	     oN.IsStriclyLess(9), TRUE)
	# NOTE, and not fixed here: four of those aliases are named "...OrEqualTo" but
	# delegate to a STRICT comparison. "Strictly less OR equal to" is a
	# contradiction in terms, so there is no correct behaviour to restore -- only a
	# naming decision to make. Left alone deliberately rather than inventing one.
EndScenario()

Scenario("IntegerPart's fluent form: two typos in three lines")
	oN = new stzNumber("42.75")

	Then("the integer part reads", oN.IntegerPart(), "42")
	Then("the correctly-named fluent form now exists", oN.IntegerPartQ().Content(), "42")
	Then("...and the historical misspelling still works", oN.IntegrPartQ().Content(), "42")
	Then("the sibling forms that called it work too",
	     oN.IntegerPartStringValueQ().Content(), "42")
	Then("...including the misspelled family", oN.IntergerPartQ().Content(), "42")
	# it was named IntegrPartQ (missing an "e") AND its body called This.InterPart()
	# (missing "eger"), so six sibling forms pointed at something unreachable.
EndScenario()

Scenario("round comparison: called Is-Round..., defined Round-Is...")
	# All three branches of this one switch called IsRound..., where the methods are
	# named RoundIs... -- so EVERY path through it raised R14. It runs now.
	#
	# WHAT IS ASSERTED HERE IS ONLY THAT, deliberately. The comparison underneath is
	# separately wrong -- RoundIsSameAsRoundOf compares This.Round() (a count of
	# DECIMALS) against the other number's NumberOfDigits() (a count of ALL digits),
	# so "1.25" and "1.5" come out :equal while "1.25" and "9.99" come out :less.
	# Pinning those answers as though they were correct would bless a bug this task
	# did not set out to fix, so the assertions check the CONTRACT (a verdict comes
	# back, and it is one of the three) rather than the arithmetic.
	cV1 = (new stzNumber("1.25")).CompareRoundsWith("1.5")
	cV2 = (new stzNumber("1.5")).CompareRoundsWith("1.25")
	cV3 = (new stzNumber("1.25")).CompareRoundsWith("9.99")

	Then("it returns a verdict instead of raising",
	     StzFindFirst(cV1, [ :Equal, :Greater, :Less ]) > 0, TRUE)
	Then("...for the reversed pair too", StzFindFirst(cV2, [ :Equal, :Greater, :Less ]) > 0, TRUE)
	Then("...and a third pair", StzFindFirst(cV3, [ :Equal, :Greater, :Less ]) > 0, TRUE)
	Then("the three round predicates it calls are reachable",
	     (new stzNumber("1.25")).RoundIsSameAsRoundOf("1.5"), 1)
EndScenario()

Scenario("gcd and lcm: a short name that had become a SECOND implementation")
	Then("gcd works", (new stzNumber(12)).GCD(18), 6)
	Then("...and its full name agrees", (new stzNumber(12)).GreatestCommonDividor(18), 6)
	Then("the Q form works, which it never could", (new stzNumber(12)).GreatestCommonDividorQ(18).Content(), "6")
	# GreatestCommonDividorQ called This.GreatCommonDividor() -- missing "est" AND
	# dropping the argument.

	Then("lcm of two numbers works", (new stzNumber(4)).LCM(6), 12)
	Then("lcm of a LIST works", (new stzNumber(4)).LCM([6, 8]), 24)
	Then("...and of numbers written as strings", (new stzNumber(4)).LCM(["6", "8"]), 24)
	Then("...which is what stzListOfNumbers depends on",
	     (new stzListOfNumbers([4, 6, 8])).LeastCommonMultiple(), 24)
	# THE WORST ONE, because it was not an R14 but a WRONG NUMBER: LCM was a second,
	# simpler implementation that went straight to the engine and handled neither a
	# list nor a `:With` named param -- and stzListOfNumbers.LeastCommonMultiple()
	# calls exactly that name with a list. It silently answered 0 instead of 24.
	# A short name must be an ALIAS of the full one, never a divergent twin.
EndScenario()

Scenario("the operator hook: >=, <=, ++ and -- all pointed at nothing")
	Then("next number", (new stzNumber(41)).NextNumber(), "42")
	Then("previous number", (new stzNumber(41)).PreviousNumber(), "40")
	Then("...and they do not mutate the number", (new stzNumber(41)).NextNumberQ().Content(), "42")
	oKeep = new stzNumber(41)
	oKeep.NextNumber()
	Then("...proven", oKeep.Content(), "41")
	# NextNumber/PreviousNumber return rather than mutate because the operator()
	# hook returns the result of "++" / "--". Increment()/Decrement() are the
	# mutating pair, and their Q forms now return This so they can chain.
	Then("IncrementQ chains, which it did not before",
	     (new stzNumber(7)).IncrementQ().Content(), "8")
	Then("...and DecrementQ", (new stzNumber(7)).DecrementQ().Content(), "6")
EndScenario()

Scenario("octal: the fractional half of the conversion did not exist")
	Then("an integer converts", (new stzNumber(10)).IntegerPartToOctalForm(), "12")
	Then("a REAL number converts, which raised before",
	     (new stzNumber("10.5")).ToOctalFormWithoutPrefix(), "12.4")
	Then("the fractional part alone", (new stzNumber("10.5")).FractionalPartToOctalForm(), "4")
	Then("an integer has no fractional octal part", (new stzNumber(10)).FractionalPartToOctalForm(), "")
	# ToOctalFormWithoutPrefix has always called FractionalPartToOctalForm for a real
	# number, and it did not exist. Unlike the integer side the conversion can run
	# forever (1/3 is 0.2525... in octal), so it is bounded by the number's own round.
EndScenario()

Scenario("the billions family: seven aliases, all missing a leading C")
	oBig = new stzNumber(2500000000)
	Then("the canonical predicate works", oBig.ContainsSeveralBillions(), TRUE)
	Then("...and the aliases that called ontainsSeveralBillions()", oBig.ContainsManyBillions(), TRUE)
	Then("...this one too", oBig.ContainsThousandsOfMillions(), TRUE)
	Then("a small number says no", (new stzNumber(5)).ContainsManyBillions(), FALSE)
	# seven call sites had lost the "C" off the front -- the signature of a bad
	# search-and-replace rather than seven independent mistakes.
EndScenario()

Scenario("removing zeros: dead calls AND wrong logic")
	oLead = new stzNumber("007")
	oLead.RemoveZerosFromLeft()
	Then("leading zeros go", oLead.Content(), "7")

	oTrail = new stzNumber("1.500")
	oTrail.RemoveZerosFromRight()
	Then("trailing zeros of a REAL number go", oTrail.Content(), "1.5")

	oInt = new stzNumber("100")
	oInt.RemoveZerosFromRight()
	Then("...but an INTEGER keeps its zeros", oInt.Content(), "100")
	# this is the one that matters: those zeros are significant, and turning 100 into
	# 1 would be a catastrophe rather than a tidy-up. The IsReal() guard is load-bearing.

	oBoth = new stzNumber("007.500")
	oBoth.RemoveZeros()
	Then("both ends together", oBoth.Content(), "7.5")

	# All three methods called four stzString methods that do not exist. The LOGIC was
	# wrong too: RemoveZerosFromLeft also stripped TRAILING zeros, and RemoveZeros
	# stripped trailing twice while never touching the leading ones.
EndScenario()

Scenario("the two tests that could not run before")
	# 62_isdividableby raised on Q(n).IsDecimalNumberInString() -- a predicate that
	# exists nowhere. "Decimal" there means base-10 (as against the hex and octal
	# classes), so the right predicate is IsNumberInString, which accepts "2".
	oN = new stzNumber(14)
	Then("a number divides", oN.IsDividableBy(2), TRUE)
	Then("...a number in a string too", oN.IsDividableBy("2"), TRUE)
	Then("...and one written with decimals", oN.IsDividableBy("2.00"), TRUE)
	Then("...while a non-divisor says no", oN.IsDividableBy("2.001"), FALSE)

	# 70_review_implementation reached RemoveZeros through Structure(). It runs now --
	# and revealed a formatting bug the R14 had been masking: the closing ")" of
	# :PutNegativeBetweenParentheses was emitted whenever the OPTION was set, while
	# the opening "(" is correctly guarded by the number being negative.
	cPos = (new stzNumber(1200)).ApplyFormatXT([
		:PutNegativeBetweenParentheses = TRUE, :ShowSign = TRUE ])
	Then("a POSITIVE number gets no stray closing parenthesis",
	     StzFindFirst(")", cPos), 0)
	cNeg = (new stzNumber(-1200)).ApplyFormatXT([
		:PutNegativeBetweenParentheses = TRUE ])
	Then("...while a negative one is bracketed on both sides",
	     StzFindFirst("(", cNeg) > 0 and StzFindFirst(")", cNeg) > 0, TRUE)

	# STILL BROKEN, DELIBERATELY NOT TOUCHED HERE: the Trillions/Millions/Thousands/
	# Hundreds decomposition slices FIXED WIDTHS FROM THE LEFT instead of grouping in
	# threes from the right, so 1234567 comes apart as 123 / 45 / 67 rather than
	# 1 / 234 / 567, and a thousands separator lands in the wrong places. That is six
	# methods and a decision about what each should return, with no recorded expected
	# output to check against -- its own task, not a hurried edit at the end of this one.
EndScenario()

Summary()
