load "../../stzBase.ring"
load "../_narrated.ring"

# stzLLMFunction (base/neural/stzLLMFunction.ring) -- the two register rows, ReturnsNumber and ReturnsBoolean, kept
# as a guard now that the class reads a reply by rules. Run from inside this folder:
#     rnxc stzLLMFunction_defects_narrated.ring
# It needs no model, no network and no DLL beyond the engine: every reply comes from a fake responder
# (UseResponder), the seam the class already has for the refusal paths no seeded memo can reach.
#
# THE HISTORY: the register said ReturnsNumber read the first word that parsed as a number, so a reply whose first
# word was not numeric ("about 42", "none") raised a Ring error R41 inside the call instead of being refused or
# retried, and a comma split words so "1,5" read as 1. It said ReturnsBoolean searched the reply for the letters
# yes/true, then no/false, as SUBSTRINGS, so "unknown" read as 0 and "yesterday" as 1. Both rows are repaired by
# ONE tokenizer (_Tokenize) and two readers that refuse what they cannot read with certainty.
#
# THE RULES the guard holds the class to:
#   ReturnsNumber   a reply is a number when, with surrounding quotes, backticks, asterisks, brackets and sentence
#                   punctuation ignored, it is ONE token written with the digits 0 to 9 (sign, whole digits,
#                   point and digits, exponent), alone or between plain filler words (the, answer, is, ...).
#                   A comma is a thousands mark between digit groups of three and nothing else: "1,000" is 1000,
#                   "1,5" is REFUSED (the class has no locale, so a lone comma cannot be told from a thousands
#                   mark). Refused as well: a hedge or any other word, two numbers, %, NaN, inf, 0x10, digits of
#                   another script, a NUL byte, an integer of more than 15 digits, a number that is not finite or
#                   that falls to zero, a question mark after the number.
#   ReturnsBoolean  yes, y, true, 1 / no, n, false, 0 as the WHOLE reply, any case, punctuation ignored. A longer
#                   reply is read by its first word (yes, true, no, false) followed by a comma, period, dash or
#                   line break; the rest may repeat the answer, never contradict it, never hedge. Whole words in
#                   any script: unknown, not sure, nobody, yesterday, know are refused.
#   ReturnsOneOf    unchanged, except that a choice must now stand as a WHOLE WORD inside a longer reply: reddish
#                   is not red (the same substring defect, in the same function).
#   ReturnsString, ReturnsStructure   unchanged.
#   A refused reply is the class's own refusal (retried inside Budget, then the LAW 3 raise that says why), never a
#   Ring error from the parser, and is never memoized.
#
# Every positive carries a negative sibling. ASCII only on the console: a reply is shown through LfLabel.

$cLfReply = ""
$aLfSeq = []
$nLfAt = 0
$cLfSt = ""
$xLfVal = ""
$cLfErr = ""
$oLfF = ""
$oLfA = ""
$oLfB = ""
$cLfSrc = ""
$nLfRing = 0
$cLfErrA = ""
$cLfErrB = ""
$cLfRA = ""
$cLfRB = ""

$cHeYes = "כן"
$cHeNo = "לא"
$cArYes = "نعم"
$cArNo = "لا"
$cZhYes = "是"
$cZhNo = "否"
$cJaYes = "はい"
$cHeWord = "אבג"
$cArDigits = "٤٢"
$cDevDigits = "४२"
$cFullDigits = "４２"
$cLq = char(226) + char(128) + char(156)
$cRq = char(226) + char(128) + char(157)
$cUMinus = char(226) + char(136) + char(146)
$cQ = char(34)

