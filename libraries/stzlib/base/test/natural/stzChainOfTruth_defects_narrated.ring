load "../../stzBase.ring"
load "../_narrated.ring"

# stzChainOfTruth -- the register's three rows (Containing, ContainingNo, Nth) and what they
# shared. Run from inside test/natural.
#
#   Containing / ContainingNo  built their condition between braces and Where refused braces, so
#       every text and every list raised "Syntax error! Check the condition you provided". They now
#       test the value directly (engine for a text, the list checker for a list): no condition text
#       is built, so nothing a value holds can be run as code.
#   Nth  ended with _( result ) inside the class, where _ is an attribute: the answer came back as
#       an empty text and any call on it died with R13 Object is required. It now returns a chain.
#
#   st, nd, rd, th  now follow the English rule. A number takes st when it ends in 1 and not in 11,
#       nd when it ends in 2 and not in 12, rd when it ends in 3 and not in 13, and th otherwise
#       (0, 4 to 20, 100, 111, 112, 113 ...). They went by the last digit alone before, so 11 took st,
#       12 nd and 13 rd, while 10 and 20 took nothing and 2 took th. That is an INTENDED change of
#       expected results: the assertion that pinned the old quirk (10 th gave an empty text) is
#       rewritten, and a scenario on the teens and a table of 31 numbers are added.
#
# The expectations are written by hand, never copied from a run. Texts beyond ASCII are built from
# char codes (UTF-8 bytes) and never printed. Every positive has a negative sibling.

$ctSideEffect = 0

eAc   = char(195) + char(169)                              # e acute, 1 codepoint, 2 bytes
alef  = char(215) + char(144)                              # Hebrew alef
bet   = char(215) + char(145)                              # Hebrew bet
gimel = char(215) + char(146)                              # Hebrew gimel
emo   = char(240) + char(159) + char(152) + char(128)      # grinning face, 1 codepoint, 4 bytes
emo2  = char(240) + char(159) + char(152) + char(129)      # another face

Scenario("The register rows: Containing, ContainingNo and Nth no longer raise")
	Given("a text chain, a list chain and a chain holding 7")
	cErr1 = ""
	nGot1 = -1
	try
		oR1 = _("HUSSEIN")
		oR1.Containing("S")
		nGot1 = oR1._
	catch
		cErr1 = cCatchError
	done
	Then("Containing on a text does not raise", cErr1, "")
	Then("and tags the chain true when the text holds the part", nGot1, 1)

	cErr2 = ""
	nGot2 = -1
	try
		oR2 = _([ "a", "b" ])
		oR2.Containing("a")
		nGot2 = oR2._
	catch
		cErr2 = cCatchError
	done
	Then("Containing on a list does not raise", cErr2, "")
	Then("and tags the chain true when the list holds the item", nGot2, 1)

	cErr3 = ""
	nGot3 = -1
	try
		oR3 = _("HUSSEIN")
		oR3.ContainingNo("S")
		nGot3 = oR3._
	catch
		cErr3 = cCatchError
	done
	Then("ContainingNo on a text does not raise", cErr3, "")
	Then("and tags the chain false when the text holds the part", nGot3, 0)

	cErr4 = ""
	nGot4 = -1
	try
		oR4 = _([ "a", "b" ])
		oR4.ContainingNo("c")
		nGot4 = oR4._
	catch
		cErr4 = cCatchError
	done
	Then("ContainingNo on a list does not raise", cErr4, "")
	Then("and tags the chain true when the list lacks the item", nGot4, 1)

	cErr5 = ""
	cGot5 = ""
	try
		oR5 = _(7)
		oN5 = oR5.Nth('LetterOf("HUSSEIN")')
		cGot5 = oN5.Value()
	catch
		cErr5 = cCatchError
	done
	Then("Nth on the number 7 does not raise (it used to answer an empty text, then R13 on first use)", cErr5, "")
	bSame5 = CtSame(cGot5, "N")
	Then("and the answer is the 7th letter of HUSSEIN", bSame5, 1)
	bSame5b = CtSame(NthLetterOf(7, "HUSSEIN"), "N")
	Then("the same answer as the call on its own", bSame5b, 1)
EndScenario()

