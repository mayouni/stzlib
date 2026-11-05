load "../../stzBase.ring"
load "../_narrated.ring"

# The number family -- stzNumber, stzHexNumber, stzOctalNumber, stzBinaryNumber (base/number/) -- the seven register
# rows kept as a guard now that the classes answer. Run from inside this folder:
#     rnxc numberfamily_defects_narrated.ring
# It needs no DLL beyond the engine's number, bigint and string modules, no network and no file.
#
# THE HISTORY: the register said five methods raised R14 (or R24) for every input, and two did nothing but raise.
#   stzHexNumber.FractionalPart       called HexNumberWithoutPrefix, which does not exist: R14 for every input
#   stzHexNumber.ToScientificForm     forwarded to a stzNumber method that did not exist, with an undefined variable
#                                     n: R24 (the variable is read before the missing method is looked up)
#   stzOctalNumber.ToBaseNForm        forwarded to ToBaseNForm on stzNumber, which has IntegerPartToBaseNForm: R14
#   stzOctalNumber.ToScientificNotationForm, stzBinaryNumber.ToScientificNotationForm
#                                     forwarded to a stzNumber method that did not exist: R14
#   stzNumber.SetDefaultFormat, stzNumber.ApplyLocale
#                                     raise "Unsupported feature in this version!" on every call
# The shared root of three of them was that stzNumber had no scientific-notation method at all.
#
# THE RULES the guard holds the classes to:
#   stzNumber.ToScientificNotationForm   (aliases ToScientificNotation, ToScientificForm, ToScientific)
#     the text is ONE digit, then a point and the other significant digits when there are any (no trailing
#     zero), a lower case e, the sign of the exponent ALWAYS, and at least two exponent digits:
#     1500 is 1.5e+03, 255 is 2.55e+02, 0.00123 is 1.23e-03, -2.5 is -2.5e+00, 100 is 1e+02, 0 is 0e+00.
#     The digits are the FEWEST that read back as the same double, so the text goes back to the value it came
#     from (ring_number of the text equals the value, tested on fractions, powers of ten, the largest and the
#     smallest doubles). This is the format StzEngineNumberToScientific writes, minus its loss of the last digits.
#     The number is unchanged by the call.
#   stzHexNumber, stzOctalNumber, stzBinaryNumber ToScientific...  forward to it: the text of 0xFF, 0o377 and
#     0b11111111 is the text of 255. A binary fraction (0b101.11) is the text of 5.75.
#   stzHexNumber.FractionalPart (FractPart)   a hex number is a WHOLE number (init refuses 0x1F.8), so the digits
#     after the point are an empty text, as stzBinaryNumber answers for a number written without a point. It never
#     raises. init still refuses a text with a point and a sign.
#   stzOctalNumber.ToBaseNForm (toBaseN)   the whole number in base 2 to 36, lower case, no prefix, the same digits
#     as stzNumber.IntegerPartToBaseNForm and stzHexNumber.IntegerPartToBaseNForm. A base that is not a whole
#     number from 2 to 36 raises the named error "Can't convert this number in the specified base", never R14.
#   stzNumber.SetDefaultFormat, stzNumber.ApplyLocale   DEFERRED: no real semantics exist to implement (the
#     format dictionary of ApplyFormatXT is itself unfinished), so both still raise the same named error, now
#     documented as doing so. The guard pins that, so a change of behaviour is a change of the guard.
#   Nothing else moves: the other methods of the four classes answer what they answered before.
#
# The text of a result is compared EXACTLY (NfSame): Ring's = on text ignores case, and the whole point of the
# format is a lower case e. Every positive carries a negative sibling. ASCII only on the console.

$nNfI = 0
$nNfJ = 0
$cNfRaised = ""
$cNfGot = ""
$oNf = ""
$aNfVals = []
$aNfBases = []
$aNfBad = []
$aNfMeths = []
$cNfDigits = "0123456789abcdefghijklmnopqrstuvwxyz"

