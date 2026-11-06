load "../../stzBase.ring"
load "../_narrated.ring"

# stzStringInserter -- the register's two rows (InsertAfterManyPositions, InsertBeforeManyPositions), kept as a guard.
# Run from inside test/string:
#     rnxc stzStringInserter_defects_narrated.ring
# It needs no DLL beyond the engine's string and list modules, no network and no file.
#
# THE HISTORY: the register said both verbs raised R13 "Object is required" for every valid list of numbers ([1,3,5] on
# banana, [2] on abc), and named as probable cause the line that sorted the positions with a call chained on
# new stzList(panPos). Under rnxc that line does NOT raise (the chain answers a usable list), so the R13 was a trait of
# the Ring 1.27 VM, which is retired; the sort is now made in two statements, which both VMs read the same way. What
# the rnxc run DID show is that the contract was nowhere written down, and that three inputs went wrong quietly:
#   a fraction as a position (2.5) CUT THE TEXT: banana after [2.5] answered ba-nan, the tail was lost
#   a position listed twice inserted twice (ban--ana), where stzList.InsertAfterManyPositions inserts once
#   the empty list of positions raised, so a caller whose search found nothing had to guard every call
#
# THE RULES the guard holds the two verbs to (InsertAfterManyPositions(frag, positions), InsertBeforeManyPositions):
#   every position refers to the text AS IT WAS before the call; the insertions are made from the last position to the
#     first so that none moves another, and the order of the list does not matter
#   a position listed twice (or three times) inserts ONCE
#   after: valid positions are 0 (the very start) to the number of characters (the very end);
#   before: valid positions are 1 to the number of characters plus one (the very end);
#   so "after p" and "before p + 1" are the same cut, for every p
#   a position outside the valid range is skipped without an error and the others still apply
#   positions count characters (Unicode code points), never bytes: Hebrew, Arabic and emoji are cut between letters
#   an empty fragment, or the empty list of positions, changes nothing
#   a list holding anything but whole numbers (a text, "2", a fraction, a list), a value that is not a list, and a
#     fragment that is not a text, raise "Incorrect param type!" and the text is left as it was
#   the list passed in is not changed
#   the Q forms do the same and answer the inserter, so calls chain
#   nothing else moves: InsertAfter, InsertBefore, InsertAfterSubString, InsertBeforeSubString, Content, NumberOfChars
#
# Texts are compared EXACTLY (SiSame, through str2hex): Ring's = on text ignores case. Expected texts are written by
# hand, and a second oracle (SiOracle) builds the answer slot by slot with no sorting and no insertion, so it shares no
# line with the library. Every positive carries a negative sibling. The console shows ASCII only.

$cSiGot = ""
$cSiR = ""
$oSi = ""
$aSiPos = []
$aSiSrc = []
$nSiI = 0
$nSiJ = 0
$nSiOk = 0
$nSiSeed = 17
$cSiHost = ""
$cSiOne = ""
$cSiTwo = ""
$cHeb = "שלום עולם"
$cArb = "شكرا"
$cEmo = "a😀b😀c"
$cComb = "e" + char(204) + char(129) + "x"

# ---------------------------------------------------------------------------------------------------------------
Scenario("1. the examples of the doc blocks")
try
	Given("an inserter over banana")
	$oSi = StzStringInserterQ("banana")
	$oSi.InsertAfterManyPositions("-", [ 1, 3, 5 ])
	Then("after 1, 3, 5 with - : b-an-an-a", SiSame($oSi.Content(), "b-an-an-a"), 1)
	$oSi = StzStringInserterQ("banana")
	$oSi.InsertBeforeManyPositions("-", [ 1, 3, 5 ])
	Then("before 1, 3, 5 with - : -ba-na-na", SiSame($oSi.Content(), "-ba-na-na"), 1)
	Then("abc after 2: ab-c", SiSame(SiAfter("abc", "-", [ 2 ]), "ab-c"), 1)
	Then("abc before 2: a-bc", SiSame(SiBefore("abc", "-", [ 2 ]), "a-bc"), 1)
	Then("NEGATIVE: the answer is not the text unchanged", SiSameQ(SiAfter("banana", "-", [ 1, 3, 5 ]), "banana"), 0)
	Then("NEGATIVE: after and before differ on the same positions", SiSameQ(SiAfter("banana", "-", [ 1, 3, 5 ]), SiBefore("banana", "-", [ 1, 3, 5 ])), 0)
	Then("the verbs raise nothing on a valid list", SiRaised('StzStringInserterQ("banana").InsertAfterManyPositions("-", [ 1, 3, 5 ])'), "")
	Then("...nor the Before verb", SiRaised('StzStringInserterQ("banana").InsertBeforeManyPositions("-", [ 1, 3, 5 ])'), "")
	Then("...nor a single position", SiRaised('StzStringInserterQ("abc").InsertAfterManyPositions("-", [ 2 ])'), "")