Scenario("Containing and ContainingNo on a table of pairs: each is right, and they are exact complements")
	Given("22 pairs of a value and a part, with the answer written by hand")
	# row = [ label, value, p, expected holds ]
	aRows = []
	aRows + [ "text, part present", "HUSSEIN", "S", 1 ]
	aRows + [ "text, case differs", "HUSSEIN", "s", 0 ]
	aRows + [ "text, longer part inside", "HUSSEIN", "SSE", 1 ]
	aRows + [ "text, letters in the wrong order", "HUSSEIN", "SIE", 0 ]
	aRows + [ "text, empty part", "HUSSEIN", "", 1 ]
	aRows + [ "empty text, empty part", "", "", 1 ]
	aRows + [ "empty text, a part", "", "a", 0 ]
	aRows + [ "part longer than the text", "ab", "abc", 0 ]
	aRows + [ "part equal to the text", "HUSSEIN", "HUSSEIN", 1 ]
	aRows + [ "accented text holds its accented letter", eAc + "t" + eAc, eAc, 1 ]
	aRows + [ "accented text does not hold the plain letter", eAc + "t" + eAc, "e", 0 ]
	aRows + [ "accented text, part with an accent", eAc + "t" + eAc, "t" + eAc, 1 ]
	aRows + [ "Hebrew text holds its middle letter", alef + bet + gimel, bet, 1 ]
	aRows + [ "Hebrew text, letters that are not neighbours", alef + bet + gimel, alef + gimel, 0 ]
	aRows + [ "emoji text holds its emoji", "x" + emo + "y", emo, 1 ]
	aRows + [ "emoji text does not hold another emoji", "x" + emo + "y", emo2, 0 ]
	aRows + [ "text holding a quote and braces", 'say "hi" {x}', '"hi" {x}', 1 ]
	aRows + [ "text, number part is not a text", "a2b", 2, 0 ]
	aRows + [ "text, the text 2 is found", "a2b", "2", 1 ]
	aRows + [ "list of texts, item present", [ "a", "b" ], "a", 1 ]
	aRows + [ "list of texts, item absent", [ "a", "b" ], "c", 0 ]
	aRows + [ "list of texts, case differs", [ "a", "b" ], "A", 0 ]
	aRows + [ "list of numbers, item present", [ 1, 2, 3 ], 2, 1 ]
	aRows + [ "list of numbers, the text 2 is not the number 2", [ 1, 2, 3 ], "2", 0 ]
	aRows + [ "list of texts, the number 2 is not the text 2", [ "1", "2" ], 2, 0 ]
	aRows + [ "list of texts, the text 2 is found", [ "1", "2" ], "2", 1 ]
	aRows + [ "nested list, whole item", [ 1, [ 2, 3 ] ], [ 2, 3 ], 1 ]
	aRows + [ "nested list, a member of the inner list is not an item", [ 1, [ 2, 3 ] ], 2, 0 ]
	aRows + [ "nested list, part of the inner list", [ 1, [ 2, 3 ] ], [ 2 ], 0 ]
	aRows + [ "two levels deep", [ [ 1, [ 2 ] ] ], [ 1, [ 2 ] ], 1 ]
	aRows + [ "mixed list, number inside an inner list", [ "a", 2, [ 3 ] ], 3, 0 ]
	aRows + [ "mixed list, the inner list itself", [ "a", 2, [ 3 ] ], [ 3 ], 1 ]
	aRows + [ "list of accented and Hebrew texts, item present", [ eAc, alef ], eAc, 1 ]
	aRows + [ "list of accented texts, plain letter absent", [ eAc, alef ], "e", 0 ]
	aRows + [ "list of emoji, item present", [ "x", emo ], emo, 1 ]
	aRows + [ "list holding an empty text, empty item present", [ "", "a" ], "", 1 ]
	aRows + [ "list without an empty text, empty item absent", [ "a" ], "", 0 ]
	aRows + [ "empty list, any item", [], "a", 0 ]
	aRows + [ "list of lists holding the empty list", [ [] ], [], 1 ]

	nRows = len(aRows)
	nOkHold = 0
	nOkLack = 0
	nOkComp = 0
	nOkTagT = 0
	nOkTagF = 0
	cBad = ""
	for i = 1 to nRows
		oH = _(aRows[i][2])
		oH.Containing(aRows[i][3])
		nH = oH._
		oL = _(aRows[i][2])
		oL.ContainingNo(aRows[i][3])
		nL = oL._
		if nH = aRows[i][4]
			nOkHold++
		else
			cBad += " hold:" + aRows[i][1]
		ok
		if nL = 1 - aRows[i][4]
			nOkLack++
		else
			cBad += " lack:" + aRows[i][1]
		ok
		if nH + nL = 1
			nOkComp++
		else
			cBad += " comp:" + aRows[i][1]
		ok
		# the tag is read back through the public readers too
		if (nH = 1 and oH.ShouldReturnTRUE() = 1 and oH.ShouldReturnFALSE() = 0) or
		   (nH = 0 and oH.ShouldReturnTRUE() = 0 and oH.ShouldReturnFALSE() = 1)
			nOkTagT++
		else
			cBad += " tagH:" + aRows[i][1]
		ok
		if (nL = 1 and oL.ShouldReturnTRUE() = 1 and oL.ShouldReturnFALSE() = 0) or
		   (nL = 0 and oL.ShouldReturnTRUE() = 0 and oL.ShouldReturnFALSE() = 1)
			nOkTagF++
		else
			cBad += " tagL:" + aRows[i][1]
		ok
	next
	Then("the table has at least 20 pairs", nRows >= 20, 1)
	Then("Containing is right on every pair", nOkHold, nRows)
	Then("ContainingNo is right on every pair", nOkLack, nRows)
	Then("the two are exact complements on every pair", nOkComp, nRows)
	Then("the tag of Containing reads back through ShouldReturnTRUE / ShouldReturnFALSE on every pair", nOkTagT, nRows)
	Then("the tag of ContainingNo reads back the same way on every pair", nOkTagF, nRows)
	Then("no pair failed (names of the failing ones, if any)", cBad, "")
