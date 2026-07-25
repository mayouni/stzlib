load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 2, second half: THE REGIME CARRIED BY THE VALUE.
#
# Scope-Oriented Programming puts the governing frame at the call site. For the tie
# rule that meant the VERB -- RoundedToHalfEven(2). For the quantity itself it means
# the CONSTRUCTOR, because a number's regime is unlike the other two instances:
# a regex scope belongs to one match, a system scope to one object, but a price is
# a price through an entire calculation. So you say it once, where the value enters
# the program, and it travels.
#
#     StzMoneyQ("19.99")        2 places, banker's rounding, always
#     StzExactQ("1/3")          refuses to become approximate -- raises instead
#     StzMeasuredQ("2.5", 3)    3 places, banker's -- approximate by nature
#     StzNumberQ(2.5)           unchanged: the machine regime, today's behaviour

Scenario("a price stays a price")
	oPrice = StzMoneyQ("19.99")
	Then("it knows what it is", oPrice.Regime(), :money)
	Then("...and IsMoney says so", oPrice.IsMoney(), TRUE)
	Then("...with two places", oPrice.RegimePlaces(), 2)

	oPrice.MultiplyBy("0.15")
	Then("a rate applied to it lands on money, not 2.9985", oPrice.Content(), "3.00")
	Then("...and it is STILL money afterwards", oPrice.IsMoney(), TRUE)
	# the regime is applied in Update() -- the single point a value changes -- so it
	# survives arithmetic, rounding, and anything else that writes.

	When("a tie appears, as it does constantly in money")
	oTotal = StzMoneyQ("10")
	oTotal.Add("0.005")
	Then("it rounds by banker's, not away from zero", oTotal.Content(), "10.00")
	# half-up would give 10.01. Across a ledger that difference compounds in one
	# direction, which is the whole reason accounting rounds to even.
EndScenario()

Scenario("an exact quantity refuses to become approximate")
	oThird = StzExactQ("1/3")
	Then("it knows what it is", oThird.Regime(), :exact)
	Then("...and holds the fraction", oThird.Content(), "1/3")

	oThird.Add("2/3")
	Then("exact arithmetic proceeds normally", oThird.Content(), "1")

	When("an operation cannot be exact")
	bRaised = FALSE
	cWhy = ""
	try
		oBad = StzExactQ("1")
		oBad.Divide(3)
	catch
		bRaised = TRUE
		cWhy = cCatchError
	done
	Then("it RAISES rather than quietly handing back 0.333333", bRaised, TRUE)
	Then("...saying the regime is why", StzFindFirst("EXACT by regime", cWhy) > 0, TRUE)
	Then("...and what to use instead", StzFindFirst("fraction (p/q)", cWhy) > 0, TRUE)
	# silently approximating is the one thing this regime exists to prevent, so it
	# is the one thing it will not do.
EndScenario()

Scenario("a measurement carries its precision")
	oM = StzMeasuredQ("2.5", 3)
	Then("it pads to the places it claims", oM.Content(), "2.500")
	Then("...and knows how many", oM.RegimePlaces(), 3)
	Then("...and what it is", oM.IsMeasured(), TRUE)

	oM.MultiplyBy("2")
	Then("arithmetic keeps the precision", oM.Content(), "5.000")
	# a measurement is approximate BY NATURE -- the places are a claim about the
	# instrument, not about the arithmetic, so they neither grow nor shrink.
EndScenario()

Scenario("the plain number is exactly what it was")
	oPlain = new stzNumber("19.99")
	Then("its regime is machine", oPlain.Regime(), :machine)
	oPlain.MultiplyBy("0.15")
	Then("...so it keeps every place the exact arithmetic produced", oPlain.Content(), "2.9985")
	Then("...and is not money", oPlain.IsMoney(), FALSE)
	# :machine returns the value untouched, which is why introducing regimes moved
	# nothing: across all 89 number tests only the two random-number files differ.
EndScenario()

Scenario("infinities and NaN are refused, not carried")
	# Ring answers isNumber(inf) with TRUE and inf > 0 with TRUE, so an overflow
	# travels silently. stzNumber used to store the literal text "inf" -- and then
	# report Representation() = :decimal, a lie every later operation inherits.
	nBig = number("1e308") * 10
	bInf = FALSE
	cWhy = ""
	try
		oInf = new stzNumber(nBig)
	catch
		bInf = TRUE
		cWhy = cCatchError
	done
	Then("an infinity is refused", bInf, TRUE)
	Then("...and named for what it is", StzFindFirst("not a finite number", cWhy) > 0, TRUE)
	Then("...pointing at where the fault actually is",
	     StzFindFirst("earlier calculation", cWhy) > 0, TRUE)

	bNan = FALSE
	try
		oNan = new stzNumber(nBig - nBig)
	catch
		bNan = TRUE
	done
	Then("a NaN is refused too", bNan, TRUE)

	Given("ordinary values, which must be untouched by all this")
	Then("zero still builds", (new stzNumber(0)).Content(), "0")
	Then("...and a negative", (new stzNumber(-1)).Content(), "-1")
	Then("...and a decimal", (new stzNumber(0.5)).Content(), "0.50")
	Then("...and a large integer", (new stzNumber(12590)).Content(), "12590")
EndScenario()

Summary()
