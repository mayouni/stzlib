load "../../stzBase.ring"
load "../_narrated.ring"

# stzOccurrences -- the positions of a substring in a string, as a value object that acts on them.
# Register rows (all "answers an empty text", "raises R14" or "empty body" before this guard):
#   SubString   read @cSubStr while the constructor wrote @pcSubStr
#   String      read @cStr while the constructor wrote @pcStr
#   Removed     called RemoveSubStringAtPositionsCSQ, a method stzString does not have
#   ReplacedWithCS, Uppercased, Lowercased   empty bodies
# The guard drives every row with plain ASCII, accented letters and Hebrew (built from char codes, so the
# source stays ASCII and nothing non-ASCII is printed), overlapping occurrences, no occurrence, an empty
# substring and stale positions. Every positive has a negative sibling. Run from inside test/common.

$cE     = char(195) + char(169)                       # e acute
$cEUp   = char(195) + char(137)                       # E acute
$cHeb   = char(215) + char(169) + char(215) + char(156) + char(215) + char(149) + char(215) + char(157)
$cHebA  = char(215) + char(169) + char(215) + char(156)            # the first two letters of $cHeb
$cHebB  = char(215) + char(149) + char(215) + char(157)            # the last two letters of $cHeb
$cLastError = ""

Scenario("SubString and String answer what the constructor was given")
	o1 = new stzOccurrences([ 2, 4 ], "an", "banana")
	Then("SubString answers the substring (positional form)", Same(o1.SubString(), "an"), 1)
	Then("String answers the string (positional form)", Same(o1.String(), "banana"), 1)
	Then("SubString does not answer an empty text", Same(o1.SubString(), ""), 0)
	Then("String does not answer an empty text", Same(o1.String(), ""), 0)

	o2 = new stzOccurrences([ 2, 4 ], :Of = "an", :In = "banana")
	Then("SubString unwraps the :Of form to the plain text", Same(o2.SubString(), "an"), 1)
	Then("String unwraps the :In form to the plain text", Same(o2.String(), "banana"), 1)
	Then("the :Of form is not kept as a list", isString(o2.SubString()), 1)
	Then("the :In form is not kept as a list", isString(o2.String()), 1)

	o3 = new stzOccurrences([ 2, 4 ], :OfSubString = "an", :InString = "banana")
	Then("the :OfSubString and :InString forms fill both", Same(o3.SubString() + "/" + o3.String(), "an/banana"), 1)

	o4 = StzOccurrenceQ([ 2, 4 ], :Of = "an", :In = "banana")
	Then("the StzOccurrenceQ function fills both as well", Same(o4.SubString() + "/" + o4.String(), "an/banana"), 1)

	o5 = new stzOccurrences([ 1 ], $cHeb, $cHeb + "x")
	Then("a Hebrew substring and string come back whole", Same(o5.SubString(), $cHeb) and Same(o5.String(), $cHeb + "x"), 1)
	Then("SubStringQ chains into a string with the same content", o1.SubStringQ().Content(), "an")
	Then("StringQ chains into a string with the same content", o1.StringQ().Content(), "banana")
	Then("Occurrences still answers the positions, unchanged", @@(o1.Occurrences()), "[ 2, 4 ]")
	Then("Content and Value answer the same positions", @@(o1.Content()) + @@(o1.Value()), "[ 2, 4 ][ 2, 4 ]")
EndScenario()

