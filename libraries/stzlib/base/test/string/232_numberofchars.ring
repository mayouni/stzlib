load "../../stzBase.ring"
load "../_narrated.ring"

# NumberOfChars / NumberOfLines / SplitQ(NL).NumberOfItems. Archive block #232
# ran these on the ~1.9M-char UnicodeData() as a perf demo; UnicodeData() is empty
# in this checkout, so the methods are verified here on a small known string
# instead (the large-text perf guard lives in 07_managing_a_big_text).

Scenario("Counting chars and lines")
	Given('"abc<NL>de<NL>f" (8 chars, 3 lines)')
	o1 = new stzString("abc" + nl + "de" + nl + "f")
	Then("NumberOfChars counts every char incl. newlines", o1.NumberOfChars(), 8)
	Then("NumberOfLines is 3", o1.NumberOfLines(), 3)
	Then("SplitQ(NL).NumberOfItems agrees", o1.SplitQ(nl).NumberOfItems(), 3)
EndScenario()

Summary()