catch
	SiAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("2. positions refer to the original text, and the order of the list does not matter")
try
	Given("banana and the same positions in every order")
	$cSiOne = SiAfter("banana", "-", [ 1, 3, 5 ])
	Then("[1,3,5] and [5,3,1] give one text", SiSame(SiAfter("banana", "-", [ 5, 3, 1 ]), $cSiOne), 1)
	Then("...and [3,1,5]", SiSame(SiAfter("banana", "-", [ 3, 1, 5 ]), $cSiOne), 1)
	Then("...and [3,5,1]", SiSame(SiAfter("banana", "-", [ 3, 5, 1 ]), $cSiOne), 1)
	Then("...and [1,5,3]", SiSame(SiAfter("banana", "-", [ 1, 5, 3 ]), $cSiOne), 1)
	Then("...and [5,1,3]", SiSame(SiAfter("banana", "-", [ 5, 1, 3 ]), $cSiOne), 1)
	Then("the same for before", SiSame(SiBefore("banana", "-", [ 5, 1, 3 ]), SiBefore("banana", "-", [ 1, 3, 5 ])), 1)
	When("a fragment is longer than one character, which would shift later positions if they were read after the cut")
	Then("abc after [1,2] with --: a--b--c", SiSame(SiAfter("abc", "--", [ 1, 2 ]), "a--b--c"), 1)
	Then("banana after [2,4] with XYZ: baXYZnaXYZna", SiSame(SiAfter("banana", "XYZ", [ 2, 4 ]), "baXYZnaXYZna"), 1)
	Then("banana before [2,4] with XYZ: bXYZanXYZana", SiSame(SiBefore("banana", "XYZ", [ 2, 4 ]), "bXYZanXYZana"), 1)
	Then("the numbers are sorted as numbers, not as texts: 10 and 9 and 2 in a 15 letter text",
		SiSame(SiAfter("abcdefghijklmno", "-", [ 10, 9, 2 ]), "ab-cdefghi-j-klmno"), 1)
	Then("...and 100 is out of range, skipped", SiSame(SiAfter("abcdefghijklmno", "-", [ 100, 10, 9, 2 ]), "ab-cdefghi-j-klmno"), 1)
	Then("NEGATIVE: a text sort would have put 9 after 10: it is not what is answered", SiSameQ(SiAfter("abcdefghijklmno", "-", [ 10, 9, 2 ]), "ab-cdefghij-k-lmno"), 0)
catch
	SiAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("3. the valid range: after is 0 to the length, before is 1 to the length plus one")