# ---------------------------------------------------------------------------------------------------------------
Scenario("1. ReturnsNumber: the replies a model really gives are read, as the number they hold")
try
	Given("a number function whose fake model answers each reply in turn")
	aOk = [
		[ "42", 42 ], [ "  42  ", 42 ], [ "42.", 42 ], [ "42!", 42 ], [ $cQ + "42" + $cQ, 42 ], [ "'42'", 42 ],
		[ "`42`", 42 ], [ "**42**", 42 ], [ "(42)", 42 ], [ $cLq + "42" + $cRq, 42 ], [ $cQ + "42." + $cQ, 42 ],
		[ "-7", -7 ], [ "+5", 5 ], [ $cUMinus + "7", -7 ], [ "3.14", 3.14 ], [ ".5", 0.5 ], [ "-.5", -0.5 ],
		[ "0", 0 ], [ "0.0", 0 ], [ "-0", 0 ], [ "00", 0 ], [ "07", 7 ], [ "1e3", 1000 ], [ "1E3", 1000 ],
		[ "2.5e-3", 0.0025 ], [ "1,000", 1000 ], [ "12,345", 12345 ], [ "1,000,000", 1000000 ],
		[ "1,000.5", 1000.5 ], [ "-1,000", -1000 ], [ "999999999999999", 999999999999999 ],
		[ "The answer is 42", 42 ], [ "the answer is 42.", 42 ], [ "Answer: 42", 42 ], [ "It is 42.", 42 ],
		[ "The result is -7.", -7 ], [ "so the total is 1,000", 1000 ], [ "42" + char(10), 42 ],
		[ char(10) + "  42" + char(10) + char(10), 42 ], [ "42" + char(9), 42 ], [ "42" + char(13) + char(10), 42 ]
	]
	LfOkAll("number", aOk)
	When("the reply is a decimal of many digits")
	LfRun("number", "3.14159265358979323846")
	Then("it is accepted (a decimal keeps its magnitude)", $cLfSt, "ok")
	Then("...as 3.14159...", $xLfVal > 3.14159 and $xLfVal < 3.1416, 1)
	When("the reply is the largest integer written with 15 digits")
	LfRun("number", "123456789012345")
	Then("it is accepted exactly", $cLfSt, "ok")
	Then("...digit for digit", LfSame($xLfVal, 123456789012345), 1)
catch
	Then("scene 1 raised: " + cCatchError, 0, 1)
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("2. ReturnsNumber: the register row -- a reply that is not a number is REFUSED, never an R41")
try
	Given("the replies the register named, and the ones around them")
	aNo = [
		"", "   ", char(10), "about 42", "none", "approximately forty", "forty-two", "forty", "N/A", "unknown",
		"The answer is not 42", "Maybe 42", "roughly 42", "42 or 43", "between 40 and 50", "at least 42",
		"42 apples", "42 apples and 7 pears", "4 2", "4" + char(10) + "2", "42, 43", "1 and 2",
		"5%", "NaN", "nan", "inf", "-inf", "infinity", "0x10", "0b101", "1.5.3", "1..5", "--5", "+-5", "e5", "1e", "1e+",
		"5-10", "1/2", "1_000", "$5", "5kg", "x42", "42x", "42?", "?42", "forty-2",
		"-", "+", ".", ",", "e", "1e999", "1e-999", "-1e999",
		"1234567890123456", "1234567890123456789012345678901234567890", "-1234567890123456"
	]
	LfNoAll("number", aNo)
	Then("the NEGATIVE sibling: a plain 42 is still read", LfValueOf("number", "42"), 42)
catch
	Then("scene 2 raised: " + cCatchError, 0, 1)
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("3. ReturnsNumber: the comma rule -- a thousands comma is read, a lone comma is refused as ambiguous")
try
	Given("the same digits with a comma between them")
	Then("1,000 is a thousand", LfValueOf("number", "1,000"), 1000)
	Then("1,500 is fifteen hundred, a thousands comma, not 1.5", LfValueOf("number", "1,500"), 1500)
	Then("1,234,567.89 reads whole", LfValueOf("number", "1,234,567.89"), 1234567.89)
	LfNoAll("number", [ "1,5", "1,50", "12,34", "1,5000", "1,23,456", "1,000,00", "1,000,0", ",5", ",500", "1.000,5", "1, 5", "1,,000" ])
	Then("1,5 gives no value at all: not 1 as the register read it, not 15, not 1.5", LfValueOf("number", "1,5"), "refused")
	Then("...nor as 1.5: the class has no locale and says so", LfWhy("number", "1,5", "comma"), 1)
	Then("two numbers split by a comma are two numbers, refused", LfWhy("number", "1, 2", "more than one"), 1)
catch
	Then("scene 3 raised: " + cCatchError, 0, 1)
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("4. ReturnsNumber: other scripts and bytes -- Latin, Hebrew, Arabic, CJK, digits of other scripts, odd bytes")
try
	Given("replies in each script, with the digits 0 to 9 and without")
	LfNoAll("number", [
		$cArDigits, $cDevDigits, $cFullDigits, "42" + $cArDigits, $cArDigits + "42",
		"42 " + "שקל", "המספר 42", "العدد 42", "答案是 42", "42个", "答案是" + "四十二", $cHeWord, "אחד",
		"4" + char(0) + "2", "42" + char(0), char(0), "42" + char(0) + "9", char(1) + "42", "42" + char(27),
		char(255), "4" + char(255) + "2", char(226) + char(128), "42" + char(226)
	])
	Then("a Hebrew word never reads as a number or a filler", LfWhy("number", $cHeWord, "filler"), 1)
	Then("digits of another script are refused with the digits named", LfWhy("number", $cArDigits, "digits 0 to 9"), 1)
	Then("a NUL byte is named", LfWhy("number", "4" + char(0) + "2", "NUL"), 1)
	Then("an invalid UTF-8 reply is named", LfWhy("number", char(255), "UTF-8"), 1)
	Then("Latin digits split by a space are two numbers: refused", LfValueOf("number", "The answer is 4 2"), "refused")
	Then("NEGATIVE sibling: a single 42 after plain filler words reads", LfValueOf("number", "the answer is 42"), 42)
