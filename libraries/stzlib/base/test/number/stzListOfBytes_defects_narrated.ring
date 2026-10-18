load "../../stzBase.ring"
load "../_narrated.ring"

# stzListOfBytes -- the six rows of the register (DEFECTS.md) and the neighbours they touched.
#
# Before: BytesOfThisChar had no body (it answered an empty text for every character),
# FillWithAsciiCharUpToNChars raised R21 (it multiplied by a list of pairs), ToUTF8 raised R14 (it
# forwarded to a stzString method that does not exist), Stripped had no body, Bits and ToStzListOfBits
# are placeholders waiting for a list of bits class that does not exist, and FillWithAsciiChar raised
# an error whose message was blank. Run from inside test/number.
#
# The class is also reachable as stzBytes (same class, declared in the same file). Accented, Hebrew and
# emoji texts are built from char codes and never printed; a list of bytes is compared as its codes.

cLbE = char(195) + char(169)                                   # e acute, 2 bytes
cLbH = char(215) + char(144)                                   # alef, 2 bytes
cLbJ = char(240) + char(159) + char(152) + char(128)           # grinning face, 4 bytes
cLbN = char(194) + char(160)                                   # no-break space, 2 bytes

Scenario("BytesOfThisChar answers what BytesOfChar answers")
	o = new stzListOfBytes("abc")
	Then("the bytes of b in abc", LbCodes(o.BytesOfThisChar("b")), "98")
	Then("BytesOfChar gives the same", LbCodes(o.BytesOfChar("b")), "98")
	Then("a character absent from the content has no bytes", LbCodes(o.BytesOfThisChar("z")), "")
	Then("the answer is a list, not an empty text", isList(o.BytesOfThisChar("b")), 1)
	Then("the absent answer is a list too (it was an empty text for every character)",
		isList(o.BytesOfThisChar("z")), 1)
	oe = new stzListOfBytes("h" + cLbE + "llo")
	Then("e acute is two bytes", LbCodes(oe.BytesOfThisChar(cLbE)), "195,169")
	Then("and BytesOfChar agrees", LbCodes(oe.BytesOfChar(cLbE)), "195,169")
	Then("a plain letter beside it is one byte", LbCodes(oe.BytesOfThisChar("l")), "108")
	oh = new stzListOfBytes("a" + cLbH + "b")
	Then("a Hebrew letter is two bytes", LbCodes(oh.BytesOfThisChar(cLbH)), "215,144")
	oj = new stzListOfBytes("x" + cLbJ + "y")
	Then("an emoji is four bytes", LbCodes(oj.BytesOfThisChar(cLbJ)), "240,159,152,128")
	Then("the emoji is not found in a list of only ASCII", LbCodes(o.BytesOfThisChar(cLbJ)), "")
	Then("e acute is not found in the Hebrew text", LbCodes(oh.BytesOfThisChar(cLbE)), "")
	oz = new stzListOfBytes("")
	Then("an empty list holds no character", LbCodes(oz.BytesOfThisChar("a")), "")
	Then("the content is untouched", o.ToString(), "abc")
	Then("a text of two characters is refused", LbBytesOfThisChar(o, "ab"), "RAISED")
	Then("a number is refused", LbBytesOfThisChar(o, 5), "RAISED")
	Then("an empty text is refused", LbBytesOfThisChar(o, ""), "RAISED")
	Then("a good character is not refused", LbBytesOfThisChar(o, "a"), "97")
EndScenario()

Scenario("FillWithAsciiCharUpToNChars repeats an ASCII character")
	o = new stzListOfBytes("abc")
	o.FillWithAsciiCharUpToNChars("x", 2)
	Then("abc filled with x up to 2 chars (it raised R21)", o.ToString(), "xx")
	Then("two bytes", o.NumberOfBytes(), 2)
	o = new stzListOfBytes("abcd")
	o.FillWithAsciiCharUpToNChars("y", 3)
	Then("abcd filled with y up to 3 chars", o.ToString(), "yyy")
	Then("three bytes", o.NumberOfBytes(), 3)
	Then("growing past the old size works too", LbFillChars("ab", "z", 6), "zzzzzz")
	Then("a bigger content is replaced, not extended", LbFillChars("abcdefgh", "q", 1), "q")
	Then("the sibling counting bytes gives the same for ASCII", LbFillBytes("abcd", "y", 3), "yyy")
	Then("the digit 0 is a character like another", LbFillChars("a", "0", 3), "000")
	Then("a space is a character like another", LbFillChars("a", " ", 3), "   ")
	Then("zero chars empties the content", LbFillChars("abc", "x", 0), "")
	Then("a negative count empties the content", LbFillChars("abc", "x", -2), "")
	Then("an empty list can be filled", LbFillChars("", "k", 4), "kkkk")
	oe = new stzListOfBytes("a" + cLbE + cLbH + cLbJ)
	oe.FillWithAsciiCharUpToNChars("m", 4)
	Then("multibyte content is replaced by 4 one-byte chars", oe.ToString(), "mmmm")
	Then("so its size in bytes is 4, not the old 9", oe.NumberOfBytes(), 4)
	Then("and every char takes one byte", LbPerChar(oe), "1,1,1,1")
	o = new stzListOfBytes("abc")
	Then("e acute is not an ASCII character", LbFillRaises(o, cLbE, 2), "RAISED")
	Then("and the content stays abc", o.ToString(), "abc")
	Then("an emoji is not an ASCII character", LbFillRaises(o, cLbJ, 2), "RAISED")
	Then("two characters are refused", LbFillRaises(o, "ab", 2), "RAISED")
	Then("an empty text is refused", LbFillRaises(o, "", 2), "RAISED")
	Then("a count that is not a number is refused", LbFillRaises(o, "x", "two"), "RAISED")
	Then("the content is still abc after every refusal", o.ToString(), "abc")
	Then("a good call is not refused", LbFillRaises(o, "x", 2), "")
	Then("and it filled", o.ToString(), "xx")