EndScenario()

Scenario("The tag: what the chain says after each step, and how it is read")
	Given("a text chain")
	oT1 = _("Ring")
	oT2 = oT1.Containing("in")
	Then("before any step the chain has no verdict and a close reads the value", _("Ring")._, "Ring")
	Then("a step returns the chain itself, so the sentence goes on", classname(oT2), "stzchainoftruth")
	Then("a true step stops the chain from continuing (a verdict was reached)", oT2.ShouldContinue(), 0)
	Then("a true step is read by the closing underscore", oT2._, 1)
	Then("... by ShouldReturnTRUE", oT2.ShouldReturnTRUE(), 1)
	Then("... and ShouldReturnFALSE says no", oT2.ShouldReturnFALSE(), 0)
	oT3 = _("Ring").Containing("xy")
	Then("a false step is read as 0", oT3._, 0)
	Then("... by ShouldReturnFALSE", oT3.ShouldReturnFALSE(), 1)
	Then("... and ShouldReturnTRUE says no", oT3.ShouldReturnTRUE(), 0)

	nA = _("Ring").Is(:String).Containing("in")._
	Then("a type question then a containment question: both hold", nA, 1)
	nB = _("Ring").Is(:Number).Containing("in")._
	Then("the type question fails, so the containment is not even asked", nB, 0)
	nC = _("Ring").Containing("zz").Containing("R")._
	Then("a chain tagged false stays false, whatever the next step would say", nC, 0)
	nD = _("Ring").Containing("R").Containing("g")._
	Then("two true steps in a row give true", nD, 1)
	nE = _("Ring").Containing("R").Containing("G")._
	Then("a true step then a false one gives false", nE, 0)
	nF = _("Ring").Containing("in").ContainingNo("xyz")._
	Then("Containing then ContainingNo, both true", nF, 1)
	nG = _("Ring").Containing("in").ContainingNo("n")._
	Then("Containing then ContainingNo that fails", nG, 0)
	nH = _("Ring").ContainingNo("zz").Where("NumberOfChars() = 4")._
	Then("a containment step then a Where step", nH, 1)
	nI = _("Ring").ContainingNo("zz").Where("NumberOfChars() = 5")._
	Then("... and the Where step can fail it", nI, 0)

	oT4 = _("Ring")
	cBefore = oT4.NeightherFunction()
	oT4.ContainingNo("x")
	cAfter = oT4.NeightherFunction()
	Then("ContainingNo is the function Nor will call: it records its name", cAfter, "containingno")
	Then("... which was empty before", cBefore, "")
	oT5 = _("Ring")
	oT5.Containing("R")
	Then("Containing records nothing for Nor", oT5.NeightherFunction(), "")
	oT6 = _("Ring")
	oT6.ContainingNo("xy")
	oT7 = oT6.Nor("zz")
	Then("Nor after ContainingNo asks ContainingNo again: absent part, true", oT7._, 1)
	oT8 = _("Ring")
	oT8.ContainingNo("xy")
	oT9 = oT8.Nor("R")
	Then("... present part, false", oT9._, 0)