catch
	Then("scene 4 raised: " + cCatchError, 0, 1)
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("5. ReturnsBoolean: the register row -- whole words only, so unknown, not sure, nobody, yesterday are refused")
try
	Given("the replies that read as yes or no")
	aYes = [ "yes", "YES", "Yes", "Yes.", "yes!", "y", "Y", "true", "True", "TRUE", "1", "  yes  ", $cQ + "yes" + $cQ, "'yes'",
		"`yes`", "**Yes**", "(yes)", "yes." + char(10), "Yes, it is.", "Yes, it is true.", "Yes - sure", "Yes: indeed",
		"yes, I think so", "Yes." + char(10) + "The sea is salty.", "yes" + char(10) + "because", "true, that is true", $cLq + "Yes" + $cRq ]
	aNo = [ "no", "NO", "No", "NO.", "no!", "n", "N", "false", "False", "FALSE", "0", "no.", "No, that is false.", "No - sorry",
		"No." + char(10) + "The sun is hot.", "false, it is false" ]
	LfBoolAll(aYes, 1)
	LfBoolAll(aNo, 0)
	Given("the replies the register named, and the words that hide yes or no inside them")
	LfNoAll("boolean", [
		"", "   ", "unknown", "Unknown", "not sure", "Not sure.", "nobody", "yesterday", "know", "I do not know", "I don't know",
		"maybe", "perhaps", "none", "nothing", "nope", "yeah", "yep", "nay", "yess", "truee", "falsetto", "false alarm", "true story",
		"innocent", "anyone", "annoy", "notyes", "yesno", "yes/no", "y/n", "yes-no", "no problem", "no one", "no way",
		"Answer: yes", "The answer is yes", "I think yes", "yes yes", "no no", "yes?", "no?", "yes?!",
		"2", "-1", "10", "01", "1.0", "1 0", "0 1", "11", "--", "?", "true or false", "yes or no"
	])
	Then("unknown was read as 0 by the register; it is refused now", LfStatus("boolean", "unknown"), "refused")
	Then("yesterday was read as 1 by the register; it is refused now", LfStatus("boolean", "yesterday"), "refused")
	Then("nobody was read as 0 by the register; it is refused now", LfStatus("boolean", "nobody"), "refused")
	Then("not sure was read as 0 by the register; it is refused now", LfStatus("boolean", "not sure"), "refused")
	Then("know was read as 0 by the register; it is refused now", LfStatus("boolean", "know"), "refused")
catch
	Then("scene 5 raised: " + cCatchError, 0, 1)
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("6. ReturnsBoolean: a reply holding both answers, a contradiction or a hedge is refused, never read as the first")
try
	Given("replies that hold a yes word and a no word, or hedge a yes")
	LfNoAll("boolean", [
		"Yes and no", "yes, no", "no, yes", "No, yes", "yes, it is false", "no, it is true", "Yes, no, yes",
		"yes but no", "Yes, but only on Tuesday", "Yes, however not always", "No, it is not.", "Yes, unless it rains",
		"Yes, if you like", "Yes, maybe", "Yes, probably", "Yes, I don't think so", "Yes, depends", "No, nobody knows",
		"true false", "False, true", "yes!no", "yes,no"
	])
	Then("a contradiction is named as one", LfWhy("boolean", "no, yes", "both"), 1)
	Then("a hedge is named as one", LfWhy("boolean", "Yes, maybe", "hedges"), 1)
	Then("a lead word run into the sentence is named", LfWhy("boolean", "yes yes", "followed by"), 1)
	Then("a reply with no answer word says so", LfWhy("boolean", "unknown", "not one of yes"), 1)
	Then("a longer reply that does not begin with an answer says so", LfWhy("boolean", "Answer: yes", "does not begin"), 1)
	Then("a question mark after the answer is named", LfWhy("boolean", "yes?", "question mark"), 1)
	Then("NEGATIVE sibling: the same answer repeated without a contradiction is read", LfValueOf("boolean", "Yes, it is true."), 1)
	Then("NEGATIVE sibling: no then false agree", LfValueOf("boolean", "No, that is false."), 0)