Scenario("Removed cuts the substring at every occurrence")
	o1 = new stzOccurrences([ 2, 4 ], "an", "banana")
	Then("the substring is cut at both positions", Same(o1.Removed(), "ba"), 1)
	Then("the string is not left as it was", Same(o1.Removed(), "banana"), 0)
	Then("it does not raise and does not answer nothing", isString(o1.Removed()), 1)
	Then("the object's own string is unchanged afterwards", Same(o1.String(), "banana"), 1)
	Then("the positions are unchanged afterwards", @@(o1.Occurrences()), "[ 2, 4 ]")

	o2 = new stzOccurrences([ 1, 3, 5 ], "a", "ababab")
	Then("a one-letter substring is cut at three positions", Same(o2.Removed(), "bbb"), 1)

	o3 = new stzOccurrences([], "z", "banana")
	Then("no occurrence leaves the string unchanged", Same(o3.Removed(), "banana"), 1)
	Then("no occurrence is not an empty text", Same(o3.Removed(), ""), 0)

	o4 = new stzOccurrences([ 1, 2 ], "", "abc")
	Then("an empty substring leaves the string unchanged", Same(o4.Removed(), "abc"), 1)

	o5 = new stzOccurrences([ 1, 3, 5 ], "ab", "ababab")
	Then("positions out of order, or beyond the string, are taken safely: [ 5, 1, 3 ] cuts all three", Same(o5.Removed(), ""), 1)

	o6 = new stzOccurrences([ 5, 1, 3, 3, 99, 0, -2 ], "ab", "ababab")
	Then("duplicates, 0, a negative and a position past the end are ignored", Same(o6.Removed(), ""), 1)

	o7 = new stzOccurrences([ 1, 4 ], "ab", "ababab")
	Then("a stale position (the text there is not the substring) cuts nothing", Same(o7.Removed(), "abab"), 1)
	Then("it did not cut at position 4 where the text is ba", Same(o7.Removed(), "ab"), 0)

	o8 = new stzOccurrences([ "x", 1 ], "ab", "abab")
	Then("a non-number in the positions is ignored", Same(o8.Removed(), "ab"), 1)
EndScenario()

Scenario("Overlapping occurrences are cut left to right, as Remove on the string does")
	oo = new stzOccurrences([ 1, 2, 3 ], "aa", "aaaa")
	Then("aa in aaaa (positions 1,2,3) leaves an empty text", Same(oo.Removed(), ""), 1)
	Then("it is not left as one overlap cut", Same(oo.Removed(), "a"), 0)
	Then("the valid positions are 1 and 3, the overlapping 2 is dropped", @@(oo.ValidOccurrencesCS(1)), "[ 1, 3 ]")

	ob = new stzOccurrences([ 1, 2, 3, 4 ], "aa", "aaaaa")
	Then("aa in aaaaa leaves one a", Same(ob.Removed(), "a"), 1)

	oS = new stzString("aaaa")
	oS.Remove("aa")
	Then("stzString.Remove on aaaa agrees", Same(oS.Content(), oo.Removed()), 1)
	oS2 = new stzString("aaaaa")
	oS2.Remove("aa")
	Then("stzString.Remove on aaaaa agrees", Same(oS2.Content(), ob.Removed()), 1)
EndScenario()

Scenario("Removed on accented and Hebrew text counts characters, not bytes")
	cStr = "caf" + $cE + " " + $cE + "t" + $cE
	oa = new stzOccurrences(StzFindCS($cE, cStr, 1), $cE, cStr)
	Then("the finder gives codepoint positions 4, 6 and 8", @@(oa.Occurrences()), "[ 4, 6, 8 ]")
	Then("every e acute is cut", Same(oa.Removed(), "caf t"), 1)
	Then("the cut text is not the original", Same(oa.Removed(), cStr), 0)

	oh = new stzOccurrences([ 3 ], $cHebB, $cHeb)
	Then("a Hebrew tail is cut at its codepoint position 3", Same(oh.Removed(), $cHebA), 1)
	oh2 = new stzOccurrences([ 1, 4 ], $cHebA, $cHeb + $cHebA + "z")
	Then("only the first hit is valid, position 4 starts at a different pair", @@(oh2.ValidOccurrencesCS(1)), "[ 1 ]")
	oh3 = new stzOccurrences([ 1, 5 ], $cHebA, $cHebA + $cHebB + $cHebA + "z")
	Then("two Hebrew hits around another are both cut", Same(oh3.Removed(), $cHebB + "z"), 1)

	ox = new stzString(cStr)
	ox.Remove($cE)
	Then("stzString.Remove agrees on the accented text", Same(ox.Content(), oa.Removed()), 1)
	Then("the result length is counted in characters: 5", StzLen(oa.Removed()), 5)
EndScenario()