EndScenario()

Scenario("The other spellings are the same calls (aliases), each on a case that holds and one that does not")
	Given("the text Ring and the list [ 1, 2 ]")
	Then("Contains, part present", _("Ring").Contains("in")._, 1)
	Then("Contains, part absent", _("Ring").Contains("xy")._, 0)
	Then("IsContaining, part present", _("Ring").IsContaining("in")._, 1)
	Then("IsContaining, part absent", _("Ring").IsContaining("xy")._, 0)
	Then("ContainsNo, part absent", _("Ring").ContainsNo("xy")._, 1)
	Then("ContainsNo, part present", _("Ring").ContainsNo("in")._, 0)
	Then("ContainsNeighther, part absent", _("Ring").ContainsNeighther("xy")._, 1)
	Then("ContainsNeighther, part present", _("Ring").ContainsNeighther("in")._, 0)
	Then("IsContainingNo, part absent", _("Ring").IsContainingNo("xy")._, 1)
	Then("IsContainingNo, part present", _("Ring").IsContainingNo("in")._, 0)
	Then("DoesNotContain, part absent", _("Ring").DoesNotContain("xy")._, 1)
	Then("DoesNotContain, part present", _("Ring").DoesNotContain("in")._, 0)
	Then("ContainingNeighther, part absent", _("Ring").ContainingNeighther("xy")._, 1)
	Then("ContainingNeighther, part present", _("Ring").ContainingNeighther("in")._, 0)
	Then("Contains on a list, item present", _([ 1, 2 ]).Contains(2)._, 1)
	Then("Contains on a list, item absent", _([ 1, 2 ]).Contains(3)._, 0)
	Then("DoesNotContain on a list, item absent", _([ 1, 2 ]).DoesNotContain(3)._, 1)
	Then("DoesNotContain on a list, item present", _([ 1, 2 ]).DoesNotContain(2)._, 0)
EndScenario()

Scenario("A value that holds nothing: a number or an object answers false to both questions")
	Given("a number chain and an object chain")
	Then("a number does not contain", _(12).Containing(1)._, 0)
	Then("... and does not lack either (it holds nothing, the chain is tagged false)", _(12).ContainingNo(1)._, 0)
	oObj = new CtDummy
	Then("an object does not contain", _(oObj).Containing("x")._, 0)
	Then("... and does not lack either", _(oObj).ContainingNo("x")._, 0)
	Then("a text still answers, so the false above is about the value, not the method", _("12").Containing("1")._, 1)
	Then("an object part is never held by a list", _([ 1, 2 ]).Containing(oObj)._, 0)
	Then("... so the list lacks it", _([ 1, 2 ]).ContainingNo(oObj)._, 1)
EndScenario()

Scenario("A value with code in it is data: nothing is run, nothing breaks out")
	Given("parts and values that look like code or carry quotes and braces")
	$ctSideEffect = 0
	cEvil = 'x") ; $ctSideEffect = 1 ; ("'
	cErrE = ""
	nE1 = -1
	nE2 = -1
	nE3 = -1
	nE4 = -1
	try
		nE1 = _("plain").Containing(cEvil)._
		nE2 = _("plain" + cEvil + "end").Containing(cEvil)._
		nE3 = _("plain").ContainingNo(cEvil)._
		nE4 = _([ cEvil, "b" ]).Containing(cEvil)._
	catch
		cErrE = cCatchError
	done
	Then("no part, however quoted, raises", cErrE, "")
	Then("a text that lacks the code-looking part is false", nE1, 0)
	Then("a text that holds the code-looking part is true", nE2, 1)
	Then("... and the code-looking part is lacked by the plain text", nE3, 1)
	Then("a list holding the code-looking text holds it", nE4, 1)
	Then("and none of it ran", $ctSideEffect, 0)
	Then("a text holding braces and quotes is asked as plain data", _('a "b" { c }').Containing('"b" { c }')._, 1)
	Then("... and a part with a closing brace alone is found", _("{ x }").Containing("}")._, 1)
	Then("... and one that is absent is not", _("{ x }").Containing("]")._, 0)