catch
	Then("scene 6 raised: " + cCatchError, 0, 1)
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("7. ReturnsBoolean: Latin, Hebrew, Arabic, CJK -- words are whole words in any script, the answer words are English")
try
	Given("answers in other scripts and English words touching them")
	LfNoAll("boolean", [
		$cHeYes, $cHeNo, $cArYes, $cArNo, $cZhYes, $cZhNo, $cJaYes, $cHeYes + "!", $cHeWord,
		"yes" + $cHeYes, $cHeYes + "yes", "no" + $cArYes, "true" + $cZhYes, "yes" + $cHeWord, $cHeWord + "yes",
		"ye" + char(0) + "s", "yes" + char(0), char(0), "y" + char(255), char(255), "yes" + char(226)
	])
	Then("an English yes with a Hebrew word after the comma still reads: no hedge, no contradiction", LfValueOf("boolean", "yes, " + $cHeYes), 1)
	Then("...and with an Arabic one", LfValueOf("boolean", "no, " + $cArNo), 0)
	Then("a Hebrew yes is not read as yes: the word does not match", LfStatus("boolean", $cHeYes), "refused")
	Then("yes touching a Hebrew letter is not the word yes", LfStatus("boolean", "yes" + $cHeWord), "refused")
	Then("a NUL byte is named", LfWhy("boolean", "ye" + char(0) + "s", "NUL"), 1)
catch
	Then("scene 7 raised: " + cCatchError, 0, 1)
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("8. a refusal is the class's own: retried inside Budget, then the LAW 3 raise that says why, never memoized")
try
	Given("a number function that is first answered with replies it must refuse")
	LfSeq([ "about 42", "none", "42" ])
	$oLfF = LfNewSeq("number", 5, 2)
	When("it is called once")
	LfCallGlobal("x1")
	Then("it answers 42 on the third attempt, after two refusals", $xLfVal, 42)
	Then("...having spent exactly three calls", $oLfF.CallsMade(), 3)
	Then("...and Why says the attempt that validated", LfHas($oLfF.Why(), "attempt 3"), 1)
	Then("...and Why says a FAKE answered", LfHas($oLfF.Why(), "FAKE"), 1)
	When("the same input is asked again, with a model that would now answer garbage")
	LfSeq([ "garbage" ])
	LfCallGlobal("x1")
	Then("the memoized 42 is served", $xLfVal, 42)
	Then("...for free: still three calls", $oLfF.CallsMade(), 3)

	Given("a boolean function answered with unknown, then yesterday, then yes")
	LfSeq([ "unknown", "yesterday", "yes" ])
	$oLfF = LfNewSeq("boolean", 5, 2)
	LfCallGlobal("q")
	Then("it answers 1 on the third attempt", $xLfVal, 1)
	Then("...three calls", $oLfF.CallsMade(), 3)

	Given("a number function whose retries are 1 and whose model never complies")
	LfSeq([ "about 42" ])
	$oLfF = LfNewSeq("number", 9, 1)
	LfCallGlobal("x2")
	Then("it REFUSES, with the class's own message", LfHas($cLfErr, "no valid 'number'"), 1)
	Then("...naming the retries", LfHas($cLfErr, "in 1 retries"), 1)
	Then("...and WHY: the word that broke it", LfHas($cLfErr, "WHY: the word about"), 1)
	Then("...no Ring error among it", LfHas($cLfErr, "Error (R"), 0)
	Then("...having spent the first attempt and one retry, no more", $oLfF.CallsMade(), 2)

	Given("a boolean function whose budget is 2 though retries are 9, and whose model never complies")
	LfSeq([ "maybe" ])
	$oLfF = LfNewSeq("boolean", 2, 9)
	LfCallGlobal("q2")
	Then("Budget(n) still bounds the retries", LfHas($cLfErr, "Budget exhausted"), 1)
	Then("...having spent exactly the budget", $oLfF.CallsMade(), 2)

	Given("a refusal, then a good reply for the SAME input")
	LfSeq([ "about 42" ])
	$oLfF = LfNewSeq("number", 4, 0)
	LfCallGlobal("same")
	Then("the first call is refused", $cLfSt, "refused")
	LfSeq([ "42" ])
	LfCallGlobal("same")
	Then("the second call, with a good model, answers 42: the refusal left nothing in the memo", $xLfVal, 42)
	Then("...and the refusal is not in the findings of a scalar", len($oLfF.LastFindings()), 0)