# ---------------------------------------------------------------------------------------------------------------
Scenario("1. stzNumber.ToScientificNotationForm: the exact texts")
try
	Given("numbers of every shape")
	Then("1500 is 1.5e+03", NfSame(new stzNumber(1500).ToScientificNotationForm(), "1.5e+03"), 1)
	Then("255 is 2.55e+02", NfSame(new stzNumber(255).ToScientificNotationForm(), "2.55e+02"), 1)
	Then("1 is 1e+00, with no point", NfSame(new stzNumber(1).ToScientificNotationForm(), "1e+00"), 1)
	Then("10 is 1e+01", NfSame(new stzNumber(10).ToScientificNotationForm(), "1e+01"), 1)
	Then("100 is 1e+02: the trailing zeros are gone", NfSame(new stzNumber(100).ToScientificNotationForm(), "1e+02"), 1)
	Then("1000000 is 1e+06", NfSame(new stzNumber(1000000).ToScientificNotationForm(), "1e+06"), 1)
	Then("123456 is 1.23456e+05", NfSame(new stzNumber(123456).ToScientificNotationForm(), "1.23456e+05"), 1)
	Then("3735928559 is 3.735928559e+09", NfSame(new stzNumber(3735928559).ToScientificNotationForm(), "3.735928559e+09"), 1)
	Then("0 is 0e+00", NfSame(new stzNumber(0).ToScientificNotationForm(), "0e+00"), 1)
	Then("5.75 is 5.75e+00", NfSame(new stzNumber(5.75).ToScientificNotationForm(), "5.75e+00"), 1)
	Then("0.1 is 1e-01: the exponent sign is written for a small number", NfSame(new stzNumber(0.1).ToScientificNotationForm(), "1e-01"), 1)
	Then("0.00123 is 1.23e-03", NfSame(new stzNumber(0.00123).ToScientificNotationForm(), "1.23e-03"), 1)
	Then("0.000001 is 1e-06", NfSame(new stzNumber(0.000001).ToScientificNotationForm(), "1e-06"), 1)
	Then("-2.5 is -2.5e+00", NfSame(new stzNumber(-2.5).ToScientificNotationForm(), "-2.5e+00"), 1)
	Then("-1500 is -1.5e+03: the sign leads", NfSame(new stzNumber(-1500).ToScientificNotationForm(), "-1.5e+03"), 1)
	Then("-0.00123 is -1.23e-03", NfSame(new stzNumber(-0.00123).ToScientificNotationForm(), "-1.23e-03"), 1)
	Then("99.5 is 9.95e+01: no rounding of a digit that is there", NfSame(new stzNumber(99.5).ToScientificNotationForm(), "9.95e+01"), 1)
	Then("9.9999 is 9.9999e+00", NfSame(new stzNumber(9.9999).ToScientificNotationForm(), "9.9999e+00"), 1)
	Then("1/3 keeps its 16 digits: 3.333333333333333e-01", NfSame(new stzNumber(1/3).ToScientificNotationForm(), "3.333333333333333e-01"), 1)
	Then("123456789.123456789 keeps its 17 digits: 1.2345678912345679e+08",
		NfSame(new stzNumber(123456789.123456789).ToScientificNotationForm(), "1.2345678912345679e+08"), 1)
	Then("NEGATIVE: the letter is lower case, never E", NfSameQ(new stzNumber(1500).ToScientificNotationForm(), "1.5E+03"), 0)
	Then("NEGATIVE: a positive exponent keeps its sign, never 1.5e03", NfSameQ(new stzNumber(1500).ToScientificNotationForm(), "1.5e03"), 0)
	Then("NEGATIVE: an exponent keeps two digits, never 1.5e+3", NfSameQ(new stzNumber(1500).ToScientificNotationForm(), "1.5e+3"), 0)
	Then("NEGATIVE: no trailing zero in the mantissa, never 1.50e+03", NfSameQ(new stzNumber(1500).ToScientificNotationForm(), "1.50e+03"), 0)
catch
	NfAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("2. stzNumber.ToScientificNotationForm: very large, very small, the edges of a double")
try
	Given("numbers built from text, since a Ring source has no exponent literal")
	$aNfVals = [
		[ "1" + copy("0", 22),               "1e+22" ],
		[ "1" + copy("0", 300),              "1e+300" ],
		[ "15" + copy("0", 300),             "1.5e+301" ],
		[ "123456789012345678901234567890",  "1.2345678901234568e+29" ],
		[ "9" + copy("9", 20),               "1e+21" ],
		[ "0." + copy("0", 299) + "25",      "2.5e-300" ],
		[ "0." + copy("0", 20) + "1",        "1e-21" ],
		[ "1.7976931348623157e+308",         "1.7976931348623157e+308" ],
		[ "-1.7976931348623157e+308",        "-1.7976931348623157e+308" ],
		[ "2.2250738585072014e-308",         "2.2250738585072014e-308" ],
		[ "1e-310",                          "1e-310" ],
		[ "4.9406564584124654e-324",         "5e-324" ]
	]
	for $nNfI = 1 to len($aNfVals)
		$cNfGot = new stzNumber(ring_number($aNfVals[$nNfI][1])).ToScientificNotationForm()
		Then("the text of " + left($aNfVals[$nNfI][1], 14) + ".. is " + $aNfVals[$nNfI][2], NfSame($cNfGot, $aNfVals[$nNfI][2]), 1)
	next
catch
	NfAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("3. stzNumber.ToScientificNotationForm: the text goes back to the number it came from")
