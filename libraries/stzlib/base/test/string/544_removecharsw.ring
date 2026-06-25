load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveCharsW with a { } predicate block -- drop the characters where the
# predicate is TRUE. Engine-backed, no eval() (the { } block that used to crash
# the WXT eval with an uncatchable C27 is stripped before the engine sees it).
# Migrated from the retired RemoveCharsWXT.

Scenario("RemoveCharsW removes every x / X from a sentence")
	Given("a Commodore-64 blurb peppered with stray x and X characters")
	Then('removing the { lower(@char) = "x" } block yields the clean sentence',
		Cleaned(), "The Commodore 64, also known as the C64 or the CBM 64, is an 8-bit home computer introduced in January 1982 by Commodore International")
EndScenario()

Summary()

func Cleaned
	o = new stzString("
	The xCommodore X64X, also known as the XC64 or the CBMx 64, is an x8-bit
	home computer introduced in January 1982x by CommodoreXx International
")
	o.Simplify()
	o.RemoveCharsW('{ lower(@char) = "x" }')
	return o.Content()
