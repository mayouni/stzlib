load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 1 (slice 2) of the numeric foundation: a number must not be DESTROYED on
# its way in, and the representation it lands on must be visible.
#
# Slice 1 made the arithmetic exact. This closes the hole one step earlier -- at
# construction -- and makes the ladder observable.
#
# THE DEFECT, and it is data loss rather than a display quirk. stzNumber stores its
# value as a STRING, and the constructor built that string with `"" + n`, which
# renders through Ring's PROCESS-GLOBAL decimals() setting. With the default of 2:
#
#     new stzNumber( number("1e-20") ).Content()   -->  "0.00"
#
# and because the string IS the value here, NumericValue() then answered 0. The
# number was not mis-shown, it was gone.

Scenario("a very small number survives being constructed")
	tiny = number("1e-20")
	oTiny = new stzNumber(tiny)

	Then("the digits are kept", oTiny.Content(), "0.00000000000000000001")
	Then("...so the value is still positive", oTiny.NumericValue() > 0, TRUE)
	Then("...and scaling it back recovers 1", oTiny.NumericValue() * number("1e20"), 1)
	# every one of those failed before: content "0.00", value 0, product 0.

	When("arithmetic is done on it")
	oTiny.MultiplyBy(2)
	Then("it is exact, because the content is a plain decimal the exact path can use",
	     oTiny.Content(), "0.00000000000000000002")
	Then("...and says so", oTiny.IsExact(), TRUE)
EndScenario()

Scenario("...and NOTHING else changed, which is the point")
	# This is a LOSS fix, not a reformatting. The ordinary rendering is kept whenever
	# it round-trips, so a number that used to read "0.10" still reads "0.10".
	# Replacing every rendering with the shortest form would have been easier to
	# write and would have churned output across the whole library for no gain.
	Then("a tenth still renders as it did", (new stzNumber(0.1)).Content(), "0.10")
	Then("...and two and a half", (new stzNumber(2.5)).Content(), "2.50")
	Then("...and a quarter", (new stzNumber(0.25)).Content(), "0.25")
	Then("an integer is untouched", (new stzNumber(100)).Content(), "100")
	Then("...and a longer one", (new stzNumber(12590)).Content(), "12590")
	Then("a string input is taken verbatim, as always", (new stzNumber("0.1")).Content(), "0.1")
EndScenario()

Scenario("the shortest PLAIN decimal, from the engine")
	# The replacement comes from stz_number_plain_shortest, which raises precision
	# until the text reads back as the same double -- so the first form that works is
	# the shortest one that loses nothing.
	Then("a tenth needs one place", StzEngineNumberPlainShortest(0.1), "0.1")
	Then("a quarter needs two", StzEngineNumberPlainShortest(0.25), "0.25")
	Then("a third needs sixteen", StzEngineNumberPlainShortest(1.0/3.0), "0.3333333333333333")
	Then("a whole number needs none", StzEngineNumberPlainShortest(100), "100")

	Then("every result round-trips", (0 + StzEngineNumberPlainShortest(1.0/3.0)) = (1.0/3.0), TRUE)
	Then("...including the very small", (0 + StzEngineNumberPlainShortest(number("1e-20"))) = number("1e-20"), TRUE)
	Then("...and the very large", (0 + StzEngineNumberPlainShortest(number("1e20"))) = number("1e20"), TRUE)

	Then("it is PLAIN, never scientific -- no exponent anywhere",
	     StzFindFirst("e", StzEngineNumberPlainShortest(number("1e-20"))), 0)
	Then("...for large values either", StzFindFirst("e", StzEngineNumberPlainShortest(number("1e20"))), 0)
	# scientific notation would defeat IntegerPart, NumberOfDigits and the
	# scaled-integer arithmetic, all of which expect digits and at most one dot.
	Then("a large value spells its digits out",
	     StzEngineNumberPlainShortest(number("1e20")), "100000000000000000000")
EndScenario()

Scenario("the representation ladder, observable rather than folklore")
	Then("a small whole number", (new stzNumber("42")).Representation(), :integer)
	Then("...negative too", (new stzNumber("-7")).Representation(), :integer)
	Then("a whole number past what an f64 holds exactly",
	     (new stzNumber("9007199254740992")).Representation(), :bigInteger)
	Then("...and far past it",
	     (new stzNumber("99999999999999999999999999999999")).Representation(), :bigInteger)
	Then("a value with a fractional part", (new stzNumber("19.99")).Representation(), :decimal)

	Then("the predicates read the same", (new stzNumber("99999999999999999999")).IsBigInteger(), TRUE)
	Then("...and say no when they should", (new stzNumber("42")).IsBigInteger(), FALSE)
	Then("...for decimals", (new stzNumber("0.5")).IsDecimalNumber(), TRUE)

	When("an operation carries a number past the f64-exact range")
	oGrow = new stzNumber("9007199254740992")
	oGrow.Add(1)
	Then("it is still exact", oGrow.Content(), "9007199254740993")
	Then("...and reports the bigger rung", oGrow.Representation(), :bigInteger)
	# promotion is automatic and upward only; nothing silently demotes.

	# :rational and :complex are named in the plan and NOT built yet, so they are
	# never reported. A ladder that claims rungs it does not have is worse than a
	# short one -- that is the next slice.
EndScenario()

Summary()