EndScenario()

Scenario("Nth with a held number and a call: the 7th letter of HUSSEIN, and the rank limits")
	Given("chains holding a number, and a call written as text")
	oN1 = _(7).Nth('LetterOf("HUSSEIN")')
	Then("the answer is a new chain", classname(oN1), "stzchainoftruth")
	bS = CtSame(oN1.Value(), "N")
	Then("holding the 7th letter", bS, 1)
	bS = CtSame(oN1._, "N")
	Then("which the closing underscore reads (no verdict was given, so it reads the value)", bS, 1)
	bS = CtSame(oN1.getQ().Content(), "N")
	Then("and which is wrapped as a string object", bS, 1)
	Then("the rank 7 is not the 8th letter", CtSame(_(7).Nth('LetterOf("HUSSEIN")').Value(), "S"), 0)
	bS = CtSame(_(1).Nth('LetterOf("HUSSEIN")').Value(), "H")
	Then("the rank 1 gives H", bS, 1)
	bS = CtSame(_(2).Nth('LetterOf("HUSSEIN")').Value(), "U")
	Then("the rank 2 gives U", bS, 1)

	oN2 = _(8)
	oN3 = oN2.Nth('LetterOf("HUSSEIN")')
	Then("a rank past the end gives no item: the chain itself, tagged false", oN3._, 0)
	Then("... and it is the same chain, still holding 8", oN3.Value(), 8)
	Then("... tagged by the false reader", oN3.ShouldReturnFALSE(), 1)

	Then("rank 0 gives no item (the call on its own answers H for 0)", _(0).Nth('LetterOf("HUSSEIN")')._, 0)
	Then("a negative rank gives no item and does not reach the engine, where it would panic", _(-1).Nth('LetterOf("HUSSEIN")')._, 0)
	Then("a rank with a fraction gives no item", _(2.5).Nth('LetterOf("HUSSEIN")')._, 0)
	Then("a rank beyond a 32 bit count gives no item", _(3000000000).Nth('LetterOf("HUSSEIN")')._, 0)

	bS = CtSame(_(2).Nth('LetterOf("' + eAc + 'bc")').Value(), "b")
	Then("the 2nd letter of an accented text is the plain letter after it", bS, 1)
	bS = CtSame(_(1).Nth('LetterOf("' + eAc + 'bc")').Value(), eAc)
	Then("the 1st letter is the whole accented letter, 2 bytes", bS, 1)
	nLen = len(_(1).Nth('LetterOf("' + eAc + 'bc")').Value())
	Then("... which is 2 bytes long, not cut", nLen, 2)

	cCallErr = ""
	try
		oBad = _(7).Nth("nocall")
	catch
		cCallErr = cCatchError
	done
	Then("a text that is not a call raises a message that says what Nth expects", StzFindFirst("Nth expects a call", cCallErr) > 0, 1)
	cCallErr2 = ""
	try
		oBad2 = _(7).Nth('NoSuchThing("x")')
	catch
		cCallErr2 = cCatchError
	done
	Then("a call that cannot run raises a message that names it", StzFindFirst("NoSuchThing", cCallErr2) > 0, 1)
EndScenario()