try
	Given("banana, six characters")
	Then("after [0] puts the fragment at the very start: -banana", SiSame(SiAfter("banana", "-", [ 0 ]), "-banana"), 1)
	Then("after [6] puts it at the very end: banana-", SiSame(SiAfter("banana", "-", [ 6 ]), "banana-"), 1)
	Then("after [0,6]: -banana-", SiSame(SiAfter("banana", "-", [ 0, 6 ]), "-banana-"), 1)
	Then("after [7] is past the end: nothing changes", SiSame(SiAfter("banana", "-", [ 7 ]), "banana"), 1)
	Then("after [-1] is before the start: nothing changes", SiSame(SiAfter("banana", "-", [ -1 ]), "banana"), 1)
	Then("after [-1,2] skips the -1 and applies the 2: ba-nana", SiSame(SiAfter("banana", "-", [ -1, 2 ]), "ba-nana"), 1)
	Then("after [1,100] skips the 100: b-anana", SiSame(SiAfter("banana", "-", [ 1, 100 ]), "b-anana"), 1)
	Then("after [0,1,2,3,4,5,6] between every character and around: -b-a-n-a-n-a-", SiSame(SiAfter("banana", "-", [ 0, 1, 2, 3, 4, 5, 6 ]), "-b-a-n-a-n-a-"), 1)
	Then("before [1] puts the fragment at the very start: -banana", SiSame(SiBefore("banana", "-", [ 1 ]), "-banana"), 1)
	Then("before [7] puts it at the very end: banana-", SiSame(SiBefore("banana", "-", [ 7 ]), "banana-"), 1)
	Then("before [1,7]: -banana-", SiSame(SiBefore("banana", "-", [ 1, 7 ]), "-banana-"), 1)
	Then("before [8] is past the end plus one: nothing changes", SiSame(SiBefore("banana", "-", [ 8 ]), "banana"), 1)
	Then("before [0] is before the start: nothing changes", SiSame(SiBefore("banana", "-", [ 0 ]), "banana"), 1)
	Then("before [-3] too", SiSame(SiBefore("banana", "-", [ -3 ]), "banana"), 1)
	Then("before [0,2] skips the 0 and applies the 2: b-anana", SiSame(SiBefore("banana", "-", [ 0, 2 ]), "b-anana"), 1)
	Then("before [1,100] skips the 100: -banana", SiSame(SiBefore("banana", "-", [ 1, 100 ]), "-banana"), 1)
	Then("before [1..7]: -b-a-n-a-n-a-", SiSame(SiBefore("banana", "-", [ 1, 2, 3, 4, 5, 6, 7 ]), "-b-a-n-a-n-a-"), 1)
	Then("only out of range positions: the text is returned whole",
		SiSame(SiAfter("banana", "-", [ -5, 7, 99 ]), "banana"), 1)
	Then("...for before too", SiSame(SiBefore("banana", "-", [ -5, 0, 8, 99 ]), "banana"), 1)

	When("every p from -2 to 10 is tried alone on abc")
	$nSiOk = 0
	for $nSiI = -2 to 10
		if SiSameQ(SiAfter("abc", "-", [ $nSiI ]), SiBefore("abc", "-", [ $nSiI + 1 ]))
			$nSiOk++
		ok
	next
	Then("after p and before p+1 are the same cut for the thirteen values", $nSiOk, 13)
	$nSiOk = 0
	for $nSiI = 0 to 4
		if SiSameQ(SiAfter("abc", "-", [ $nSiI ]), "abc")
			$nSiOk++
		ok
	next
	Then("NEGATIVE: of the five positions 0 to 4 after, exactly four change the text (4 is past the end)", $nSiOk, 1)
catch
	SiAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("4. a position listed twice inserts once")
try
	Given("banana with repeated positions")
	Then("after [3,3]: ban-ana, one dash", SiSame(SiAfter("banana", "-", [ 3, 3 ]), "ban-ana"), 1)
	Then("after [3,3,3]: ban-ana", SiSame(SiAfter("banana", "-", [ 3, 3, 3 ]), "ban-ana"), 1)
	Then("before [3,3]: ba-nana", SiSame(SiBefore("banana", "-", [ 3, 3 ]), "ba-nana"), 1)
	Then("after [2,4,2,4,2]: ba-na-na", SiSame(SiAfter("banana", "-", [ 2, 4, 2, 4, 2 ]), "ba-na-na"), 1)
	Then("after [0,0]: -banana", SiSame(SiAfter("banana", "-", [ 0, 0 ]), "-banana"), 1)
	Then("after [6,6]: banana-", SiSame(SiAfter("banana", "-", [ 6, 6 ]), "banana-"), 1)
	Then("a position twice and out of range twice: skipped twice, nothing inserted", SiSame(SiAfter("banana", "-", [ 9, 9 ]), "banana"), 1)
	Then("a list with and without duplicates answers one text",
		SiSame(SiAfter("banana", "-", [ 1, 1, 3, 3, 5, 5 ]), SiAfter("banana", "-", [ 1, 3, 5 ])), 1)
	Then("...for before too", SiSame(SiBefore("banana", "-", [ 1, 1, 3, 3, 5, 5 ]), SiBefore("banana", "-", [ 1, 3, 5 ])), 1)
	Then("NEGATIVE: two dashes at one place is never the answer", SiSameQ(SiAfter("banana", "-", [ 3, 3 ]), "ban--ana"), 0)
	Then("3 and 3.0 are one position", SiSame(SiAfter("banana", "-", [ 3, 3.0 ]), "ban-ana"), 1)
catch
	SiAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("5. fragments: empty, longer, in another script")
