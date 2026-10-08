load "../../stzBase.ring"
load "../_narrated.ring"

# Guard for the stzStringChar defects fixed on fix/gscl (DEFECTS.md, stzStringChar):
# HexUnicode kept four hex digits; IsUnicodeNumber, IsPrintable/IsNonPrintable and
# IsArabicNumber tested the wrong category codes or the wrong type; Update(number)
# emptied the object; IsBasicLatin, IsBasicArabic and the circled-letter tests read
# variables that do not exist (R24).

Scenario("HexUnicode keeps every hex digit")
	o = new stzStringChar("a")
	Then("a is U+0061", o.HexUnicode(), "U+0061")
	o = new stzStringChar(128512)
	Then("the grinning face is U+1F600, not U+F600", o.HexUnicode(), "U+1F600")
	o = new stzStringChar(1576)
	Then("the Arabic beh is U+0628", o.HexUnicode(), "U+0628")
	o = new stzStringChar(0x10FFFF)
	Then("the last codepoint is U+10FFFF", o.HexUnicode(), "U+10FFFF")
EndScenario()

Scenario("Update takes a codepoint as well as a text")
	o = new stzStringChar("a")
	o.Update(98)
	Then("Update(98) holds b", o.Content(), "b")
	Then("and its codepoint is 98", o.Unicode(), 98)
	o.UpdateWith("U+0628")
	Then("UpdateWith a U+ text holds the Arabic beh", o.Unicode(), 1576)
	o.UpdateBy(128512)
	Then("UpdateBy a codepoint above U+FFFF", o.HexUnicode(), "U+1F600")
	o.UpdateUsing("z")
	Then("UpdateUsing a one-char text", o.Content(), "z")
	Then("a text of two chars is refused", Raises(o, 'o.Update("ab")') != "", 1)
	Then("and the char is left as it was", o.Content(), "z")
EndScenario()

Scenario("IsUnicodeNumber answers for number chars, not letters")
	Then("7 is a number", GChar("7").IsUnicodeNumber(), 1)
	Then("the Arabic-Indic one is a number", GChar(1633).IsUnicodeNumber(), 1)
	Then("the Roman numeral one (U+2160) is a number", GChar(8544).IsUnicodeNumber(), 1)
	Then("the vulgar fraction one half is a number", GChar(189).IsUnicodeNumber(), 1)
	Then("the Arabic beh is not", GChar(1576).IsUnicodeNumber(), 0)
	Then("the Hebrew alef is not", GChar(1488).IsUnicodeNumber(), 0)
	Then("a is not", GChar("a").IsUnicodeNumber(), 0)
EndScenario()

Scenario("IsPrintable rejects control and format chars, not digits")
	Then("7 is printable", GChar("7").IsPrintable(), 1)
	Then("the hyphen is printable", GChar("-").IsPrintable(), 1)
	Then("the Roman numeral one is printable", GChar(8544).IsPrintable(), 1)
	Then("the space is printable", GChar(" ").IsPrintable(), 1)
	Then("the tab is not", GChar(9).IsPrintable(), 0)
	Then("the zero-width joiner (format) is not", GChar(8205).IsPrintable(), 0)
	Then("a private-use char is not", GChar(57344).IsPrintable(), 0)
	Then("IsNonPrintable is the reverse for the tab", GChar(9).IsNonPrintable(), 1)
	Then("and for 7", GChar("7").IsNonPrintable(), 0)
EndScenario()

Scenario("IsArabicNumber answers for 0 to 9 and never raises")
	Then("0 is an Arabic digit", GChar("0").IsArabicNumber(), 1)
	Then("9 is an Arabic digit", GChar("9").IsArabicNumber(), 1)
	Then("a is not", GChar("a").IsArabicNumber(), 0)
	o = new stzStringChar(1633)
	Then("the Arabic-Indic one answers without raising", Raises(o, "o.IsArabicNumber()"), "")
	Then("and answers FALSE (it is an Indian number here)", o.IsArabicNumber(), 0)
	o = new stzStringChar(9312)
	Then("a circled one answers FALSE without raising", Raises(o, "o.IsArabicNumber()"), "")
EndScenario()

Scenario("The block tests read the right data")
	Then("a is Basic Latin", GChar("a").IsBasicLatin(), 1)
	Then("e acute is not Basic Latin", GChar(233).IsBasicLatin(), 0)
	Then("the Arabic beh is basic Arabic", GChar(1576).IsBasicArabic(), 1)
	Then("a is not basic Arabic", GChar("a").IsBasicArabic(), 0)
	Then("circled small a (U+24D0) is a circled small letter", GChar(9424).IsCircledLatinSmallLetter(), 1)
	Then("circled capital A (U+24B6) is not", GChar(9398).IsCircledLatinSmallLetter(), 0)
	Then("circled capital A is a circled capital letter", GChar(9398).IsCircledLatinCapitalLetter(), 1)
	Then("circled small a is not", GChar(9424).IsCircledLatinCapitalLetter(), 0)
EndScenario()

Summary()

func Raises(o, cCode)
	try
		eval(cCode)
		return ""
	catch
		return cCatchError
	done

func GChar(p)
	return new stzStringChar(p)
