load "../../stzBase.ring"
load "../_narrated.ring"

# stzLocale -- WHICH LANGUAGE A LOCALE IS IN.
#
# Found by running the library's own recorded expectations. Test files here
# carry lines like
#
#     ? NativeNthDayOfWeek(1)   #--> السبت
#
# and nothing had ever compared them to what the method returns. It returned
# "Monday".
#
# LanguageName() derived the language from the COUNTRY alone, which got two
# different things wrong:
#
#   en-PW      answered "palauan". Palau's primary language is Palauan, and the
#              "en" in the locale was never consulted at all.
#
#   ar_ARAB    answered NOTHING. A locale selected by SCRIPT has no country, so
#              the chain fell off its end and returned NULL. _DayNameInLang read
#              that as "language unknown" and silently answered from its first
#              table entry -- English. Hence "Monday" for an Arabic locale, and
#              "Mon" from the abbreviation.
#
# _LangNameFromCode, which resolves a code against $aLocaleLanguagesXT, had been
# sitting in the same file the whole time with no caller.

pr()

Scenario("The language comes from the language, not from the country")

	Given("English as spoken in Palau")
	oPW = new stzLocale("en-PW")

	Then("the country is still Palau", oPW.CountryName(), "palau")
	Then("...but the language is English", oPW.LanguageName(), "english")

	# THE NEGATIVE SIBLING: the country is not ignored, it is the FALLBACK. A
	# locale naming a country but no language this library knows is still better
	# answered by that country's language than by nothing at all.
	Given("a locale whose language code is in no table")
	oZZ = new stzLocale("zz-FR")
	Then("the country answers for it", oZZ.LanguageName(), "french")

	# ...and when neither can answer, it says so rather than guessing English.
	Given("a locale with neither a known language nor a country")
	Then("an unresolvable code gives nothing", _LangNameFromCode("zz"), "")
EndScenario()

Scenario("A locale chosen by SCRIPT still knows its language")

	# This is the one that produced English day names. No country means the old
	# chain returned NULL, and NULL meant "fall back to the first language in
	# the table".

	Given("the Arabic script, with no country named")
	oAr = new stzLocale("ar_ARAB")
	Then("it resolves its language", oAr.LanguageName(), "arabic")

	# Day ONE of an ar_EG week is SATURDAY, not Monday -- Egypt is one of the
	# seventeen CLDR firstDay=sat territories, and _LocaleFirstDayNumber used
	# to list only Afghanistan and Iran. These assertions named Monday before
	# that was fixed.
	Given("the same locale reached the way a caller writes it")
	StzLocaleQ([ :Script = :Arabic ]) {
		Then("the native day name is NATIVE", NativeNthDayOfWeek(1), "السبت")
		Then("...and so is the abbreviation", StzLeft(NativeNthDayOfWeekAbbreviation(1), 2), "ال")
	}

	# THE NEGATIVE SIBLING, and the one that makes the two above mean something:
	# the ENGLISH day name must still be English. A fix that simply returned
	# Arabic everywhere would satisfy them both.
	Then("the English name is untouched", StzLocaleQ([ :Script = :Arabic ]).NthDayOfWeek(1), "saturday")

	# ...and the SECOND sibling, which pins the rotation rather than the
	# constant: Monday has not vanished, it has moved to where an ar_EG week
	# puts it. Asserting only day 1 would pass against a locale stuck on any
	# single day.
	Then("Monday is still in the week, three days along",
	     StzLocaleQ([ :Script = :Arabic ]).NthDayOfWeek(3), "monday")
	Then("...and its native name agrees",
	     StzLocaleQ([ :Script = :Arabic ]).NativeNthDayOfWeek(3), "الاثنين")

	# The English and native faces must name the SAME day at every index --
	# the inconsistency that started this: abbreviation said Mon while the
	# day said Sat.
	Then("English and native abbreviations agree on the day",
	     StzLeft(StzLocaleQ([ :Script = :Arabic ]).NthDayOfWeekAbbreviation(1), 3), "Sat")
EndScenario()

Scenario("The week starts where the locale says, and rotates from there")

	# The rotation reads a hardcoded English week to find where to start. Two of
	# its seven days were MISSPELLED -- :tuesady and :thirsday -- in five
	# copy-pasted copies of the same list, so a locale beginning on either would
	# have found nothing and opened its week with an empty day. No locale in the
	# data does, which is why it never showed; the list is spelled correctly now
	# in all five.

	Given("locales that start their week on different days")
	Then("the United States starts on Sunday", LocaleFirstDay("en_US"), "sunday")
	Then("Iran starts on Saturday", LocaleFirstDay("fa_IR"), "saturday")
	Then("France starts on Monday", LocaleFirstDay("fr_FR"), "monday")

	# Whatever the start, a week has seven days and none of them is blank --
	# which is exactly what a failed lookup in that list used to produce.
	Then("a US week is seven real days", SevenRealDays("en_US"), TRUE)
	Then("...an Iranian week too", SevenRealDays("fa_IR"), TRUE)
	Then("...and an Egyptian one", SevenRealDays("ar_EG"), TRUE)
EndScenario()

Scenario("What the native names still cannot do")

	# Pinned rather than glossed. The native day-name table carries ELEVEN
	# languages. A locale in any other one falls back to English, so a
	# "native" name can still be an English word. That is a missing
	# translation, not a resolution bug, and it is the only way this fallback
	# can fire: an unresolved LANGUAGE no longer reaches it.
	#
	# Persian used to be the example here. It is carried now, so the gap is
	# demonstrated with a language that genuinely is not -- otherwise this
	# scenario would quietly stop testing anything the day a translation
	# lands.

	Given("Persian, which the table now carries")
	oFa = new stzLocale("fa_IR")
	Then("the language itself resolves", oFa.LanguageName(), "persian")
	Then("...and its first day is Saturday, as Iran counts it", oFa.NthDayOfWeek(1), "saturday")
	Then("...named in Persian, not English", oFa.NativeNthDayOfWeek(1), "شنبه")

	Given("Swahili, which the table does not carry")
	oSw = new stzLocale([ :Language = :swahili ])
	Then("the language itself resolves", oSw.LanguageName(), "swahili")
	Then("...but the native day name falls back to English (documented gap)",
	     StzFindFirst(oSw.NativeNthDayOfWeek(1), "MondayTuesdayWednesdayThursdayFridaySaturdaySunday") > 0, TRUE)

	# ...while a language the table DOES carry is answered properly, which is
	# what tells a missing translation apart from a broken lookup.
	oEg = new stzLocale("ar_EG")
	Then("Arabic, which it carries, is native", oEg.NativeNthDayOfWeek(1), "السبت")
EndScenario()

Summary()

pf()

#-- helpers --------------------------------------------------------------------

# Ring will not take a method call chained onto `new`, so the object is named
# first -- the same R13 that bit the timer guard.
func LocaleFirstDay(pcCode)
	_o_ = new stzLocale(pcCode)
	return _o_.FirstDayOfWeek()

func SevenRealDays(pcCode)
	_oL_ = new stzLocale(pcCode)
	_a_ = _oL_.NativeDaysOfWeek()
	if len(_a_) != 7
		return FALSE
	ok
	for _i_ = 1 to 7
		if ring_trim("" + _a_[_i_]) = ""
			return FALSE
		ok
	next
	return TRUE