catch
	Then("scene 8 raised: " + cCatchError, 0, 1)
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("9. two functions share no state: a refusal, a reason, a memo and a budget stay in their own object")
try
	Given("a number function A and a boolean function B, each with its own fake model")
	$cLfRA = "7"
	$cLfRB = "no"
	$oLfA = LfNewNamed("number", 3, 0, "LfRepA")
	$oLfB = LfNewNamed("boolean", 3, 0, "LfRepB")
	Then("A answers 7", $oLfA.Call_("i"), 7)
	Then("B answers 0 from its own model", $oLfB.Call_("i"), 0)
	Then("A spent one call", $oLfA.CallsMade(), 1)
	Then("B spent one call", $oLfB.CallsMade(), 1)
	When("A is refused with about 42 and B, another number function, is refused with 1,5")
	$cLfRA = "about 42"
	$cLfRB = "1,5"
	$oLfA = LfNewNamed("number", 3, 0, "LfRepA")
	$oLfB = LfNewNamed("number", 3, 0, "LfRepB")
	$cLfErrA = ""
	$cLfErrB = ""
	try
		$oLfA.Call_("r1")
	catch
		$cLfErrA = cCatchError
	done
	try
		$oLfB.Call_("r2")
	catch
		$cLfErrB = cCatchError
	done
	Then("A's refusal names about", LfHas($cLfErrA, "about"), 1)
	Then("B's refusal names the comma", LfHas($cLfErrB, "comma"), 1)
	Then("B's refusal does not carry A's reason", LfHas($cLfErrB, "about"), 0)
	Then("A's refusal does not carry B's reason", LfHas($cLfErrA, "comma"), 0)
	When("two number functions with the same name are asked the same input but answered differently")
	$cLfRA = "1"
	$cLfRB = "2"
	$oLfA = LfNewNamed("number", 3, 0, "LfRepA")
	$oLfB = LfNewNamed("number", 3, 0, "LfRepB")
	Then("A answers its own model's 1", $oLfA.Call_("same"), 1)
	Then("B answers its own model's 2", $oLfB.Call_("same"), 2)
	$cLfRA = "9"
	$cLfRB = "8"
	Then("A's memo still holds A's answer", $oLfA.Call_("same"), 1)
	Then("B's memo still holds B's answer", $oLfB.Call_("same"), 2)
	Then("neither spent a second call", $oLfA.CallsMade() + $oLfB.CallsMade(), 2)
catch
	Then("scene 9 raised: " + cCatchError, 0, 1)
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("10. the other Returns* types: ReturnsString and ReturnsStructure unchanged, ReturnsOneOf with whole words")
try
	Given("a string function")
	Then("it trims a reply", LfValueOf("string", "  hi  "), "hi")
	Then("...keeps a number as text", LfValueOf("string", "42"), "42")
	Then("...keeps unknown, which is a fine string", LfValueOf("string", "unknown"), "unknown")
	Then("...accepts an empty reply, as it always did", LfStatus("string", ""), "ok")
	Given("a one-of function over red and green")
	Then("red is red", LfValueOf("oneof", "red"), "red")
	Then("RED is red, kept in lower case", LfExactValue("oneof", "RED", "red"), 1)
	Then("Red. is red", LfValueOf("oneof", "Red."), "red")
	Then("it is red is red: one choice inside a longer reply", LfValueOf("oneof", "it is red"), "red")
	Then("the answer is: red is red", LfValueOf("oneof", "the answer is: red"), "red")
	Then("a quoted red is red", LfValueOf("oneof", $cQ + "red" + $cQ), "red")
	LfNoAll("oneof", [ "red or green", "red green", "blue", "", "   ", "reddish", "predator", "redhead", "unred", "red2", "2red", "greener" ])
	Then("reddish was read as red by the substring search; it is refused now", LfStatus("oneof", "reddish"), "refused")
	Then("NEGATIVE sibling: a choice beside punctuation still reads", LfValueOf("oneof", "(green)"), "green")
	Given("a one-of function over Hebrew choices")
	Then("the Hebrew choice alone is read", LfValueOf("oneofhe", $cHeWord), $cHeWord)
	Then("...with a sentence word before it", LfValueOf("oneofhe", "הוא " + $cHeWord), $cHeWord)
	Then("...and a Hebrew letter after it makes another word: refused", LfStatus("oneofhe", $cHeWord + "ד"), "refused")
	Then("...and before it too", LfStatus("oneofhe", "ד" + $cHeWord), "refused")
	Given("a one-of function over the digits 1 and 2")
	Then("option 2 is 2", LfValueOf("oneofnum", "option 2"), "2")
	LfNoAll("oneofnum", [ "12", "21", "1 2", "option 12", "3" ])
	Given("a structure with a number, a boolean and a one-of field")
	Then("a good memo reply is read whole", LfStructOk("name: Ada" + char(10) + "age: 36" + char(10) + "ok: yes" + char(10) + "c: red"), 1)
	Then("age: about 42 is refused by the schema, no Ring error", LfStatus("structure", "name: Ada" + char(10) + "age: about 42" + char(10) + "ok: yes" + char(10) + "c: red"), "refused")
	Then("ok: unknown is refused by the schema", LfStatus("structure", "name: Ada" + char(10) + "age: 36" + char(10) + "ok: unknown" + char(10) + "c: red"), "refused")
	Then("c: reddish is refused by the schema", LfStatus("structure", "name: Ada" + char(10) + "age: 36" + char(10) + "ok: yes" + char(10) + "c: reddish"), "refused")
	Then("age: 1,5 is refused by the schema", LfStatus("structure", "name: Ada" + char(10) + "age: 1,5" + char(10) + "ok: yes" + char(10) + "c: red"), "refused")
	Then("an empty reply is refused by the schema", LfStatus("structure", ""), "refused")