Scenario("Nth with a held text or list: the nth letter or item")
	Given("chains holding a text, a list, a number and an object")
	bS = CtSame(_("HUSSEIN").Nth(7).Value(), "N")
	Then("the 7th letter of the text", bS, 1)
	bS = CtSame(_("HUSSEIN").Nth(7)._, "N")
	Then("read by the closing underscore too", bS, 1)
	bS = CtSame(_("HUSSEIN").Nth(1).Value(), "H")
	Then("the 1st letter", bS, 1)
	bS = CtSame(_("HUSSEIN").Nth(1).Value(), "U")
	Then("... is not the 2nd", bS, 0)
	Then("past the end gives no item", _("HUSSEIN").Nth(8)._, 0)
	Then("rank 0 gives no item", _("HUSSEIN").Nth(0)._, 0)
	Then("a negative rank gives no item", _("HUSSEIN").Nth(-3)._, 0)
	Then("a rank with a fraction gives no item", _("HUSSEIN").Nth(1.5)._, 0)
	Then("a text asked with a text gives no item (it is not a rank)", _("HUSSEIN").Nth("7")._, 0)
	Then("the empty text has no 1st letter", _("").Nth(1)._, 0)

	cAcc = eAc + "bc"
	bS = CtSame(_(cAcc).Nth(1).Value(), eAc)
	Then("the 1st letter of an accented text is the whole accented letter", bS, 1)
	bS = CtSame(_(cAcc).Nth(2).Value(), "b")
	Then("the 2nd is the plain letter", bS, 1)
	bS = CtSame(_(cAcc).Nth(2).Value(), StzMid(cAcc, 2, 1))
	Then("... as StzMid says", bS, 1)
	bS = CtSame(_(cAcc).Nth(1).Value(), StzMid(cAcc, 1, 1))
	Then("... and for the 1st too", bS, 1)
	Then("an accented text of 3 letters has no 4th", _(cAcc).Nth(4)._, 0)
	cHeb = alef + "b" + emo + gimel
	bS = CtSame(_(cHeb).Nth(1).Value(), alef)
	Then("Hebrew: the 1st letter", bS, 1)
	bS = CtSame(_(cHeb).Nth(3).Value(), emo)
	Then("emoji: the 3rd is the whole 4 byte character", bS, 1)
	bS = CtSame(_(cHeb).Nth(4).Value(), gimel)
	Then("... and the letter after it is intact", bS, 1)
	Then("... and there is no 5th", _(cHeb).Nth(5)._, 0)

	Then("a list gives its nth item (a number)", _([ 10, 20, 30 ]).Nth(2).Value(), 20)
	Then("a list gives its nth item (read by the underscore)", _([ 10, 20, 30 ]).Nth(3)._, 30)
	bS = CtSame(_([ "a", "b", "c" ]).Nth(1).Value(), "a")
	Then("a list gives its nth item (a text)", bS, 1)
	aItem = _([ "a", "b", [ 1, 2 ] ]).Nth(3).Value()
	Then("a list gives its nth item (a list)", len(aItem), 2)
	Then("... whole", aItem[2], 2)
	Then("past the end of a list gives no item", _([ 1, 2 ]).Nth(3)._, 0)
	Then("rank 0 on a list gives no item", _([ 1, 2 ]).Nth(0)._, 0)
	Then("a negative rank on a list gives no item", _([ 1, 2 ]).Nth(-1)._, 0)
	Then("the empty list has no 1st item", _([]).Nth(1)._, 0)

	Then("an object has no nth item", _(new CtDummy).Nth(1)._, 0)
	Then("a number asked with a number has no nth item (it needs a call)", _(7).Nth(1)._, 0)
EndScenario()

Scenario("The ordinal forms st, nd, rd, th go through Nth")
	Given("the alphabet and numbers ending in 1, 2, 3 and 4 to 9")
	cAbc = 'LetterOf("ABCDEFGHIJKLMNOPQRSTUVWXYZ")'
	bS = CtSame(_(21).st(cAbc).Value(), "U")
	Then("21 st gives the 21st letter", bS, 1)
	bS = CtSame(_(22).nd(cAbc).Value(), "V")
	Then("22 nd gives the 22nd", bS, 1)
	bS = CtSame(_(23).rd(cAbc).Value(), "W")
	Then("23 rd gives the 23rd", bS, 1)
	bS = CtSame(_(24).th(cAbc).Value(), "X")
	Then("24 th gives the 24th", bS, 1)
	bS = CtSame(_(7).th('LetterOf("HUSSEIN")').Value(), "N")
	Then("7 th gives the 7th letter of HUSSEIN", bS, 1)
	Then("21 st on HUSSEIN has no item: the chain, tagged false", _(21).st('LetterOf("HUSSEIN")')._, 0)
	Then("a number that does not end in 1 gives an empty text from st", CtIsEmptyText(_(22).st(cAbc)), 1)
	Then("... and from nd", CtIsEmptyText(_(21).nd(cAbc)), 1)
	Then("... and from rd", CtIsEmptyText(_(21).rd(cAbc)), 1)
	Then("a text value gives an empty text from st", CtIsEmptyText(_("ring").st(cAbc)), 1)
	Then("a number ending in 1 gives an empty text from th", CtIsEmptyText(_(21).th(cAbc)), 1)
	bS = CtSame(CtLetterOf(_(10).th(cAbc)), "J")
	Then("10 th gives the 10th letter (it gave an empty text before, a known limit that is lifted)", bS, 1)
	Then("... and 10 gives an empty text from st, nd and rd", CtIsEmptyText(_(10).st(cAbc)) + CtIsEmptyText(_(10).nd(cAbc)) + CtIsEmptyText(_(10).rd(cAbc)), 3)