try
	Given("forty values, round numbers, fractions that are not exact in binary, powers of ten and the edges")
	$aNfVals = [ 1500, 255, 0, 1, 10, 100, -2.5, 0.00123, 0.1, 0.2, 0.3, 0.7, 5.75, 99.5, 999.5, 9.9999, 123456789.123456789,
	             3735928559, 1/3, 2/3, 1/7, 22/7, 100000, 1000000, 123456, 0.000001, 1234567.891, 0.5, 0.25, 1/1024,
	             65535, 4294967296, 9007199254740992, 0.1 + 0.2, 100 * 1.1, 3 * 0.1, -0.001, -123456.789, 1/9, 8/9 ]
	$nNfJ = 0
	for $nNfI = 1 to len($aNfVals)
		$oNf = new stzNumber($aNfVals[$nNfI])
		$cNfGot = $oNf.ToScientificNotationForm()
		if ring_number($cNfGot) = $oNf.NumericValue()
			$nNfJ++
		else
			? "      round trip failed for " + $oNf.Content() + " : " + $cNfGot
		ok
	next
	Then("every text reads back as exactly the value it was made from", $nNfJ, len($aNfVals))

	$aNfVals = [ "1" + copy("0", 22), "1" + copy("0", 300), "15" + copy("0", 300), "123456789012345678901234567890",
	             "0." + copy("0", 299) + "25", "1.7976931348623157e+308", "2.2250738585072014e-308", "4.9406564584124654e-324" ]
	$nNfJ = 0
	for $nNfI = 1 to len($aNfVals)
		$oNf = new stzNumber(ring_number($aNfVals[$nNfI]))
		if ring_number($oNf.ToScientificNotationForm()) = $oNf.NumericValue()
			$nNfJ++
		ok
	next
	Then("...and so do eight values at the edges of a double", $nNfJ, len($aNfVals))

	When("the digits are counted")
	Then("0.1 + 0.2 shows its 17 digits, since it is not 0.3: 3.0000000000000004e-01",
		NfSame(new stzNumber(0.1 + 0.2).ToScientificNotationForm(), "3.0000000000000004e-01"), 1)
	Then("NEGATIVE: 0.3 is NOT 0.1 + 0.2 and its text is short: 3e-01", NfSameQ(new stzNumber(0.3).ToScientificNotationForm(), "3e-01"), 1)
catch
	NfAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("4. stzNumber.ToScientificNotationForm: the four spellings, case, and the receiver left alone")
try
	Given("a stzNumber holding 1500")
	$oNf = new stzNumber(1500)
	Then("ToScientificNotation is the same text", NfSame($oNf.ToScientificNotation(), "1.5e+03"), 1)
	Then("ToScientificForm is the same text", NfSame($oNf.ToScientificForm(), "1.5e+03"), 1)
	Then("ToScientific is the same text", NfSame($oNf.ToScientific(), "1.5e+03"), 1)
	Then("the method name is case-insensitive: toscientificnotationform", NfSame($oNf.toscientificnotationform(), "1.5e+03"), 1)
	Then("...and TOSCIENTIFIC", NfSame($oNf.TOSCIENTIFIC(), "1.5e+03"), 1)
	Then("the call leaves the content alone", $oNf.Content(), "1500")
	Then("...and the value alone", $oNf.NumericValue(), 1500)
	Then("the hex form of the same number is unchanged: 0x5DC", NfSame($oNf.ToHexForm(), "0x5DC"), 1)
	Then("the octal form is unchanged: 0o2734", NfSame($oNf.ToOctalForm(), "0o2734"), 1)
	Then("the binary form is unchanged: 0b10111011100", NfSame($oNf.ToBinaryForm(), "0b10111011100"), 1)
	Then("the base 36 digits are unchanged: 15o", NfSame($oNf.IntegerPartToBaseNForm(36), "15o"), 1)
	Then("two numbers share nothing: another one answers its own text", NfSame(new stzNumber(255).ToScientificNotationForm(), "2.55e+02"), 1)
	Then("...and the first one still answers its own", NfSame($oNf.ToScientificNotationForm(), "1.5e+03"), 1)
catch
	NfAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("5. stzHexNumber: ToScientificForm answers, and agrees with the decimal value")
