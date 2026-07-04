load "../../stzBase.ring"
load "../_narrated.ring"

# Alignment is codepoint-based: the shadda counts as its own char, so
# the Arabic word is 9 units and gets 21 dots of padding. (The archive
# counted grapheme clusters -- 8 units, 22 dots; grapheme-aware
# alignment is on the engine backlog.) Archive block #813.

Scenario("An Arabic word in 30 columns")
	str = "منصوريّات"
	Then("nine codepoints", StzLen(str), 9)
	cDots21 = Q(".").RepeatedNTimes(21)
	Then("left = word + 21 dots",
		StringAlignXT(str, 30, ".", :Left), str + cDots21)
	Then("right = 21 dots + word",
		StringAlignXT(str, 30, ".", :Right), cDots21 + str)
	Then("center = 10 + word + 11",
		StringAlignXT(str, 30, ".", :Center),
		Q(".").RepeatedNTimes(10) + str + Q(".").RepeatedNTimes(11))
	Then("justified spans the full width",
		StzLen( StringAlignXT(str, 30, ".", :Justified) ), 30)
EndScenario()

Summary()