EndScenario()

Scenario("The ordinal forms follow the English rule: 11, 12 and 13 take th, and so do 111, 112 and 113")
	Given("the alphabet, and the teens, which the last digit alone used to get wrong")
	cAbc = 'LetterOf("ABCDEFGHIJKLMNOPQRSTUVWXYZ")'
	bS = CtSame(CtLetterOf(_(11).th(cAbc)), "K")
	Then("11 th gives the 11th letter (11st before)", bS, 1)
	bS = CtSame(CtLetterOf(_(12).th(cAbc)), "L")
	Then("12 th gives the 12th letter (12nd before)", bS, 1)
	bS = CtSame(CtLetterOf(_(13).th(cAbc)), "M")
	Then("13 th gives the 13th letter (13rd before)", bS, 1)
	Then("11 gives an empty text from st", CtIsEmptyText(_(11).st(cAbc)), 1)
	Then("12 gives an empty text from nd", CtIsEmptyText(_(12).nd(cAbc)), 1)
	Then("13 gives an empty text from rd", CtIsEmptyText(_(13).rd(cAbc)), 1)
	Given("the numbers just beside the teens, which keep their own word")
	bS = CtSame(CtLetterOf(_(1).st(cAbc)), "A")
	Then("1 st gives the 1st letter", bS, 1)
	bS = CtSame(CtLetterOf(_(2).nd(cAbc)), "B")
	Then("2 nd gives the 2nd letter", bS, 1)
	bS = CtSame(CtLetterOf(_(3).rd(cAbc)), "C")
	Then("3 rd gives the 3rd letter", bS, 1)
	bS = CtSame(CtLetterOf(_(14).th(cAbc)), "N")
	Then("14 th gives the 14th letter", bS, 1)
	bS = CtSame(CtLetterOf(_(20).th(cAbc)), "T")
	Then("20 th gives the 20th letter (an empty text before)", bS, 1)
	bS = CtSame(CtLetterOf(_(21).st(cAbc)), "U")
	Then("21 st still gives the 21st letter", bS, 1)
	Then("2 gives an empty text from th (it gave the 2nd letter before)", CtIsEmptyText(_(2).th(cAbc)), 1)
	Then("3 gives an empty text from th (it gave the 3rd letter before)", CtIsEmptyText(_(3).th(cAbc)), 1)
	Then("1 gives an empty text from th", CtIsEmptyText(_(1).th(cAbc)), 1)
	Then("0 gives an empty text from st", CtIsEmptyText(_(0).st(cAbc)), 1)
	Then("0 takes th, and the nth-item step finds no 0th item: the chain, tagged false", CtTagOf(_(0).th(cAbc)), 0)
	Then("a number takes th, so 0 gives not an empty text from th", CtIsEmptyText(_(0).th(cAbc)), 0)
	Given("a fraction and a negative number, which have no ordinal")
	Then("2.5 gives an empty text from nd", CtIsEmptyText(_(2.5).nd(cAbc)), 1)
	Then("2.5 takes th, and finds no item: the chain, tagged false", CtTagOf(_(2.5).th(cAbc)), 0)
	Then("-1 gives an empty text from st", CtIsEmptyText(_(-1).st(cAbc)), 1)
	Then("-1 takes th, and finds no item: the chain, tagged false", CtTagOf(_(-1).th(cAbc)), 0)
	Then("a text gives an empty text from th", CtIsEmptyText(_("ring").th(cAbc)), 1)
	Then("a list gives an empty text from rd", CtIsEmptyText(_([ 1, 2 ]).rd(cAbc)), 1)