try
	Given("abc and fragments of every kind")
	Then("an empty fragment changes nothing: abc", SiSame(SiAfter("abc", "", [ 1, 2 ]), "abc"), 1)
	Then("...for before", SiSame(SiBefore("abc", "", [ 1, 2 ]), "abc"), 1)
	Then("a fragment of three characters: a<<>>b<<>>c", SiSame(SiAfter("abc", "<<>>", [ 1, 2 ]), "a<<>>b<<>>c"), 1)
	Then("a fragment that is a space: a b c", SiSame(SiAfter("abc", " ", [ 1, 2 ]), "a b c"), 1)
	Then("a fragment that holds a digit: a1b1c", SiSame(SiAfter("abc", "1", [ 1, 2 ]), "a1b1c"), 1)
	Then("a Hebrew fragment in an ASCII text: aשלוםb", SiSame(SiAfter("ab", "שלום", [ 1 ]), "aשלוםb"), 1)
	Then("an emoji fragment: a😀b😀c", SiSame(SiAfter("abc", "😀", [ 1, 2 ]), "a😀b😀c"), 1)
	Then("an accented fragment: aéb", SiSame(SiAfter("ab", "é", [ 1 ]), "aéb"), 1)
	Then("a fragment equal to the text: abcabc", SiSame(SiAfter("abc", "abc", [ 3 ]), "abcabc"), 1)
	Then("the case of a fragment is kept: aXb", SiSame(SiAfter("ab", "X", [ 1 ]), "aXb"), 1)
	Then("NEGATIVE: ...and not folded to lower case", SiSameQ(SiAfter("ab", "X", [ 1 ]), "axb"), 0)
catch
	SiAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("6. positions count characters, not bytes: Hebrew, Arabic, emoji, a combining mark")
try
	Given("Hebrew, nine characters (a space among them) and seventeen bytes")
	Then("the text has nine characters", new stzString($cHeb).NumberOfChars(), 9)
	Then("...and seventeen bytes", len($cHeb), 17)
	Then("after [1,4,9]: ש!לום! עולם!", SiSame(SiAfter($cHeb, "!", [ 1, 4, 9 ]), "ש!לום! עולם!"), 1)
	Then("before [1,4,6]: !שלו!ם !עולם", SiSame(SiBefore($cHeb, "!", [ 1, 4, 6 ]), "!שלו!ם !עולם"), 1)
	Then("after [0,4]: -שלום- עולם", SiSame(SiAfter($cHeb, "-", [ 0, 4 ]), "-שלום- עולם"), 1)
	Then("after [5], behind the space: שלום -עולם", SiSame(SiAfter($cHeb, "-", [ 5 ]), "שלום -עולם"), 1)
	Then("before [10] is the end: שלום עולם-", SiSame(SiBefore($cHeb, "-", [ 10 ]), "שלום עולם-"), 1)
	Then("before [11] is past the end: nothing changes", SiSame(SiBefore($cHeb, "-", [ 11 ]), $cHeb), 1)
	Then("after [10] is past the end: nothing changes", SiSame(SiAfter($cHeb, "-", [ 10 ]), $cHeb), 1)
	Then("the answer has twelve characters and twenty bytes: no letter was cut in two",
		"" + new stzString(SiAfter($cHeb, "!", [ 1, 4, 9 ])).NumberOfChars() + "/" + len(SiAfter($cHeb, "!", [ 1, 4, 9 ])), "12/20")
	Then("NEGATIVE: the text a BYTE count would give (positions 9, 4, 1 read as bytes) is not what is answered", SiSameQ(SiAfter($cHeb, "!", [ 1, 4, 9 ]), SiByteCut($cHeb, "!", [ 9, 4, 1 ])), 0)
	Given("Arabic, four letters")
	Then("after every position: ش|ك|ر|ا|", SiSame(SiAfter($cArb, "|", [ 1, 2, 3, 4 ]), "ش|ك|ر|ا|"), 1)
	Then("before every position and the end: |ش|ك|ر|ا|", SiSame(SiBefore($cArb, "|", [ 1, 2, 3, 4, 5 ]), "|ش|ك|ر|ا|"), 1)
	Then("after [2]: شك|را", SiSame(SiAfter($cArb, "|", [ 2 ]), "شك|را"), 1)
	Given("a text with two emoji, five characters")
	Then("the text has five characters", new stzString($cEmo).NumberOfChars(), 5)
	Then("after every position: a-😀-b-😀-c-", SiSame(SiAfter($cEmo, "-", [ 1, 2, 3, 4, 5 ]), "a-😀-b-😀-c-"), 1)
	Then("before [2,4]: a-😀b-😀c", SiSame(SiBefore($cEmo, "-", [ 2, 4 ]), "a-😀b-😀c"), 1)
	Then("after [2]: a😀-b😀c", SiSame(SiAfter($cEmo, "-", [ 2 ]), "a😀-b😀c"), 1)
	Then("a position past the five characters is skipped though the bytes go to eleven: after [9]", SiSame(SiAfter($cEmo, "-", [ 9 ]), $cEmo), 1)
	Given("a letter and a combining accent, then x: three code points")
	Then("the text has three characters", new stzString($cComb).NumberOfChars(), 3)
	Then("after [1] separates the letter from its mark, as a code point count says",
		SiSame(SiAfter($cComb, "-", [ 1 ]), "e-" + char(204) + char(129) + "x"), 1)
	Then("after [2] goes behind the mark", SiSame(SiAfter($cComb, "-", [ 2 ]), "e" + char(204) + char(129) + "-x"), 1)
	Then("after [3] is the end", SiSame(SiAfter($cComb, "-", [ 3 ]), "e" + char(204) + char(129) + "x-"), 1)
	Given("a text of two-byte letters")
	Then("héllo after [2]: hé-llo", SiSame(SiAfter("héllo", "-", [ 2 ]), "hé-llo"), 1)
	Then("héllo before [2]: h-éllo", SiSame(SiBefore("héllo", "-", [ 2 ]), "h-éllo"), 1)
	Then("héllo after [1,2,3,4,5]: h-é-l-l-o-", SiSame(SiAfter("héllo", "-", [ 1, 2, 3, 4, 5 ]), "h-é-l-l-o-"), 1)