EndScenario()

Scenario("FillWithAsciiChar refuses a non-ASCII character with a message")
	o = new stzListOfBytes("abc")
	Then("an ASCII character fills the same size", o.FillWithAsciiChar("z"), "zzz")
	cMsg = LbFillAsciiMessage(o, cLbE)
	Then("the message of the refusal is not blank (it was a heading with no reason)", len(cMsg) > 20, 1)
	Then("it says the character is not ASCII", StzFindFirst("ASCII", cMsg) > 0, 1)
	Then("the content is kept", o.ToString(), "zzz")
EndScenario()

Scenario("ToUTF8 answers the bytes as the UTF-8 text they spell")
	Then("ASCII text (it raised R14)", LbToUtf8("abc"), "abc")
	Then("e acute stays whole", LbCodes2(LbToUtf8(cLbE)), "195,169")
	Then("a word with e acute", LbToUtf8("caf" + cLbE), "caf" + cLbE)
	Then("Hebrew stays whole", LbCodes2(LbToUtf8(cLbH + cLbH)), "215,144,215,144")
	Then("an emoji stays four bytes", LbCodes2(LbToUtf8("x" + cLbJ)), "120,240,159,152,128")
	Then("an empty list answers an empty text", LbToUtf8(""), "")
	Then("the answer is a text", isString(LbToUtf8("abc")), 1)
	o = new stzListOfBytes("a" + cLbE + cLbJ)
	Then("it is the same as ToString", strcmp(o.ToUTF8(), o.ToString()), 0)
	Then("its size in bytes is the size of the list", len(o.ToUTF8()), o.NumberOfBytes())
	Then("its size is 7 here: 1 + 2 + 4", len(o.ToUTF8()), 7)
	Then("it is not the hexadecimal form", strcmp(o.ToUTF8(), o.ToHexUTF8()) != 0, 1)
	Then("the object is not changed", LbCodes(o.Bytecodes()), "97,195,169,240,159,152,128")
	ob = new stzBytes("hi")
	Then("the same through the stzBytes name", ob.ToUTF8(), "hi")
EndScenario()

Scenario("Bits and ToStzListOfBits are placeholders until a list of bits class exists")
	o = new stzListOfBytes("abc")
	Then("Bits does not raise and answers an empty text", LbBits(o), "")
	Then("ToStzListOfBits does not raise and answers an empty text", LbBitsObject(o), "")
	Then("the content is untouched by either", o.ToString(), "abc")
	Then("the byte values are still there for the bits to be made from", LbCodes(o.Bytecodes()), "97,98,99")
	Then("no list of bits class is defined in the library", LbClassExists("stzListOfBits"), 0)
	Then("the byte class is defined", LbClassExists("stzListOfBytes"), 1)
EndScenario()

