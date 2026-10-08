load "../../stzBase.ring"
load "../_narrated.ring"

# Guard for the stzLocale defects fixed on fix/gscl (DEFECTS.md, stzLocale):
# the Script* methods answered common for every locale written without a script
# (the bare attributes started as the TEXT "NULL"); the ToTimeAs* methods raised
# R20; the title-case and capital-case methods raised R14; the case conversions
# changed ASCII letters only; the fold-case methods answered nothing; and
# StringLowercased(5) / StringUppercased(5) ENDED THE PROCESS. This guard calls
# both of them and keeps running: reaching Summary() is the proof.

Scenario("The script comes from the language when the code names none")
	aCases = [ [ "fr-FR", "7", "latin", "Latn" ], [ "en-US", "7", "latin", "Latn" ],
	           [ "ar-EG", "1", "arabic", "Arab" ], [ "ru-RU", "2", "cyrillic", "Cyrl" ],
	           [ "ar_Arab_TN", "1", "arabic", "Arab" ] ]
	nLen = len(aCases)
	for i = 1 to nLen
		o = new stzLocale(aCases[i][1])
		Then(aCases[i][1] + " has script number " + aCases[i][2], o.ScriptNumber(), aCases[i][2])
		Then(aCases[i][1] + " has script name " + aCases[i][3], o.ScriptName(), aCases[i][3])
		Then(aCases[i][1] + " has script code " + aCases[i][4], o.ScriptAbbreviation(), aCases[i][4])
	next
EndScenario()

Scenario("The ToTimeAs methods write the time")
	o = new stzLocale("fr-FR")
	Then("the short format", o.ToTimeAsShortString("14:30:00"), "14:30")
	Then("the narrow format", o.ToTimeAsNarrowString("14:30:00"), "14:30")
	Then("the long format, without a zone letter", o.ToTimeAsLongString("14:30:00"), "14:30:00")
	Then("a format given as text", o.ToTimeAsString("14:30:00", "HH"), "14")
EndScenario()

Scenario("The case conversions reach every script")
	o = new stzLocale("fr-FR")
	Then("E acute and Cyrillic lowercase", o.StringLowercased("ÉCOLE Привет"), "école привет")
	Then("e acute uppercases and sharp s gives SS", o.StringUppercased("école straße"), "ÉCOLE STRASSE")
	Then("CharLowercased turns E acute", o.CharLowercased("É"), "é")
	Then("StringIsLowercased notices an accented capital", o.StringIsLowercased("École"), 0)
	Then("StringIsUppercased notices an accented small letter", o.StringIsUppercased("éCOLE"), 0)
	o = new stzLocale("tr-TR")
	Then("Turkish I lowercases to the dotless i", o.StringLowercased("I"), StzEngineCharToUtf8(305))
	Then("Turkish dotted I lowercases to i", o.StringLowercased(StzEngineCharToUtf8(304)), "i")
	Then("Turkish i uppercases to the dotted I", o.StringUppercased("i"), StzEngineCharToUtf8(304))
	o = new stzLocale("en-US")
	Then("English I lowercases to i", o.StringLowercased("I"), "i")
EndScenario()

Scenario("Title case and capital case")
	o = new stzLocale("en-US")
	Then("English capitalises every word", o.StringTitlecased("in search OF lost time"), "In Search Of Lost Time")
	Then("ToTitleCase answers the same", o.ToTitleCase("in search of lost time"), "In Search Of Lost Time")
	Then("StringIsTitlecased is TRUE for a title", o.StringIsTitlecased("In Search Of Lost Time"), 1)
	Then("and FALSE for a sentence", o.StringIsTitlecased("In search of lost time"), 0)
	Then("double spaces are kept", o.StringCapitalcased("a  b"), "A  B")
	o = new stzLocale("fr-FR")
	Then("French capitalises the first letter only",
		o.StringTitlecased("a LA recherche du temps perdu"), "A la recherche du temps perdu")
	Then("StringCapitalcased capitalises every word, accents too", o.StringCapitalcased("été chaud"), "Été Chaud")
	Then("StringIsCapitalised", o.StringIsCapitalised("Été Chaud"), 1)
	o = new stzLocale("tr-TR")
	Then("Turkish capital case uses the dotted I", o.StringCapitalcased("istanbul"), StzEngineCharToUtf8(304) + "stanbul")
EndScenario()

Scenario("Case folding answers")
	o = new stzLocale("de-DE")
	Then("Straße folds to strasse", o.StringFoldcased("Straße"), "strasse")
	Then("ToFoldcase answers the same", o.ToFoldcase("ABC"), "abc")
	Then("CharFoldcased", o.CharFoldcased("A"), "a")
	Then("StringIsfoldcased is TRUE for folded text", o.StringIsfoldcased("abc"), 1)
	Then("and FALSE otherwise", o.StringIsfoldcased("Abc"), 0)
EndScenario()

Scenario("A number given to the case methods raises; the process lives on")
	o = new stzLocale("fr-FR")
	Then("StringLowercased(5) raises a clear error",
		Raises(o, "o.StringLowercased(5)"), "Incorrect param type! pcStr must be a string." + char(10))
	Then("StringUppercased(5) raises a clear error",
		Raises(o, "o.StringUppercased(5)") != "", 1)
	Then("a list raises too, instead of answering empty text", Raises(o, "o.StringLowercased([ 1 ])") != "", 1)
	Then("the object still works afterwards", o.StringUppercased("ok"), "OK")
EndScenario()

Summary()

func Raises(o, cCode)
	try
		eval(cCode)
		return ""
	catch
		return cCatchError
	done