catch
	SiAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("7. the empty list, the empty text, a one character text")
try
	Given("the empty list of positions")
	Then("it raises nothing", SiRaised('StzStringInserterQ("abc").InsertAfterManyPositions("-", [])'), "")
	Then("...nor for before", SiRaised('StzStringInserterQ("abc").InsertBeforeManyPositions("-", [])'), "")
	Then("the text is unchanged: abc", SiSame(SiAfter("abc", "-", []), "abc"), 1)
	Then("...for before", SiSame(SiBefore("abc", "-", []), "abc"), 1)
	Then("the empty list on the empty text: the empty text", SiSame(SiAfter("", "-", []), ""), 1)
	Given("the empty text")
	Then("after [0] gives the fragment alone: -", SiSame(SiAfter("", "-", [ 0 ]), "-"), 1)
	Then("after [1] is past the end: the empty text", SiSame(SiAfter("", "-", [ 1 ]), ""), 1)
	Then("before [1] gives the fragment alone: -", SiSame(SiBefore("", "-", [ 1 ]), "-"), 1)
	Then("before [0] is out of range: the empty text", SiSame(SiBefore("", "-", [ 0 ]), ""), 1)
	Then("before [1,1] gives one fragment: -", SiSame(SiBefore("", "-", [ 1, 1 ]), "-"), 1)
	Given("a one character text")
	Then("after [0,1]: -a-", SiSame(SiAfter("a", "-", [ 0, 1 ]), "-a-"), 1)
	Then("before [1,2]: -a-", SiSame(SiBefore("a", "-", [ 1, 2 ]), "-a-"), 1)
	Then("after [1]: a-", SiSame(SiAfter("a", "-", [ 1 ]), "a-"), 1)
	Then("before [1]: -a", SiSame(SiBefore("a", "-", [ 1 ]), "-a"), 1)
catch
	SiAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("8. what is refused, and that the text is left as it was")
try
	Given("an inserter over banana and bad arguments in turn")
	$cSiOne = "Incorrect param type! panPos must be a list of whole numbers."
	Then("a fraction raises", SiRaisedMsg("banana", "-", [ 2.5 ], 1), $cSiOne)
	Then("...and the text is whole, no tail lost", SiSame(SiLeft(), "banana"), 1)
	Then("a number written as a text raises", SiRaisedMsg("banana", "-", [ "2" ], 1), $cSiOne)
	Then("a text raises", SiRaisedMsg("banana", "-", [ "a" ], 1), $cSiOne)
	Then("a list inside the list raises", SiRaisedMsg("banana", "-", [ [ 1 ] ], 1), $cSiOne)
	Then("an empty list inside the list raises", SiRaisedMsg("banana", "-", [ [] ], 1), $cSiOne)
	Then("one bad item among good ones raises", SiRaisedMsg("banana", "-", [ 1, 2, "x", 4 ], 1), $cSiOne)
	Then("...and nothing was inserted before the bad item was met", SiSame(SiLeft(), "banana"), 1)
	Then("a fraction late in the list raises too", SiRaisedMsg("banana", "-", [ 1, 2, 3.5 ], 1), $cSiOne)
	Then("...and nothing was inserted", SiSame(SiLeft(), "banana"), 1)
	Then("a number that is not a list raises", SiRaisedMsg("banana", "-", 2, 1), $cSiOne)
	Then("a text that is not a list raises", SiRaisedMsg("banana", "-", "2", 1), $cSiOne)
	Then("a fragment that is a number raises", SiRaisedMsg("banana", 5, [ 1 ], 1), "Incorrect param type! pcSubStr must be a string.")
	Then("a fragment that is a list raises", SiRaisedMsg("banana", [ "-" ], [ 1 ], 1), "Incorrect param type! pcSubStr must be a string.")
	Then("...and the text is whole", SiSame(SiLeft(), "banana"), 1)
	Then("the same for before: a fraction", SiRaisedMsg("banana", "-", [ 2.5 ], 0), $cSiOne)
	Then("...before: a text", SiRaisedMsg("banana", "-", [ "a" ], 0), $cSiOne)
	Then("...before: not a list", SiRaisedMsg("banana", "-", 2, 0), $cSiOne)
	Then("...before: a number as fragment", SiRaisedMsg("banana", 5, [ 1 ], 0), "Incorrect param type! pcSubStr must be a string.")
	Then("...and the text is whole", SiSame(SiLeft(), "banana"), 1)
	Then("NEGATIVE: a valid list is not refused", SiRaisedMsg("banana", "-", [ 1, 2 ], 1), "")
	Then("NEGATIVE: negative whole numbers are valid, only skipped", SiRaisedMsg("banana", "-", [ -1, -2 ], 1), "")
	Then("NEGATIVE: a very large whole number is valid, only skipped", SiRaisedMsg("banana", "-", [ 1000000 ], 1), "")