EndScenario()

Scenario("The ordinal table: for 31 numbers exactly one of st, nd, rd and th answers, and it is the English one")
	Given("a table of numbers, each with the word written by hand")
	aTable = [
		[ 0, "th" ], [ 1, "st" ], [ 2, "nd" ], [ 3, "rd" ], [ 4, "th" ], [ 9, "th" ], [ 10, "th" ],
		[ 11, "th" ], [ 12, "th" ], [ 13, "th" ], [ 14, "th" ], [ 20, "th" ], [ 21, "st" ], [ 22, "nd" ],
		[ 23, "rd" ], [ 24, "th" ], [ 100, "th" ], [ 101, "st" ], [ 102, "nd" ], [ 103, "rd" ], [ 104, "th" ],
		[ 111, "th" ], [ 112, "th" ], [ 113, "th" ], [ 121, "st" ], [ 122, "nd" ], [ 123, "rd" ],
		[ 1000, "th" ], [ 1011, "th" ], [ 1012, "th" ], [ 1013, "th" ]
	]
	nRows = len(aTable)
	Then("the table holds 31 numbers", nRows, 31)
	for iRow = 1 to nRows
		cGot = CtWordsOf(aTable[iRow][1])
		Then("the number " + aTable[iRow][1] + " answers to " + aTable[iRow][2] + " and to nothing else", cGot, aTable[iRow][2])
	next
	Given("the same numbers, each asked for the three words it does not take")
	nWrong = 0
	for iRow = 1 to nRows
		cGot = CtWordsOf(aTable[iRow][1])
		if strcmp(cGot, aTable[iRow][2]) != 0
			nWrong++
		ok
	next
	Then("no number answers to a second word, or to none", nWrong, 0)
	Then("the English rule on a bigger number: 1000001 takes st", CtWordsOf(1000001), "st")
	Then("... 1000011 takes th", CtWordsOf(1000011), "th")
	Then("... 3000000012 takes th", CtWordsOf(3000000012), "th")
	Then("... 3000000022 takes nd", CtWordsOf(3000000022), "nd")
EndScenario()

Scenario("The function-call form of Is no longer dies on the name _ (R13)")
	Given("the call 'LetterOf(...)' asked of a one letter text")
	cErrI = ""
	try
		nI = _("H").Is('LetterOf("HUSSEIN")')._
	catch
		cErrI = cCatchError
	done
	Then("it raises, but no longer R13 Object is required", StzFindFirst("R13", cErrI), 0)
	Then("... it reaches the string object and stops there: stzString has no IsLetterOf (not this class's to add)", StzFindFirst("isletterof", cErrI) > 0, 1)
	nOk = _("H").Is(:Letter)._
	Then("the word form is untouched and still true", nOk, 1)
	nNo = _("5").Is(:Letter)._
	Then("... and false when it should be", nNo, 0)
EndScenario()

Summary()

func CtSame a, b
	if isString(a) and isString(b) and strcmp(a, b) = 0
		return 1
	ok
	return 0

func CtWordsOf n
	cWAbc = 'LetterOf("ABCDEFGHIJKLMNOPQRSTUVWXYZ")'
	cWGot = ""
	oWA = _(n).st(cWAbc)
	if NOT CtIsEmptyText(oWA)
		cWGot += "st"
	ok
	oWB = _(n).nd(cWAbc)
	if NOT CtIsEmptyText(oWB)
		cWGot += "nd"
	ok
	oWC = _(n).rd(cWAbc)
	if NOT CtIsEmptyText(oWC)
		cWGot += "rd"
	ok
	oWD = _(n).th(cWAbc)
	if NOT CtIsEmptyText(oWD)
		cWGot += "th"
	ok
	return cWGot

func CtLetterOf x
	if isObject(x)
		return x.Value()
	ok
	return "(none)"

func CtTagOf x
	if isObject(x)
		return x._
	ok
	return "(none)"

func CtIsEmptyText x
	if isString(x) and len(x) = 0
		return 1
	ok
	return 0

class CtDummy
	name = "dummy"