try
	Given("hex numbers written with and without a prefix")
	Then("0xFF is 2.55e+02", NfSame(new stzHexNumber("0xFF").ToScientificForm(), "2.55e+02"), 1)
	Then("0x41 is 6.5e+01", NfSame(new stzHexNumber("0x41").ToScientificForm(), "6.5e+01"), 1)
	Then("0x0 is 0e+00", NfSame(new stzHexNumber("0x0").ToScientificForm(), "0e+00"), 1)
	Then("FF, with no prefix, is 2.55e+02", NfSame(new stzHexNumber("FF").ToScientificForm(), "2.55e+02"), 1)
	Then("U+0041 is 6.5e+01", NfSame(new stzHexNumber("U+0041").ToScientificForm(), "6.5e+01"), 1)
	Then("0xabc, in lower case, is 2.748e+03", NfSame(new stzHexNumber("0xabc").ToScientificForm(), "2.748e+03"), 1)
	Then("0x1A3 is 4.19e+02", NfSame(new stzHexNumber("0x1A3").ToScientificForm(), "4.19e+02"), 1)
	Then("0xDEADBEEF is 3.735928559e+09", NfSame(new stzHexNumber("0xDEADBEEF").ToScientificForm(), "3.735928559e+09"), 1)
	Then("ToScientific is the same call", NfSame(new stzHexNumber("0xFF").ToScientific(), "2.55e+02"), 1)
	Then("the spelling is case-insensitive: toscientificform", NfSame(new stzHexNumber("0xFF").toscientificform(), "2.55e+02"), 1)
	Then("an empty hex number is zero: 0e+00", NfSame(new stzHexNumber("").ToScientificForm(), "0e+00"), 1)
	Then("it is the text of the decimal value, for 0xDEADBEEF", NfSame(new stzHexNumber("0xDEADBEEF").ToScientificForm(),
		new stzNumber(3735928559).ToScientificNotationForm()), 1)
	Then("NEGATIVE: it raises nothing", NfRaised('new stzHexNumber("0xFF").ToScientificForm()'), "")
	Then("NEGATIVE: the text is not the hex digits, never 0xFF", NfSameQ(new stzHexNumber("0xFF").ToScientificForm(), "0xFF"), 0)
	Then("the object is unchanged: Content is FF", NfSame(new stzHexNumber("0xFF").Content(), "FF"), 1)
catch
	NfAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("6. stzHexNumber.FractionalPart: a whole number has no digits after the point, and the call never raises")
try
	Given("hex numbers of every kind init accepts")
	$aNfVals = [ "0xFF", "0x41", "0x0", "FF", "U+0041", "0xDEADBEEF", "0xabc", "0x1A3", "" ]
	$nNfJ = 0
	$cNfRaised = ""
	for $nNfI = 1 to len($aNfVals)
		$cNfGot = NfRaised('new stzHexNumber("' + $aNfVals[$nNfI] + '").FractionalPart()')
		if $cNfGot = "" and NfSame(new stzHexNumber($aNfVals[$nNfI]).FractionalPart(), "")
			$nNfJ++
		else
			? "      FractionalPart failed for [" + $aNfVals[$nNfI] + "] : " + $cNfGot
		ok
	next
	Then("FractionalPart answers an empty text for all nine, and raises for none", $nNfJ, 9)
	Then("FractPart is the same call", NfSame(new stzHexNumber("0xFF").FractPart(), ""), 1)
	Then("the spelling is case-insensitive: fractionalpart", NfSame(new stzHexNumber("0x41").fractionalpart(), ""), 1)
	Then("the answer is a text, not a number", isString(new stzHexNumber("0xFF").FractionalPart()), 1)
	Then("NEGATIVE: it is not the integer digits", NfSameQ(new stzHexNumber("0xFF").FractionalPart(), "FF"), 0)
	Then("NEGATIVE: it no longer raises R14", WsHasNf(NfRaised('new stzHexNumber("0xFF").FractionalPart()'), "R14"), 0)

	When("the neighbours of FractionalPart are asked")
	Then("IntegerPart is unchanged: 0xFF", NfSame(new stzHexNumber("0xFF").IntegerPart(), "0xFF"), 1)
	Then("IntegerPartWithoutPrefix keeps its documented stray 0: 0FF", NfSame(new stzHexNumber("0xFF").IntegerPartWithoutPrefix(), "0FF"), 1)
	Then("Content is unchanged: FF", NfSame(new stzHexNumber("0xFF").Content(), "FF"), 1)
	Then("WithPrefix is unchanged: 0xFF", NfSame(new stzHexNumber("0xFF").WithPrefix(), "0xFF"), 1)

	When("a hex number with a point, or a sign, is offered to init")
	Then("0x1F.8 is still refused (hex numbers are whole numbers by design)", WsHasNf(NfRaised('new stzHexNumber("0x1F.8")'), "hex number"), 1)
	Then("-0xFF is still refused", WsHasNf(NfRaised('new stzHexNumber("-0xFF")'), "hex number"), 1)
	Then("a number is still refused, with the param type", WsHasNf(NfRaised('new stzHexNumber(255)'), "Incorrect param type"), 1)
catch
	NfAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("7. stzHexNumber: every other method answers what it answered before")