catch
	Then("scene 10 raised: " + cCatchError, 0, 1)
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("11. seeds, determinism and size: the memo door is unchanged, a reply is judged the same twice, a long reply is cheap")
try
	Given("a number function seeded with a known answer")
	$oLfF = LfNewSeq("number", 2, 0)
	$oLfF.SeedAnswer("2+3", 5)
	Then("the seed is served", $oLfF.Call_("2+3"), 5)
	Then("...for free", $oLfF.CallsMade(), 0)
	Given("the same reply judged twice by two fresh functions")
	Then("a refused reply is refused again", LfStatus("number", "about 42") + LfStatus("number", "about 42"), "refusedrefused")
	Then("an accepted reply reads the same again", LfValueOf("number", "1,000") + LfValueOf("number", "1,000"), 2000)
	Given("a very long reply")
	cLong = ""
	for i = 1 to 400
		cLong += "the "
	next
	Then("a long run of filler words and one number reads", LfValueOf("number", cLong + "42"), 42)
	Then("...and two numbers in it are refused", LfStatus("number", cLong + "42 " + cLong + "43"), "refused")
	cDigits = ""
	for i = 1 to 3000
		cDigits += "7"
	next
	Then("a digit string of 3000 digits is refused, not parsed", LfStatus("number", cDigits), "refused")
	cWords = ""
	for i = 1 to 600
		cWords += "maybe "
	next
	Then("a long reply of hedges is refused as a number", LfStatus("number", cWords), "refused")
	Then("...and as a boolean", LfStatus("boolean", cWords), "refused")
	Then("a long reply of yes words with separators and one hedge is refused", LfStatus("boolean", "yes, " + cWords), "refused")
catch
	Then("scene 11 raised: " + cCatchError, 0, 1)
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("12. no Ring error escapes for any type, whatever the reply: a sweep")
try
	Given("every type answered with every awkward reply")
	aOdd = [ "", " ", char(0), char(255), char(1), char(27), char(127), "'", $cQ, "`", "*", "**", "-", "--", "+", ".", ",", ";", ":", "...", "?", "!!",
		"(", ")", "[]", "{}", "e", "E", "1e", "e1", "0e0", "0,0", "0,000", "000,000", "-,5", "+.", "1,000,", ",,", "1.", "1.e3", ".e3", "-e3",
		"9" + char(0), "yes" + char(10) + char(0), char(226) + char(128) + char(156), char(226) + char(128) + char(156) + char(226) + char(128) + char(157),
		$cHeYes + " " + $cArYes + " " + $cZhYes, "'''", "yes'", "'yes", "don't", "n't", "'t", "t'", "a'b", "''yes''" ]
	LfNoRingError(aOdd)
	Then("every reply of the sweep was judged without a Ring error, for number, boolean, string, one-of and structure", $nLfRing, 0)
catch
	Then("scene 12 raised: " + cCatchError, 0, 1)
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("13. the doc and the code say what the class does now")
try
	Given("the source of the class")
	$cLfSrc = read("../../neural/stzLLMFunction.ring")
	Then("the source was read", len($cLfSrc) > 1000, 1)
	Then("no doc block says today", LfHas($cLfSrc, "today"), 0)
	Then("no doc block cites the defect file", LfHas($cLfSrc, "w13 defect file"), 0)
	Then("no doc block warns that a reply of unknown reads as 0", LfHas($cLfSrc, "unknown reads as 0"), 0)
	Then("no doc block warns of a Ring error R41", LfHas($cLfSrc, "raises a Ring error R41"), 0)
	Then("the class no longer searches a reply for the letters yes", LfHas($cLfSrc, 'StzFind("yes", _cT_)'), 0)
	Then("the class no longer parses the first word that is a number", LfHas($cLfSrc, "StzReplace(_cT_, char(10), "), 0)
	Then("ReturnsNumber states the comma rule", LfHas($cLfSrc, "A comma is read only as a thousands mark"), 1)
	Then("ReturnsBoolean states the whole-word rule", LfHas($cLfSrc, "Words are whole words"), 1)