Scenario("RemovedCS and the case flag")
	oc = new stzOccurrences([ 2, 4 ], "AN", "banana")
	Then("matching case: AN is not in banana, so nothing is cut", Same(oc.RemovedCS(1), "banana"), 1)
	Then("Removed is the case-sensitive one", Same(oc.Removed(), "banana"), 1)
	Then("ignoring case: both hits are cut", Same(oc.RemovedCS(0), "ba"), 1)
	Then("ignoring case is not the string unchanged", Same(oc.RemovedCS(0), "banana"), 0)
	od = new stzOccurrences([ 2, 4 ], "an", "banana")
	Then("a lower-case substring is cut in both modes", Same(od.RemovedCS(1), od.RemovedCS(0)), 1)
	oe = new stzOccurrences([ 1, 3 ], $cEUp, $cEUp + "x" + $cE)
	Then("e acute against E acute: case-sensitive cuts one", Same(oe.RemovedCS(1), "x" + $cE), 1)
	Then("e acute against E acute: case-insensitive cuts the two", Same(oe.RemovedCS(0), "x"), 1)
EndScenario()

Scenario("ReplacedWithCS puts a text at every occurrence")
	o1 = new stzOccurrences([ 2, 4 ], "an", "banana")
	Then("each occurrence is replaced", Same(o1.ReplacedWithCS("XY", 1), "bXYXYa"), 1)
	Then("it does not answer an empty text", Same(o1.ReplacedWithCS("XY", 1), ""), 0)
	Then("it is not the original string", Same(o1.ReplacedWithCS("XY", 1), "banana"), 0)
	Then("an empty replacement is a removal", Same(o1.ReplacedWithCS("", 1), o1.Removed()), 1)
	Then("a shorter replacement works", Same(o1.ReplacedWithCS("-", 1), "b--a"), 1)
	Then("a longer replacement works", Same(o1.ReplacedWithCS("123", 1), "b123123a"), 1)
	Then("the object's string is unchanged afterwards", Same(o1.String(), "banana"), 1)
	Then(":With is accepted", Same(o1.ReplacedWithCS(:With = "Q", 1), "bQQa"), 1)
	Then(":By is accepted", Same(o1.ReplacedWithCS(:By = "Q", 1), "bQQa"), 1)
	Then("ReplacedWith is the case-sensitive form", Same(o1.ReplacedWith("Q"), "bQQa"), 1)
	Then("ReplacedWith accepts :By too", Same(o1.ReplacedWith(:By = "Q"), "bQQa"), 1)

	o2 = new stzOccurrences([], "z", "banana")
	Then("no occurrence leaves the string unchanged", Same(o2.ReplacedWithCS("Q", 1), "banana"), 1)
	o3 = new stzOccurrences([ 1 ], "", "banana")
	Then("an empty substring leaves the string unchanged", Same(o3.ReplacedWithCS("Q", 1), "banana"), 1)

	o4 = new stzOccurrences([ 2, 4 ], "AN", "banana")
	Then("matching case: nothing replaced", Same(o4.ReplacedWithCS("Q", 1), "banana"), 1)
	Then("ignoring case: both replaced", Same(o4.ReplacedWithCS("Q", 0), "bQQa"), 1)

	oo = new stzOccurrences([ 1, 2, 3 ], "aa", "aaaa")
	Then("overlapping hits: left to right, 2 replacements", Same(oo.ReplacedWithCS("X", 1), "XX"), 1)
	oS = new stzString("aaaa")
	oS.Replace("aa", "X")
	Then("stzString.Replace agrees on the overlap", Same(oS.Content(), oo.ReplacedWithCS("X", 1)), 1)

	cStr = "caf" + $cE + " " + $cE + "t" + $cE
	oa = new stzOccurrences(StzFindCS($cE, cStr, 1), $cE, cStr)
	Then("accented text: e acute replaced by e", Same(oa.ReplacedWithCS("e", 1), "cafe et" + "e"), 1)
	Then("accented text: replaced by two characters, length 11", StzLen(oa.ReplacedWithCS("ee", 1)), 11)
	oh = new stzOccurrences([ 1 ], $cHebA, $cHeb)
	Then("Hebrew: the first two letters replaced by a Latin word", Same(oh.ReplacedWithCS("ab", 1), "ab" + $cHebB), 1)
	oh2 = new stzOccurrences([ 1 ], $cHebA, $cHeb)
	Then("Hebrew: replaced by Hebrew, whole", Same(oh2.ReplacedWithCS($cHebB, 1), $cHebB + $cHebB), 1)

	$cLastError = ""
	try
		o1.ReplacedWithCS(5, 1)
	catch
		$cLastError = cCatchError
	done
	Then("a number as the new text is refused with a message", ring_len($cLastError) > 0, 1)