try
	Given("0xFF, 0x41, 0x0 and 0xDEADBEEF")
	Then("0xFF ToDecimalForm is 255", NfSame(new stzHexNumber("0xFF").ToDecimalForm(), "255"), 1)
	Then("0xFF ToBinaryForm is 0b11111111", NfSame(new stzHexNumber("0xFF").ToBinaryForm(), "0b11111111"), 1)
	Then("0xFF ToBinaryFormWithoutPrefix is 11111111", NfSame(new stzHexNumber("0xFF").ToBinaryFormWithoutPrefix(), "11111111"), 1)
	Then("0xFF ToOctalForm is 0o377", NfSame(new stzHexNumber("0xFF").ToOctalForm(), "0o377"), 1)
	Then("0xFF ToOctalFormWithoutPrefix is 377", NfSame(new stzHexNumber("0xFF").ToOctalFormWithoutPrefix(), "377"), 1)
	Then("0xFF IntegerPartToBaseNForm(2) is 11111111", NfSame(new stzHexNumber("0xFF").IntegerPartToBaseNForm(2), "11111111"), 1)
	Then("0xFF IntegerPartToBaseNForm(16) is ff, in lower case", NfSame(new stzHexNumber("0xFF").IntegerPartToBaseNForm(16), "ff"), 1)
	Then("0xFF IntegerPartToBaseNForm(36) is 73", NfSame(new stzHexNumber("0xFF").IntegerPartToBaseNForm(36), "73"), 1)
	Then("0xFF ToUnicodeHexForm keeps its documented 0x: U+0xFF", NfSame(new stzHexNumber("0xFF").ToUnicodeHexForm(), "U+0xFF"), 1)
	Then("0x0 ToDecimalForm is 0", NfSame(new stzHexNumber("0x0").ToDecimalForm(), "0"), 1)
	Then("0x0 ToBinaryForm is 0b0", NfSame(new stzHexNumber("0x0").ToBinaryForm(), "0b0"), 1)
	Then("0xDEADBEEF ToDecimalForm is 3735928559", NfSame(new stzHexNumber("0xDEADBEEF").ToDecimalForm(), "3735928559"), 1)
	Then("0xDEADBEEF ToOctalFormWithoutPrefix is 33653337357", NfSame(new stzHexNumber("0xDEADBEEF").ToOctalFormWithoutPrefix(), "33653337357"), 1)
	Then("0xDEADBEEF ToBinaryFormWithoutPrefix is 11011110101011011011111011101111",
		NfSame(new stzHexNumber("0xDEADBEEF").ToBinaryFormWithoutPrefix(), "11011110101011011011111011101111"), 1)
	Then("0xFF ToBytes is eight bytes", len(new stzHexNumber("0xFF").ToBytes()), 8)
	Then("IsHexNumber is TRUE", new stzHexNumber("0xFF").IsHexNumber(), 1)
	Then("0xFF round trip: FromDecimalForm(255) stores FF", NfSame(NfFromDec(255), "FF"), 1)
	Then("...FromDecimalForm(4096) stores 1000", NfSame(NfFromDec(4096), "1000"), 1)
catch
	NfAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("8. stzOctalNumber.ToBaseNForm: every base from 2 to 36, against an independent division")
