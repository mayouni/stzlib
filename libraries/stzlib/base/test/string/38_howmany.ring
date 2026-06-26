load "../../stzBase.ring"
load "../_narrated.ring"

# HowMany(list) -- a readable count over a domain list. The Arabic alphabet has
# 28 base letters; the eXTended list (with hamza/lam-alef variants) has 34.
# Archive block #38. (The 10PercentOf(...) sample on the original middle line is
# non-deterministic -- archive marked it #o--> "one possible output" -- so only
# the deterministic counts are asserted here.)

Scenario("Counting the letters of the Arabic alphabet")
	Then("the base Arabic alphabet has 28 letters", HowMany( ArabicLetters() ), 28)
	Then("the extended Arabic letter list has 34", HowMany( ArabicLettersXT() ), 34)
EndScenario()

Summary()