EndScenario()

Scenario("Uppercased and Lowercased change the text at the occurrences only")
	o1 = new stzOccurrences([ 2, 4 ], "an", "banana")
	Then("the two hits are in capitals, the rest is untouched", Same(o1.Uppercased(), "bANANa"), 1)
	Then("it is not the whole string in capitals", Same(o1.Uppercased(), "BANANA"), 0)
	Then("it is not the original", Same(o1.Uppercased(), "banana"), 0)
	Then("the object's string is unchanged afterwards", Same(o1.String(), "banana"), 1)

	o2 = new stzOccurrences([ 2, 4 ], "AN", "bANANa")
	Then("the two hits are in small letters, the rest is untouched", Same(o2.Lowercased(), "banana"), 1)
	o3 = new stzOccurrences([ 1 ], "B", "BANANA")
	Then("only the hit is lowered, not the whole string", Same(o3.Lowercased(), "bANANA"), 1)
	Then("it is not the whole string in small letters", Same(o3.Lowercased(), "banana"), 0)

	o4 = new stzOccurrences([], "z", "banana")
	Then("no occurrence: Uppercased leaves the string unchanged", Same(o4.Uppercased(), "banana"), 1)
	Then("no occurrence: Lowercased leaves the string unchanged", Same(o4.Lowercased(), "banana"), 1)
	o5 = new stzOccurrences([ 1, 2 ], "", "banana")
	Then("an empty substring: Uppercased leaves the string unchanged", Same(o5.Uppercased(), "banana"), 1)

	oo = new stzOccurrences([ 1, 2, 3 ], "aa", "aaaa")
	Then("overlapping hits: left to right, all four letters", Same(oo.Uppercased(), "AAAA"), 1)
	oo2 = new stzOccurrences([ 1, 2, 3, 4 ], "aa", "aaaaa")
	Then("overlapping hits in aaaaa: the last letter stays", Same(oo2.Uppercased(), "AAAAa"), 1)

	cStr = "caf" + $cE + " " + $cE + "t" + $cE
	oa = new stzOccurrences(StzFindCS($cE, cStr, 1), $cE, cStr)
	Then("e acute becomes E acute at its three positions", Same(oa.Uppercased(), "caf" + $cEUp + " " + $cEUp + "t" + $cEUp), 1)
	Then("the accented result is not left lower-case", Same(oa.Uppercased(), cStr), 0)
	oa2 = new stzOccurrences([ 4 ], $cEUp, "CAF" + $cEUp)
	Then("E acute goes back to e acute", Same(oa2.Lowercased(), "CAF" + $cE), 1)

	oh = new stzOccurrences([ 1 ], $cHebA, $cHeb + "x")
	Then("Hebrew has no case: Uppercased changes nothing", Same(oh.Uppercased(), $cHeb + "x"), 1)
	oh2 = new stzOccurrences([ 5 ], "x", $cHeb + "x")
	Then("a Latin hit after Hebrew is capitalised at its codepoint position", Same(oh2.Uppercased(), $cHeb + "X"), 1)

	od = new stzOccurrences([ 2 ], "AN", "banana")
	Then("a case-different hit still counts for Uppercased", Same(od.Uppercased(), "bANana"), 1)
	ost = new stzOccurrences([ 2 ], "xx", "banana")
	Then("a stale position changes nothing", Same(ost.Uppercased(), "banana"), 1)
EndScenario()

Summary()

func Same(pcA, pcB)
	if NOT (isString(pcA) and isString(pcB))
		return 0
	ok
	return strcmp(pcA, pcB) = 0