try
	Given("0o377, which is 255, and three more octal numbers")
	$aNfVals = [ [ "0o377", 255 ], [ "17", 15 ], [ "0o0", 0 ], [ "0o755", 493 ] ]
	for $nNfJ = 1 to len($aNfVals)
		$nNfI = 0
		$cNfRaised = ""
		for $nNfBase = 2 to 36
			$cNfGot = new stzOctalNumber($aNfVals[$nNfJ][1]).ToBaseNForm($nNfBase)
			if NfSame($cNfGot, NfDigits($aNfVals[$nNfJ][2], $nNfBase))
				$nNfI++
			else
				? "      base " + $nNfBase + " of " + $aNfVals[$nNfJ][1] + " : got " + $cNfGot + " wanted " + NfDigits($aNfVals[$nNfJ][2], $nNfBase)
			ok
		next
		Then($aNfVals[$nNfJ][1] + " is written right in each of the 35 bases", $nNfI, 35)
	next

	When("single values are read by eye")
	Then("0o377 in base 2 is 11111111", NfSame(new stzOctalNumber("0o377").ToBaseNForm(2), "11111111"), 1)
	Then("0o377 in base 8 is 377", NfSame(new stzOctalNumber("0o377").ToBaseNForm(8), "377"), 1)
	Then("0o377 in base 10 is 255", NfSame(new stzOctalNumber("0o377").ToBaseNForm(10), "255"), 1)
	Then("0o377 in base 16 is ff, lower case and with no prefix", NfSame(new stzOctalNumber("0o377").ToBaseNForm(16), "ff"), 1)
	Then("0o377 in base 36 is 73", NfSame(new stzOctalNumber("0o377").ToBaseNForm(36), "73"), 1)
	Then("17 in base 16 is f", NfSame(new stzOctalNumber("17").ToBaseNForm(16), "f"), 1)
	Then("17 in base 2 is 1111", NfSame(new stzOctalNumber("17").ToBaseNForm(2), "1111"), 1)
	Then("0o755 in base 16 is 1ed", NfSame(new stzOctalNumber("0o755").ToBaseNForm(16), "1ed"), 1)
	Then("0o0 in base 7 is 0", NfSame(new stzOctalNumber("0o0").ToBaseNForm(7), "0"), 1)
	Then("toBaseN is the same call", NfSame(new stzOctalNumber("0o377").toBaseN(16), "ff"), 1)
	Then("the spelling is case-insensitive: TOBASENFORM", NfSame(new stzOctalNumber("0o377").TOBASENFORM(16), "ff"), 1)
	Then("NEGATIVE: the digits are not upper case, never FF", NfSameQ(new stzOctalNumber("0o377").ToBaseNForm(16), "FF"), 0)
	Then("NEGATIVE: no prefix is added, never 0xff", NfSameQ(new stzOctalNumber("0o377").ToBaseNForm(16), "0xff"), 0)
	Then("it agrees with stzHexNumber.IntegerPartToBaseNForm for 255", NfSame(new stzOctalNumber("0o377").ToBaseNForm(36),
		new stzHexNumber("0xFF").IntegerPartToBaseNForm(36)), 1)
	Then("...and with stzNumber.IntegerPartToBaseNForm", NfSame(new stzOctalNumber("0o377").ToBaseNForm(7),
		new stzNumber(255).IntegerPartToBaseNForm(7)), 1)
	Then("each digit string reads back as the value, base 36 of 0o755", NfFromBase(new stzOctalNumber("0o755").ToBaseNForm(36), 36), 493)
	Then("...and base 3 of 0o755", NfFromBase(new stzOctalNumber("0o755").ToBaseNForm(3), 3), 493)
	Then("the object is unchanged: Content is 0o377", NfSame(new stzOctalNumber("0o377").Content(), "0o377"), 1)
catch
	NfAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("9. stzOctalNumber.ToBaseNForm: a base that is not a whole number from 2 to 36 raises the named error, never R14")
try
	Given("bad bases of every kind")
	$aNfBad = [ "0", "1", "37", "100", "-3", "-2", "2.5", "36.5", '""', '"16"', '"abc"', '"2"', "[ 16 ]", "[ ]" ]
	$nNfI = 0
	for $nNfJ = 1 to len($aNfBad)
		$cNfRaised = NfRaised('new stzOctalNumber("0o377").ToBaseNForm(' + $aNfBad[$nNfJ] + ')')
		if WsHasNf($cNfRaised, "Can't convert this number in the specified base") and NOT WsHasNf($cNfRaised, "R14") and
		   NOT WsHasNf($cNfRaised, "without definition")
			$nNfI++
		else
			? "      base " + $aNfBad[$nNfJ] + " : [" + $cNfRaised + "]"
		ok
	next
	Then("all fourteen raise the named error, and none raises R14", $nNfI, len($aNfBad))
	Then("the alias toBaseN refuses 37 the same way", WsHasNf(NfRaised('new stzOctalNumber("0o377").toBaseN(37)'), "specified base"), 1)
	Then("NEGATIVE: base 2 is accepted", NfRaised('new stzOctalNumber("0o377").ToBaseNForm(2)'), "")
	Then("NEGATIVE: base 36 is accepted", NfRaised('new stzOctalNumber("0o377").ToBaseNForm(36)'), "")
	Then("NEGATIVE: base 37 is refused, not computed", WsHasNf(NfRaised('new stzOctalNumber("0o377").ToBaseNForm(37)'), "specified base"), 1)
	Then("a bad base on the other classes' own method is refused the same way: stzHexNumber 37",
		WsHasNf(NfRaised('new stzHexNumber("0xFF").IntegerPartToBaseNForm(37)'), "specified base"), 1)
catch
	NfAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("10. stzOctalNumber.ToScientificNotationForm, and the rest of the class unchanged")