catch
	SiAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("9. the Q forms chain, the list passed in is left alone")
try
	Given("an inserter over abcd")
	$oSi = new stzStringInserter("abcd")
	$cSiOne = classname($oSi.InsertAfterManyPositionsQ("-", [ 1 ]))
	Then("InsertAfterManyPositionsQ answers the inserter", $cSiOne, "stzstringinserter")
	Then("...which holds the new text: a-bcd", SiSame($oSi.Content(), "a-bcd"), 1)
	$oSi = new stzStringInserter("abcd")
	$oSi.InsertAfterManyPositionsQ("-", [ 1 ]).InsertBeforeManyPositionsQ("+", [ 4 ])
	Then("two Q calls chained, the second reads the text the first left: a-b+cd", SiSame($oSi.Content(), "a-b+cd"), 1)
	$oSi = new stzStringInserter("abcd")
	$oSi.InsertBeforeManyPositionsQ("-", [ 2 ]).InsertAfterManyPositionsQ("+", [ 0 ])
	Then("the other order: +a-bcd", SiSame($oSi.Content(), "+a-bcd"), 1)
	$oSi = new stzStringInserter("abcd")
	$cSiOne = classname($oSi.InsertBeforeManyPositionsQ("-", [ 2 ]))
	Then("InsertBeforeManyPositionsQ answers the inserter", $cSiOne, "stzstringinserter")

	When("the list of positions is a variable, unsorted and with a duplicate")
	$aSiPos = [ 5, 1, 3, 3 ]
	$oSi = new stzStringInserter("banana")
	$oSi.InsertAfterManyPositions("-", $aSiPos)
	Then("the text is b-an-an-a", SiSame($oSi.Content(), "b-an-an-a"), 1)
	Then("the list is as it was: [5,1,3,3]", @@($aSiPos), "[ 5, 1, 3, 3 ]")
	$oSi.InsertBeforeManyPositions("+", $aSiPos)
	Then("it is still as it was after the second verb", @@($aSiPos), "[ 5, 1, 3, 3 ]")
	Then("a second verb reads its positions in the text as the first left it: +b-+an+-an-a", SiSame($oSi.Content(), "+b-+an+-an-a"), 1)
	Then("NEGATIVE: ...so the answer is not the first one", SiSameQ($oSi.Content(), "b-an-an-a"), 0)

	When("a second inserter over the same text is built")
	$cSiOne = StzStringInserterQ("banana").Content()
	Then("it does not see the first one", SiSame($cSiOne, "banana"), 1)
catch
	SiAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("10. a second author: the answer built slot by slot, over many lists")
