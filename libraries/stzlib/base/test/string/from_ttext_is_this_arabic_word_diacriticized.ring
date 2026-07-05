load "../../stzBase.ring"
load "../_narrated.ring"

# Arabic diacritics carry the INHERITED script (they attach to the
# base letter); a diacriticized word's dominant script is still Arabic.
# Extracted from stzTtexttest.ring, block #8.

Scenario("Diacritics and script")
	Then("the word has diacritics",
		StzStringQ("سَلَامُُ").ContainsDiacritics(), TRUE)
	Then("a bare letter is Arabic", StzStringQ("س").Script(), :Arabic)
	Then("a lone fat7ah is Inherited",
		StzStringQ(ArabicFat7ah()).Script(), :Inherited)
	Then("the diacriticized word is Arabic",
		StzStringQ("سَلَامُُ").Script(), :Arabic)
	Then("the diacriticized greeting too",
		StzStringQ("السَّلَامُ عَلَيْكُمْ").Script(), :Arabic)
	Then("and the plain greeting",
		StzStringQ("السلام عليكم").Script(), :Arabic)
EndScenario()

Summary()