catch
	Then("scene 13 raised: " + cCatchError, 0, 1)
done
EndScenario()

Summary()
shutdown($_zst_fail)

# ---------------------------------------------------------------------------------------------------------------
# helpers: functions come last, because in Ring a statement after a func belongs to that func

# builds a function of the given kind whose fake model returns the global $cLfReply
func LfNew(cType)
	_o_ = ""
	_cT_ = cType
	if cType = "structure" or cType = "struct"
		_o_ = LfNewStruct()
		return _o_
	ok
	_o_ = new stzLLMFunction("lf-" + cType)
	_o_.SetPrompt("q {input}")
	if _cT_ = "number"     _o_.ReturnsNumber()  ok
	if _cT_ = "boolean"    _o_.ReturnsBoolean() ok
	if _cT_ = "string"     _o_.ReturnsString()  ok
	if _cT_ = "oneof"      _o_.ReturnsOneOf([ "red", "green" ]) ok
	if _cT_ = "oneofhe"    _o_.ReturnsOneOf([ "אבג", "דהו" ]) ok
	if _cT_ = "oneofnum"   _o_.ReturnsOneOf([ "1", "2" ]) ok
	_o_.Budget(1)
	_o_.SetRetries(0)
	_o_.UseResponder(func cP, nT { return $cLfReply })
	return _o_

func LfNewStruct()
	_o_ = new stzLLMFunction("lf-structure")
	_o_.SetPrompt("q {input}")
	_o_.ReturnsStructure([
		[ :field = "name", :type = :string ],
		[ :field = "age",  :type = :number ],
		[ :field = "ok",   :type = :boolean ],
		[ :field = "c",    :type = :oneof, :choices = [ "red", "green" ] ] ])
	_o_.Budget(1)
	_o_.SetRetries(0)
	_o_.UseResponder(func cP, nT { return $cLfReply })
	return _o_

# runs one reply through a fresh function; leaves the status in $cLfSt, the value in $xLfVal, the raise text in $cLfErr
func LfRun(cType, cReply)
	$cLfReply = cReply
	$cLfSt = ""
	$xLfVal = ""
	$cLfErr = ""
	_o_ = LfNew(cType)
	try
		$xLfVal = _o_.Call_("x")
		$cLfSt = "ok"
	catch
		$cLfErr = cCatchError
		$cLfSt = LfClass($cLfErr)
	done

func LfClass(cErr)
	if LfHas(cErr, "Error (R") = 1
		return "ringerror"
	ok
	if LfHas(cErr, "The model produced no valid '") = 1
		return "refused"
	ok
	return "other: " + left(cErr, 80)

func LfStatus(cType, cReply)
	LfRun(cType, cReply)
	return $cLfSt

# the value of an accepted reply, or the text refused / ringerror
func LfValueOf(cType, cReply)
	LfRun(cType, cReply)
	if $cLfSt = "ok"
		return $xLfVal
	ok
	return $cLfSt

func LfExactValue(cType, cReply, cWant)
	LfRun(cType, cReply)
	if $cLfSt != "ok"
		return 0
	ok
	return LfSame($xLfVal, cWant)

func LfWhy(cType, cReply, cNeedle)
	LfRun(cType, cReply)
	if $cLfSt != "refused"
		return 0
	ok
	return LfHas($cLfErr, "WHY: ") * LfHas($cLfErr, cNeedle)

func LfStructOk(cReply)
	LfRun("structure", cReply)
	if $cLfSt != "ok"
		return 0
	ok
	_a_ = $xLfVal
	if _a_[:age] = 36 and _a_[:ok] = 1 and _a_[:c] = "red" and _a_[:name] = "Ada"
		return 1
	ok
	return 0

func LfOkAll(cType, aPairs)
	_n_ = len(aPairs)
	for _i_ = 1 to _n_
		LfRun(cType, aPairs[_i_][1])
		Then(cType + " accepts [" + LfLabel(aPairs[_i_][1]) + "]", $cLfSt, "ok")
		Then("   ...and reads it as " + aPairs[_i_][2], LfSame($xLfVal, aPairs[_i_][2]), 1)
	next