try
	Given("a 40 character text and sixty lists of positions made by a small generator")
	$cSiHost = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMN"
	$nSiOk = 0
	$nSiJ = 0
	$nSiSeed = 17
	for $nSiI = 1 to 60
		$aSiPos = []
		$nSiK = 1 + ($nSiI % 9)
		for $nSiL = 1 to $nSiK
			$nSiSeed = ($nSiSeed * 75 + 74) % 65537
			$aSiPos + (($nSiSeed % 50) - 4)
		next
		$cSiOne = SiAfter($cSiHost, "<>", $aSiPos)
		$cSiTwo = SiOracle($cSiHost, "<>", $aSiPos, 1)
		if SiSameQ($cSiOne, $cSiTwo)  $nSiOk++  ok
		$cSiOne = SiBefore($cSiHost, "<>", $aSiPos)
		$cSiTwo = SiOracle($cSiHost, "<>", $aSiPos, 0)
		if SiSameQ($cSiOne, $cSiTwo)  $nSiJ++  ok
	next
	Then("sixty lists after: the library and the oracle agree", $nSiOk, 60)
	Then("sixty lists before: the library and the oracle agree", $nSiJ, 60)

	When("the positions are every number from -3 to 45")
	$aSiPos = []
	for $nSiI = -3 to 45
		$aSiPos + $nSiI
	next
	Then("after all of them: the oracle and the library agree", SiSame(SiAfter($cSiHost, "<>", $aSiPos), SiOracle($cSiHost, "<>", $aSiPos, 1)), 1)
	Then("before all of them: the oracle and the library agree", SiSame(SiBefore($cSiHost, "<>", $aSiPos), SiOracle($cSiHost, "<>", $aSiPos, 0)), 1)
	Then("the text is 40 characters plus 41 fragments of 2: 122", len(SiAfter($cSiHost, "<>", $aSiPos)), 122)

	When("two hundred positions on a two hundred character text")
	$cSiHost = copy("0123456789", 20)
	$aSiPos = []
	for $nSiI = 200 to 1 step -1
		$aSiPos + $nSiI
	next
	$cSiOne = SiAfter($cSiHost, "-", $aSiPos)
	Then("the answer has 400 characters", len($cSiOne), 400)
	Then("and is what the oracle builds", SiSame($cSiOne, SiOracle($cSiHost, "-", $aSiPos, 1)), 1)
catch
	SiAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("11. nothing else moved: the single-position and fragment verbs, and the readers")
try
	Given("an inserter over banana")
	$oSi = new stzStringInserter("banana")
	$oSi.InsertAfter(3, "-")
	Then("InsertAfter(3): ban-ana", SiSame($oSi.Content(), "ban-ana"), 1)
	$oSi = new stzStringInserter("banana")
	$oSi.InsertBefore(4, "-")
	Then("InsertBefore(4): ban-ana", SiSame($oSi.Content(), "ban-ana"), 1)
	$oSi = new stzStringInserter("banana")
	$oSi.InsertAfter(0, "-")
	Then("InsertAfter(0): -banana", SiSame($oSi.Content(), "-banana"), 1)
	$oSi = new stzStringInserter("banana")
	$oSi.InsertAfter(7, "-")
	Then("InsertAfter(7), past the end: nothing changes", SiSame($oSi.Content(), "banana"), 1)
	$oSi = new stzStringInserter("banana")
	$oSi.InsertBefore(0, "-")
	Then("InsertBefore(0): nothing changes", SiSame($oSi.Content(), "banana"), 1)
	$oSi = new stzStringInserter("banana")
	$oSi.InsertAfterSubString("an", "-")
	Then("InsertAfterSubString(an, -): ban-an-a", SiSame($oSi.Content(), "ban-an-a"), 1)
	$oSi = new stzStringInserter("banana")
	$oSi.InsertBeforeSubString("an", "_")
	Then("InsertBeforeSubString(an, _): b_an_ana", SiSame($oSi.Content(), "b_an_ana"), 1)
	$oSi = new stzStringInserter("banana")
	$oSi.InsertAfterFirst("an", "-")
	Then("InsertAfterFirst(an, -): ban-ana", SiSame($oSi.Content(), "ban-ana"), 1)
	$oSi = new stzStringInserter("banana")
	$oSi.InsertBeforeLast("an", "-")
	Then("InsertBeforeLast(an, -): ban-ana", SiSame($oSi.Content(), "ban-ana"), 1)
	Then("InsertedAfterFirst answers the text and leaves the inserter alone",
		SiSame(new stzStringInserter("banana").InsertedAfterFirst("an", "-"), "ban-ana"), 1)
	$oSi = new stzStringInserter("a😀b")
	Then("InsertedAfterFirst on emoji: a😀-b", SiSame($oSi.InsertedAfterFirst("😀", "-"), "a😀-b"), 1)
	Then("...and the inserter is as it was: a😀b", SiSame($oSi.Content(), "a😀b"), 1)
	$oSi = new stzStringInserter("שלום עולם")
	$oSi.InsertBefore(6, "!")
	Then("the class example, Hebrew InsertBefore(6): שלום !עולם", SiSame($oSi.Content(), "שלום !עולם"), 1)
	Then("NumberOfChars counts characters: 10", $oSi.NumberOfChars(), 10)
	Then("IsEmpty is false", $oSi.IsEmpty(), 0)
	Then("IsEmpty is true over the empty text", new stzStringInserter("").IsEmpty(), 1)
	Then("NumberOfChars of the empty text is 0", new stzStringInserter("").NumberOfChars(), 0)
	Then("an inserter over a number is refused",
		SiRaised('new stzStringInserter(5)'), "Can't create stzStringInserter! Parameter must be a string or stzString object.")
	$oSi = new stzString("banana")
	$oSi.InsertAfterPosition(3, "-")
	Then("stzString.InsertAfterPosition, which builds an inserter over itself: ban-ana", SiSame($oSi.Content(), "ban-ana"), 1)
	$oSi = new stzString("banana")
	$oSi.InsertAfterSubString("an", "-")
	Then("stzString.InsertAfterSubString: ban-an-a", SiSame($oSi.Content(), "ban-an-a"), 1)