try
	Given("octal numbers")
	Then("0o377 is 2.55e+02", NfSame(new stzOctalNumber("0o377").ToScientificNotationForm(), "2.55e+02"), 1)
	Then("17 is 1.5e+01", NfSame(new stzOctalNumber("17").ToScientificNotationForm(), "1.5e+01"), 1)
	Then("0o0 is 0e+00", NfSame(new stzOctalNumber("0o0").ToScientificNotationForm(), "0e+00"), 1)
	Then("0o755 is 4.93e+02", NfSame(new stzOctalNumber("0o755").ToScientificNotationForm(), "4.93e+02"), 1)
	Then("ToScientificNotation is the same call", NfSame(new stzOctalNumber("0o377").ToScientificNotation(), "2.55e+02"), 1)
	Then("the spelling is case-insensitive: TOSCIENTIFICNOTATION", NfSame(new stzOctalNumber("0o377").TOSCIENTIFICNOTATION(), "2.55e+02"), 1)
	Then("NEGATIVE: it raises nothing", NfRaised('new stzOctalNumber("0o377").ToScientificNotationForm()'), "")
	Then("0o377 and 0xFF write the same text", NfSame(new stzOctalNumber("0o377").ToScientificNotationForm(),
		new stzHexNumber("0xFF").ToScientificForm()), 1)

	When("the other methods are asked")
	Then("ToDecimalForm of 0o377 is 255", new stzOctalNumber("0o377").ToDecimalForm(), 255)
	Then("ToBinaryForm of 0o377 is 0b11111111", NfSame(new stzOctalNumber("0o377").ToBinaryForm(), "0b11111111"), 1)
	Then("ToHexForm of 0o377 is 0xFF", NfSame(new stzOctalNumber("0o377").ToHexForm(), "0xFF"), 1)
	Then("ToHexFormWithoutPrefix of 0o755 is 1ED", NfSame(new stzOctalNumber("0o755").ToHexFormWithoutPrefix(), "1ED"), 1)
	Then("ToUnicodeHexForm of 0o377 is U+FF", NfSame(new stzOctalNumber("0o377").ToUnicodeHexForm(), "U+FF"), 1)
	Then("WithPrefix keeps its documented doubling: 0o0o377", NfSame(new stzOctalNumber("0o377").WithPrefix(), "0o0o377"), 1)
	Then("WithPrefix of 17 is 0o17", NfSame(new stzOctalNumber("17").WithPrefix(), "0o17"), 1)
	Then("FromDecimalForm(255) stores 0o377", NfSame(NfOctFromDec(255), "0o377"), 1)
catch
	NfAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("11. stzBinaryNumber.ToScientificNotationForm: whole numbers, fractions, signs, and the rest unchanged")
try
	Given("binary numbers")
	Then("0b1010 is 1e+01", NfSame(new stzBinaryNumber("0b1010").ToScientificNotationForm(), "1e+01"), 1)
	Then("0b1011 is 1.1e+01", NfSame(new stzBinaryNumber("0b1011").ToScientificNotationForm(), "1.1e+01"), 1)
	Then("0b11111111 is 2.55e+02", NfSame(new stzBinaryNumber("0b11111111").ToScientificNotationForm(), "2.55e+02"), 1)
	Then("0b0 is 0e+00", NfSame(new stzBinaryNumber("0b0").ToScientificNotationForm(), "0e+00"), 1)
	Then("the empty binary number is zero: 0e+00", NfSame(new stzBinaryNumber("").ToScientificNotationForm(), "0e+00"), 1)
	Then("0b101.11 (5.75) is 5.75e+00", NfSame(new stzBinaryNumber("0b101.11").ToScientificNotationForm(), "5.75e+00"), 1)
	Then("-0b101 is -5e+00", NfSame(new stzBinaryNumber("-0b101").ToScientificNotationForm(), "-5e+00"), 1)
	Then("0b0.1 (0.5) is 5e-01", NfSame(new stzBinaryNumber("0b0.1").ToScientificNotationForm(), "5e-01"), 1)
	Then("ToScientificNotation is the same call", NfSame(new stzBinaryNumber("0b1011").ToScientificNotation(), "1.1e+01"), 1)
	Then("the spelling is case-insensitive: tOsCiEnTiFiCnOtAtIoN", NfSame(new stzBinaryNumber("0b1011").tOsCiEnTiFiCnOtAtIoN(), "1.1e+01"), 1)
	Then("NEGATIVE: it raises nothing", NfRaised('new stzBinaryNumber("0b1011").ToScientificNotationForm()'), "")
	Then("0b11111111, 0o377 and 0xFF write the text of 255", NfSame(new stzBinaryNumber("0b11111111").ToScientificNotationForm(),
		new stzNumber(255).ToScientificNotationForm()), 1)

	When("the other methods are asked")
	Then("ToDecimalForm of 0b1011 is 11", NfSame(new stzBinaryNumber("0b1011").ToDecimalForm(), "11"), 1)
	Then("ToDecimalForm of 0b101.11 is 5.75", NfSame(new stzBinaryNumber("0b101.11").ToDecimalForm(), "5.75"), 1)
	Then("ToOctalForm of 0b1011 is 0o13", NfSame(new stzBinaryNumber("0b1011").ToOctalForm(), "0o13"), 1)
	Then("ToHexForm of 0b1011 is 0xB", NfSame(new stzBinaryNumber("0b1011").ToHexForm(), "0xB"), 1)
	Then("ToHexForm of 0b101.11 keeps its documented loss: 0x5.", NfSame(new stzBinaryNumber("0b101.11").ToHexForm(), "0x5."), 1)
	Then("IntegerPartToBaseNForm(3) of 0b1011 is 102", NfSame(new stzBinaryNumber("0b1011").IntegerPartToBaseNForm(3), "102"), 1)
	Then("FractionalPart of 0b101.11 is 11", NfSame(new stzBinaryNumber("0b101.11").FractionalPart(), "11"), 1)
	Then("FractionalPart of 0b1011, with no point, is the empty text", NfSame(new stzBinaryNumber("0b1011").FractionalPart(), ""), 1)
	Then("BitwiseAND(6) of 0b1011 is 2", new stzBinaryNumber("0b1011").BitwiseAND(6), 2)
	Then("BitwiseLeftShift(2) of 0b1011 is 44", new stzBinaryNumber("0b1011").BitwiseLeftShift(2), 44)
	Then("WithPrefix keeps its documented doubling: 0b0b1011", NfSame(new stzBinaryNumber("0b1011").WithPrefix(), "0b0b1011"), 1)
	Then("FromDecimalForm(12500) stores 0b11000011010100", NfSame(NfBinFromDec(12500), "0b11000011010100"), 1)