Scenario("Stripped answers what Trimmed answers")
	Then("the spaces at both ends of  ab c  go (it answered an empty text)", LbStripped("  ab c  "), "ab c")
	Then("Trimmed agrees", LbTrimmed("  ab c  "), "ab c")
	Then("a trailing space of x goes", LbStripped("x "), "x")
	Then("a leading space goes", LbStripped(" x"), "x")
	Then("spaces inside stay", LbStripped(" a  b "), "a  b")
	Then("nothing to strip is nothing changed", LbStripped("ab"), "ab")
	Then("only spaces leaves an empty text", LbStripped("    "), "")
	Then("an empty list answers an empty text", LbStripped(""), "")
	Then("Trimmed on only spaces is empty too", LbTrimmed("    "), "")
	Then("Trimmed on an empty list is empty", LbTrimmed(""), "")
	Then("a tab and a line feed are white space", LbStripped(char(9) + "a" + char(10)), "a")
	Then("a carriage return is white space", LbStripped(char(13) + "a" + char(13)), "a")
	Then("a form feed is white space", LbStripped(char(12) + "a"), "a")
	Then("the byte 0 is not white space", LbCodes2(LbStripped(char(0) + "a")), "0,97")
	Then("e acute between spaces is kept whole", LbCodes2(LbStripped(" " + cLbE + " ")), "195,169")
	Then("Hebrew between spaces is kept whole", LbCodes2(LbStripped("  " + cLbH + "  ")), "215,144")
	Then("an emoji between spaces is kept whole", LbCodes2(LbStripped(" " + cLbJ + " ")), "240,159,152,128")
	Then("a no-break space at both ends is white space", LbStripped(cLbN + "a" + cLbN), "a")
	Then("a letter that is not white space is not stripped", LbStripped("xax"), "xax")
	Then("every case above agrees with Trimmed",
		LbAgree([ "  ab c  ", "x ", " x", "    ", "", " " + cLbE + " ", " " + cLbJ + " ", cLbN + "a" ]), 1)
	o = new stzListOfBytes("  ab c  ")
	Then("Stripped leaves the object as it is", o.Stripped() + "|" + o.ToString(), "ab c|  ab c  ")
	o.Strip()
	Then("Strip changes the object", o.ToString(), "ab c")
	ob = new stzBytes(" q ")
	Then("the same through the stzBytes name", ob.Stripped(), "q")
EndScenario()

Scenario("The neighbours the six rows rely on did not move")
	o = new stzListOfBytes("a" + cLbE)
	Then("NumberOfBytes counts bytes", o.NumberOfBytes(), 3)
	Then("NumberOfBytesPerChar pairs each char with its byte count", LbPerChar(o), "1,2")
	Then("BytesOfCharNumber is still byte-level", LbCodes(o.BytesOfCharNumber(2)), "195,169")
	Then("ToHexUTF8 is still the escaped hexadecimal", o.ToHexUTF8(), "\x61 \xc3 \xa9")
	Then("Trimmed still answers the same for a plain word", LbTrimmed(" word "), "word")
EndScenario()

Summary()

#-----------------------------------------------------------------------------------------------#

# the codes of a list of one-byte texts, joined by commas ("" for an empty list)
func LbCodes(aBytes)
	cOut = ""
	nLen = len(aBytes)
	for i = 1 to nLen
		if i > 1 cOut += "," ok
		if isNumber(aBytes[i])
			cOut += aBytes[i]
		else
			cOut += ascii(aBytes[i])
		ok
	next
	return cOut

# the codes of the bytes of a text
func LbCodes2(cText)
	o = new stzListOfBytes(cText)
	return LbCodes(o.Bytecodes())

func LbBytesOfThisChar(o, pChar)
	try
		aOut = o.BytesOfThisChar(pChar)
		return LbCodes(aOut)
	catch
		return "RAISED"
	done

func LbFillChars(cInit, cChar, nChars)
	o = new stzListOfBytes(cInit)
	o.FillWithAsciiCharUpToNChars(cChar, nChars)
	return o.ToString()

func LbFillBytes(cInit, cChar, nBytes)
	o = new stzListOfBytes(cInit)
	o.FillWithAsciiCharUpToNBytes(cChar, nBytes)
	return o.ToString()

func LbFillRaises(o, cChar, nChars)
	try
		o.FillWithAsciiCharUpToNChars(cChar, nChars)
		return ""
	catch
		return "RAISED"
	done

func LbFillAsciiMessage(o, cChar)
	try
		o.FillWithAsciiChar(cChar)
		return ""
	catch
		return cCatchError
	done

# how many bytes each char of the content takes, joined by commas
func LbPerChar(o)
	aPairs = o.NumberOfBytesPerChar()
	cOut = ""
	nLen = len(aPairs)
	for i = 1 to nLen
		if i > 1 cOut += "," ok
		cOut += aPairs[i][2]
	next
	return cOut

func LbToUtf8(cText)
	o = new stzListOfBytes(cText)
	return o.ToUTF8()

func LbBits(o)
	try
		x = o.Bits()
		return x
	catch
		return "RAISED"
	done

func LbBitsObject(o)
	try
		x = o.ToStzListOfBits()
		return x
	catch
		return "RAISED"
	done

func LbClassExists(cName)
	try
		eval("oTest = new " + cName + "('a')")
		return 1
	catch
		return 0
	done

func LbStripped(cText)
	o = new stzListOfBytes(cText)
	return o.Stripped()

func LbTrimmed(cText)
	o = new stzListOfBytes(cText)
	return o.Trimmed()

func LbAgree(aTexts)
	nLen = len(aTexts)
	for i = 1 to nLen
		if strcmp(LbStripped(aTexts[i]), LbTrimmed(aTexts[i])) != 0
			return 0
		ok
	next
	return 1