catch
	SiAbort()
done
EndScenario()

Summary()

# ---------------------------------------------------------------------------------------------------------------
# helpers: every name a function reads is a $global (Rule A)

# an EXACT, case-sensitive comparison of two texts through their hex: Ring's = on text ignores case
func SiSame(a, b)
	if SiSameQ(a, b) = 1  return 1  ok
	? "      (exact compare failed)  got hex [" + str2hex(a) + "]  wanted hex [" + str2hex(b) + "]"
	return 0

# the same, quietly: for the negative siblings, which are expected to differ
func SiSameQ(a, b)
	if isString(a) and isString(b)
		if str2hex(a) = str2hex(b)  return 1  ok
	ok
	return 0

# the text after the after-verb on a fresh inserter, or the text RAISED: and the message when it raised
func SiAfter(cHost, cFrag, aPos)
	$oSi2 = new stzStringInserter(cHost)
	try
		$oSi2.InsertAfterManyPositions(cFrag, aPos)
	catch
		return "RAISED: " + trim(cCatchError)
	done
	return $oSi2.Content()

func SiBefore(cHost, cFrag, aPos)
	$oSi2 = new stzStringInserter(cHost)
	try
		$oSi2.InsertBeforeManyPositions(cFrag, aPos)
	catch
		return "RAISED: " + trim(cCatchError)
	done
	return $oSi2.Content()

# the error message of one verb call ("" when it raises nothing); the inserter is kept for SiLeft
func SiRaisedMsg(cHost, cFrag, aPos, bAfter)
	$oSiKept = new stzStringInserter(cHost)
	$cSiMsg = ""
	try
		if bAfter = 1
			$oSiKept.InsertAfterManyPositions(cFrag, aPos)
		else
			$oSiKept.InsertBeforeManyPositions(cFrag, aPos)
		ok
	catch
		$cSiMsg = trim(cCatchError)
	done
	return $cSiMsg

func SiLeft()
	return $oSiKept.Content()

# the text of the error a statement raises, "" when it raises nothing
func SiRaised(cCode)
	$cSiR = ""
	try
		eval("$oSi3 = " + cCode)
	catch
		$cSiR = trim(cCatchError)
	done
	return $cSiR

# the answer slot by slot: gap k is behind character k (0 to the length); an "after" position k and a "before"
# position k + 1 name the same gap. No sort, no insertion at a position: it shares no line with the library.
func SiOracle(cHost, cFrag, aPos, bAfter)
	nLen = len(cHost)
	cOut = ""
	for k = 0 to nLen
		if bAfter = 1
			nWant = k
		else
			nWant = k + 1
		ok
		if SiHas(aPos, nWant) = 1
			cOut += cFrag
		ok
		if k < nLen
			cOut += cHost[k + 1]
		ok
	next
	return cOut

# the text a byte-oriented insertion would give, positions in the order given (last first)
func SiByteCut(cHost, cFrag, aPos)
	cOut = cHost
	nCount = len(aPos)
	for j = 1 to nCount
		cOut = left(cOut, aPos[j]) + cFrag + right(cOut, len(cOut) - aPos[j])
	next
	return cOut

func SiHas(aList, nValue)
	nCount = len(aList)
	for j = 1 to nCount
		if aList[j] = nValue
			return 1
		ok
	next
	return 0

func SiAbort()
	? "  ABORTED by an uncaught error: " + cCatchError
	$_zst_fail++
	$_zst_total++