catch
	NfAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("12. SetDefaultFormat and ApplyLocale: DEFERRED, so they still raise the named error, and nothing else around them moved")
try
	Given("a stzNumber")
	$cNfRaised = NfRaised('new stzNumber(1234567.891).SetDefaultFormat()')
	Then("SetDefaultFormat raises Unsupported feature in this version!", WsHasNf($cNfRaised, "Unsupported feature in this version!"), 1)
	$cNfRaised = NfRaised('new stzNumber(1234567.891).ApplyLocale("fr-FR")')
	Then("ApplyLocale raises the same error", WsHasNf($cNfRaised, "Unsupported feature in this version!"), 1)
	Then("NEGATIVE: neither raises R14", WsHasNf($cNfRaised, "R14"), 0)
	Then("ApplyLocale with an empty locale name raises too", WsHasNf(NfRaised('new stzNumber(1).ApplyLocale("")'), "Unsupported"), 1)
	Then("FormatXT, the documented way to choose separators, still groups the whole part with them",
		NfSame(new stzNumber(1234567).FormatXT([ :ShowSign = 0, :ThousandsSeparator = " " ]), "1 234 567"), 1)
	Then("StzFormatNumber, the other documented way, still groups with commas",
		NfSame(StzFormatNumber(1234567.891, 2), "1,234,567.89"), 1)
	Then("new stzLocale(fr-FR).DecimalPoint() is still a comma", NfSame(new stzLocale("fr-FR").DecimalPoint(), ","), 1)
catch
	NfAbort()
done
EndScenario()

Summary()

# ---------------------------------------------------------------------------------------------------------------
# helpers: every name a function reads is a $global (Rule A)

# an EXACT, case-sensitive comparison of two texts through their hex: Ring's = on text ignores case
func NfSame(a, b)
	if NfSameQ(a, b) = 1  return 1  ok
	? "      (exact compare failed)  got [" + a + "]  wanted [" + b + "]"
	return 0

# the same, quietly: for the negative siblings, which are expected to differ
func NfSameQ(a, b)
	if isString(a) and isString(b)
		if str2hex(a) = str2hex(b)  return 1  ok
	ok
	return 0

# the text of the error a statement raises, "" when it raises nothing
func NfRaised(cCode)
	$cNfRaised = ""
	try
		eval("$oNf = " + cCode)
	catch
		$cNfRaised = cCatchError
	done
	return $cNfRaised

func WsHasNf(cHay, cNeedle)
	if StzFindFirst(cNeedle, cHay) > 0  return 1  ok
	return 0

func NfAbort()
	? "  ABORTED by an uncaught error: " + cCatchError
	$_zst_fail++
	$_zst_total++

# the digits of a whole number in a base, by repeated division: written here, not taken from the library
func NfDigits(nVal, nBase)
	if nVal = 0
		return "0"
	ok
	cOut = ""
	while nVal > 0
		nRem = nVal % nBase
		cOut = $cNfDigits[nRem + 1] + cOut
		nVal = (nVal - nRem) / nBase
	end
	return cOut

# the value of digits in a base, read back with Horner's rule
func NfFromBase(cDigits, nBase)
	nOut = 0
	for nK = 1 to len(cDigits)
		nOut = nOut * nBase + (StzFindFirst(cDigits[nK], $cNfDigits) - 1)
	next
	return nOut

func NfFromDec(n)
	o = new stzHexNumber("")
	o.FromDecimalForm(n)
	return o.Content()

func NfOctFromDec(n)
	o = new stzOctalNumber("0")
	o.FromDecimalForm(n)
	return o.Content()

func NfBinFromDec(n)
	o = new stzBinaryNumber("")
	o.FromDecimalForm(n)
	return o.Content()
