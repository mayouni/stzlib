# Narrative
# ---------
# A FACULTY MEASURED PER LANGUAGE (base/faculty/, ruled by the author 2026-10-30, OCR-PERLANG-01). When a faculty
# names the input field that holds a golden's language (SetGoldenLanguageKey), RunGoldens files one measurement per
# language beside the whole-set one (golden version "v1/fr"), and a call that names one language is resolved on
# that language's measurements alone: the floor's bar and every model's score come from the same language. So a
# model can answer one language while the floor keeps another. A call with no language, or a language the golden
# set has no items in, is judged on the whole set -- and the plan says which.
#
# The rule came from :ocr, where the platform engine wins Arabic, the PP-OCR model wins Russian and French is a
# tie; this guard needs no engine and no model file: the "implementations" are Ring functions of known quality.
#
# The task: say a greeting's language back in capitals. Six golden items, two per language:
#   floor   right in English and German, wrong in French       (4 of 6)
#   model   right in English and French, wrong in German       (4 of 6)
# On the whole set they TIE, so the floor answers a call with no language. Per language: English ties (floor),
# French goes to the model, German stays with the floor.
#
#   cd libraries/stzlib/base/test/faculty ; rnxc faculty_perlang_narrated.ring

load "../../stzBase.ring"
load "../_narrated.ring"

StzClearMeasurements()
StzClearModelTrace()
StzClearParcelMemo()

aGold = [ [ [ :text = "hello", :lang = "en-GB" ], "HELLO" ], [ [ :text = "good morning", :lang = "en-US" ], "GOOD MORNING" ],
          [ [ :text = "bonjour", :lang = "fr-FR" ], "BONJOUR" ], [ [ :text = "salut", :lang = "fr-FR" ], "SALUT" ],
          [ [ :text = "hallo", :lang = "de-DE" ], "HALLO" ], [ [ :text = "guten tag", :lang = "de-DE" ], "GUTEN TAG" ] ]

Scenario("A faculty is declared as measured per language")
	oF = StzFacultyQ(:shout)
	oF.SetInputTypeQ(:record).SetOutputTypeQ(:text).SetFloorQ("rule", "_PlFloor").
	   SetGoldenCheckerQ("exact").SetGoldenVersionQ("v1").SetGoldenLanguageKeyQ(:lang)
	oF.AddImplementation([ :id = "learned", :kind = "graph", :fn = "_PlModel", :licence = "mit" ])
	nG = len(aGold)
	for i = 1 to nG
		oF.AddGolden(aGold[i][1], aGold[i][2])
	next
	Then("the language key is recorded", oF.GoldenLanguageKey(), "lang")
	Then("a golden's language is the two-letter code of its :lang", StzGoldenLanguageOf(:shout, aGold[3][1], []), "fr")
	Then("the call's parameters name it first", StzGoldenLanguageOf(:shout, aGold[3][1], [ :lang = "de-DE" ]), "de")
	Then("a faculty with no key has no golden language", StzGoldenLanguageOf(:nosuchfaculty, aGold[3][1], []), "")
EndScenario()

Scenario("RunGoldens files the whole-set measurement and one per language")
	aRows = StzModelRegistryQ().RunGoldens(:shout)
	oReg = StzModelRegistryQ()
	Then("the rows returned are the whole-set ones, one per implementation", len(aRows), 2)
	Then("on the whole set the floor scores 4 of 6", oReg.MeasurementOf(:shout, "rule")[:score] * 6, 4)
	Then("and so does the model", oReg.MeasurementOf(:shout, "learned")[:score] * 6, 4)
	Then("per language, the floor: English 1, French 0, German 1",
	     @@([ oReg.MeasurementOfIn(:shout, "rule", "en")[:score], oReg.MeasurementOfIn(:shout, "rule", "fr")[:score], oReg.MeasurementOfIn(:shout, "rule", "de")[:score] ]), @@([ 1, 0, 1 ]))
	Then("the model: English 1, French 1, German 0",
	     @@([ oReg.MeasurementOfIn(:shout, "learned", "en")[:score], oReg.MeasurementOfIn(:shout, "learned", "fr")[:score], oReg.MeasurementOfIn(:shout, "learned", "de")[:score] ]), @@([ 1, 1, 0 ]))
	Then("each language row counts its own items", oReg.MeasurementOfIn(:shout, "learned", "fr-FR")[:n], 2)
	Then("a language measured is filed under <version>/<lang>", StzMeasurementOf(:shout, "learned", "v1/fr")[:score], 1)
EndScenario()

Scenario("The registry chooses per language, and says on what it judged")
	oReg = StzModelRegistryQ()
	oP = oReg.ResolveQ(StzRequirementQ(:shout).RequireLanguagesQ([ "fr" ]))
	Then("French goes to the model: it beats the floor on the French items", oP.Chosen(), "learned")
	Then("and the plan says it judged on them", StzFindFirst("judged on the 'fr' items", oP.Why()) > 0, 1)
	oP = oReg.ResolveQ(StzRequirementQ(:shout).RequireLanguagesQ([ "de" ]))
	Then("German stays with the floor", oP.Chosen(), "rule")
	oP = oReg.ResolveQ(StzRequirementQ(:shout).RequireLanguagesQ([ "en" ]))
	Then("English stays with the floor: a tie is not strictly better", oP.Chosen(), "rule")
	oP = oReg.ResolveQ(StzRequirementQ(:shout))
	Then("with no language, the whole set decides: a tie, so the floor", oP.Chosen(), "rule")
	oP = oReg.ResolveQ(StzRequirementQ(:shout).RequireLanguagesQ([ "it" ]))
	Then("a language with no items is judged on the whole set", oP.Chosen(), "rule")
	Then("and the plan says so", StzFindFirst("has no measured 'it' items", oP.Why()) > 0, 1)
EndScenario()

Scenario("A call takes its language from its input, and the chosen implementation answers it")
	oF = StzFacultyQ(:shout)
	Then("a French input is answered by the model", oF.Run([ :text = "merci", :lang = "fr-CA" ], []), "MERCI")
	Then("a German input by the floor", oF.Run([ :text = "danke", :lang = "de-AT" ], []), "DANKE")
	Then("the parameters' language wins over the input's: French named, the model answers",
	     oF.RunQ([ :text = "danke", :lang = "de-AT" ], [ :lang = "fr-FR" ]).Chain()[1], "shout:learned")
	aT = StzModelTrace()
	Then("every resolution is in the trace", len(aT) >= 3, 1)
EndScenario()

Summary()

# the floor: right unless the text is French (it lowercases French by mistake)
func _PlFloor(paIn, paParams)
	if lower(left(paIn[:lang], 2)) = "fr" return lower(paIn[:text]) ok
	return upper(paIn[:text])

# the model: right unless the text is German
func _PlModel(paIn, paParams)
	if lower(left(paIn[:lang], 2)) = "de" return paIn[:text] ok
	return upper(paIn[:text])
