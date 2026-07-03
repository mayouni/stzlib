load "../../stzBase.ring"
load "../_narrated.ring"

# IsMultipleOf: the string is n whole copies of the unit; the CS dial
# takes the named :CS spelling too. Archive block #604.

Scenario("Arabic three times")
	Then("a multiple", Q("ArabicArabicArabic").IsMultipleOf("Arabic"), TRUE)
	Then("exactly 3 times", Q("ArabicArabicArabic").IsNTimesMultipleOf(3, "Arabic"), TRUE)
	Then("not 5 times", Q("ArabicArabicArabic").IsNTimesMultipleOf(5, "Arabic"), FALSE)
	Then("case-sensitively, no", Q("ArabicArabicArabic").IsMultipleOfCS("arabic", TRUE), FALSE)
	Then("case aside, yes", Q("ArabicArabicArabic").IsMultipleOfCS("arabic", :CS = FALSE), TRUE)
EndScenario()

Summary()