func LfNoAll(cType, acReplies)
	_n_ = len(acReplies)
	for _i_ = 1 to _n_
		LfRun(cType, acReplies[_i_])
		Then(cType + " REFUSES [" + LfLabel(acReplies[_i_]) + "], no Ring error", $cLfSt, "refused")
	next

func LfBoolAll(acReplies, nWant)
	_n_ = len(acReplies)
	for _i_ = 1 to _n_
		LfRun("boolean", acReplies[_i_])
		Then("boolean reads [" + LfLabel(acReplies[_i_]) + "] as " + nWant, LfSt2($cLfSt, $xLfVal), "ok" + nWant)
	next

func LfSt2(cSt, xVal)
	if cSt = "ok"
		return "ok" + xVal
	ok
	return cSt

func LfNoRingError(acReplies)
	$nLfRing = 0
	_acTypes_ = [ "number", "boolean", "string", "oneof", "oneofhe", "structure" ]
	_n_ = len(acReplies)
	for _i_ = 1 to _n_
		for _j_ = 1 to len(_acTypes_)
			LfRun(_acTypes_[_j_], acReplies[_i_])
			if $cLfSt != "ok" and $cLfSt != "refused"
				$nLfRing++
				? "      ring error or other: " + _acTypes_[_j_] + " [" + LfLabel(acReplies[_i_]) + "] -> " + $cLfSt
			ok
		next
	next

# ---- the retry scenes: a fake model that returns a sequence of replies, one per attempt ----

func LfSeq(aReplies)
	$aLfSeq = aReplies
	$nLfAt = 0

func LfNextReply()
	$nLfAt++
	if $nLfAt > len($aLfSeq)
		return $aLfSeq[len($aLfSeq)]
	ok
	return $aLfSeq[$nLfAt]

func LfNewSeq(cType, nBudget, nRetries)
	_o_ = new stzLLMFunction("lf-seq")
	_o_.SetPrompt("q {input}")
	if cType = "number"  _o_.ReturnsNumber()  ok
	if cType = "boolean" _o_.ReturnsBoolean() ok
	_o_.Budget(nBudget)
	_o_.SetRetries(nRetries)
	_o_.UseResponder(func cP, nT { return LfNextReply() })
	return _o_

func LfNewNamed(cType, nBudget, nRetries, cFunc)
	_o_ = new stzLLMFunction("lf-named")
	_o_.SetPrompt("q {input}")
	if cType = "number"  _o_.ReturnsNumber()  ok
	if cType = "boolean" _o_.ReturnsBoolean() ok
	_o_.Budget(nBudget)
	_o_.SetRetries(nRetries)
	_o_.UseResponder(cFunc)
	return _o_

func LfRepA(cPrompt, nTry)
	return $cLfRA

func LfRepB(cPrompt, nTry)
	return $cLfRB

# calls the global $oLfF
func LfCallGlobal(cInput)
	$cLfErr = ""
	$cLfSt = ""
	$xLfVal = ""
	try
		$xLfVal = $oLfF.Call_(cInput)
		$cLfSt = "ok"
	catch
		$cLfErr = cCatchError
		$cLfSt = LfClass($cLfErr)
	done

func LfSame(a, b)
	if isNumber(a) and isNumber(b)
		_d_ = a - b
		if _d_ < 0
			_d_ = 0 - _d_
		ok
		_m_ = b
		if _m_ < 0
			_m_ = 0 - _m_
		ok
		if _m_ < 1
			_m_ = 1
		ok
		if _d_ <= _m_ * 0.000000001
			return 1
		ok
		return 0
	ok
	if isString(a) and isString(b)
		if StzEngineCryptoSha256(a) = StzEngineCryptoSha256(b)
			return 1
		ok
		return 0
	ok
	return 0

func LfHas(cHay, cNeedle)
	if len(StzFind(cNeedle, cHay)) > 0
		return 1
	ok
	return 0

# a reply made printable: control bytes and every byte above 126 become a dot, the text is cut at 36 bytes
func LfLabel(c)
	_o_ = ""
	_n_ = len("" + c)
	_m_ = _n_
	if _m_ > 36
		_m_ = 36
	ok
	for _i_ = 1 to _m_
		_a_ = ascii(c[_i_])
		if _a_ = 10
			_o_ += "<LF>"
		but _a_ = 0
			_o_ += "<NUL>"
		but _a_ < 32 or _a_ > 126
			_o_ += "."
		else
			_o_ += c[_i_]
		ok
	next
	if _n_ > 36
		_o_ += "...(" + _n_ + " bytes)"
	ok
	return _o_
