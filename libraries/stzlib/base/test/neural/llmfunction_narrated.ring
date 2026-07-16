# R4 step 6 ACCEPTANCE -- stzLLMFunction: the LLM call as a PURE
# TYPED FUNCTION (5.7 G3 seed). Model-OPTIONAL: the contract scenes
# run everywhere; the live scene runs when a GGUF is loaded.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: the contract -- budget, types, refusal --"
oF = new stzLLMFunction("mood")
oF.SetPrompt("One word only, positive or negative: {input}")
oF.ReturnsOneOf([ "positive", "negative" ])

b1 = 0
try
	oF.Call_("hello")
catch
	b1 = 1
done
chk("Budget(n) is MANDATORY before any call (G9)", b1 = 1)
oF.Budget(4)

? ""
? "-- Scene 2: determinism by memoization --"
oF.SeedAnswer("What a lovely day!", "positive")
chk("a seeded/memoized call answers typed", oF.Call_("What a lovely day!") = "positive")
chk("...for FREE (zero calls spent)", oF.CallsMade() = 0)
chk("...and says so", len(StzFind("memoized", oF.Why())) > 0)

? ""
? "-- Scene 3: no model + no memo = HONEST REFUSAL --"
if StzHasGenerativeModel() = 0
	b2 = 0
	try
		oF.Call_("This is terrible.")
	catch
		b2 = 1
	done
	chk("refuses rather than guessing (LAW 3)", b2 = 1)
else
	cLive = oF.Call_("This is terrible and sad.")
	chk("live call validates against the type",
		cLive = "negative" or cLive = "positive")
ok

? ""
? "-- Scene 4: golden sets (regression pinning) --"
oF.AddGolden("What a lovely day!", "positive")
aG = oF.RunGoldens()
chk("goldens run and report structured", aG[:passed] = 1 and aG[:total] = 1)

? ""
? "-- Scene 5: typed outputs are VALUES, not strings --"
oN = new stzLLMFunction("add")
oN.SetPrompt("Compute: {input}")
oN.ReturnsNumber()
oN.Budget(2)
oN.SeedAnswer("2+3", 5)
chk("a Number-typed answer computes", oN.Call_("2+3") + 1 = 6)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
