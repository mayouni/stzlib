load "../../stzBase.ring"
load "../_narrated.ring"

# DOCREFORM -- derived briefs for the GENERATED families (meta/stzDocExport.ring, _StzDocGenBrief).
# Four classes are largely machine-made forwarders (stzObject's XB / XQC / XN / XNB, stzQuestion's XQ,
# stzListNamedParams' Is...NamedParam). The exporter derives a brief from the executor and the name, labels it
# `derived`, and it must still pass the form and the not-restating checks. The functions are PURE: names and
# forward arguments in, brief out, so this runs on made-up names in milliseconds.

Scenario("The executor says the family, the name says the words")
	Then("_NNLValueIs is the value family", _StzDocGenKind("_NNLValueIs"), "value")
	Then("_NNLImmutable is the chainable-copy family", _StzDocGenKind("_NNLImmutable"), "immutable")
	Then("_NNLNounCount is the count family", _StzDocGenKind("_NNLNounCount"), "count")
	Then("_NNLCountIs is the count-agreement family", _StzDocGenKind("_NNLCountIs"), "countis")
	Then("_Noun is the question-noun family", _StzDocGenKind("_Noun"), "noun")
	Then("any other forward is no family", _StzDocGenKind("Content"), "")
	Then("the suffix of the family is dropped from the words", _StzDocGenWords("FindAllExceptLastQC", "immutable"), "find all except last")
	Then("the B of a value test is dropped", _StzDocGenWords("ContainsPairsB", "value"), "contains pairs")
	Then("a name that does not end in the suffix keeps all its words", _StzDocGenWords("Which", "value"), "which")
	Then("the noun is the first string literal", _StzDocGenNoun([ char(34) + "numberofbytes" + char(34), "[ p1 ]" ]), "numberofbytes")
	Then("an argument that is not a literal gives no noun", _StzDocGenNoun([ "pcMethod" ]), "")
EndScenario()

Scenario("Each family writes a brief that passes the gate's form and restating checks")
	aV = _StzDocGenBrief("ContainsPairsB", "_NNLValueIs", [ char(34) + "containspairs" + char(34) ])
	Then("a value test is TRUE if ...", Left(aV[1], 7), "TRUE if")
	Then("and returns TRUE or FALSE", aV[2], "TRUE or FALSE.")
	Then("and passes checks 1 and 2", ScoreOk(aV[1], "ContainsPairsB"), TRUE)
	aI = _StzDocGenBrief("EveryNthItemQC", "_NNLImmutable", [ char(34) + "everynthitem" + char(34), "[ p1 ]" ])
	Then("a chainable action says it leaves the original alone", StzFindFirst("original is unchanged", aI[1]) > 0, TRUE)
	Then("and passes checks 1 and 2", ScoreOk(aI[1], "EveryNthItemQC"), TRUE)
	aN = _StzDocGenBrief("ByteN", "_NNLNounCount", [ char(34) + "numberofbytes" + char(34) ])
	Then("a count names the method it forwards to", StzFindFirst("numberofbytes()", aN[1]) > 0, TRUE)
	Then("and returns a number", aN[2], "a number.")
	Then("and passes checks 1 and 2", ScoreOk(aN[1], "ByteN"), TRUE)
	aC = _StzDocGenBrief("ByteNB", "_NNLCountIs", [ char(34) + "numberofbytes" + char(34) ])
	Then("a count agreement is TRUE if ...", Left(aC[1], 7), "TRUE if")
	Then("and passes checks 1 and 2", ScoreOk(aC[1], "ByteNB"), TRUE)
	aQ = _StzDocGenBrief("LengthQ", "_Noun", [ char(34) + "length" + char(34) ])
	Then("a question noun sets it on the current side", StzFindFirst("current side", aQ[1]) > 0, TRUE)
	Then("and passes checks 1 and 2", ScoreOk(aQ[1], "LengthQ"), TRUE)
	Then("a long name never pushes the brief past 140 characters",
		StzLen(_StzDocGenBrief("FindAllExceptLastOccurrencesInTheSecondHalfOfTheTextQC", "_NNLImmutable", [ char(34) + "x" + char(34), "[ p1 ]" ])[1]) <= 140, TRUE)
	Then("a forward whose noun is not a literal gets no derived brief", len(_StzDocGenBrief("XB", "_NNLValueIs", [ "pcMethod" ])), 0)
	Then("a method that forwards elsewhere gets none", len(_StzDocGenBrief("Content", "ContentFast", [ ])), 0)
EndScenario()

Scenario("Is...NamedParam: the keyword is the name, an Or makes two")
	Then("a plain keyword", _StzDocNamedParamKeys("IsOnPositionNamedParam")[1], "OnPosition")
	Then("one keyword only", len(_StzDocNamedParamKeys("IsOnPositionNamedParam")), 1)
	aT = _StzDocNamedParamKeys("IsOfOrInNamedParams")
	Then("Or between capitals splits into two", len(aT), 2)
	Then("the first is Of", aT[1], "Of")
	Then("the second is In", aT[2], "In")
	Then("an Or inside a word does not split (Order, Color)", len(_StzDocNamedParamKeys("IsOrderByNamedParam")), 1)
	Then("a lower-case or inside a word does not split", len(_StzDocNamedParamKeys("IsColorSetNamedParam")), 1)
	Then("the Options predicates are left to a hand-written block", len(_StzDocNamedParamKeys("IsBoxOptionsNamedParam")), 0)
	Then("OneOf... is left to a hand-written block", len(_StzDocNamedParamKeys("IsOneOfTheseNamedParams")), 0)
	Then("a lone A is no keyword", len(_StzDocNamedParamKeys("IsANamedParam")), 0)
	Then("a name that is not a named-param predicate gives none", len(_StzDocNamedParamKeys("IsEmpty")), 0)
	aB = _StzDocGenBrief("IsOnPositionNamedParam", "", [ ])
	Then("the brief says what the list must look like", StzFindFirst("a pair whose first item is the keyword :OnPosition", aB[1]) > 0, TRUE)
	Then("and passes checks 1 and 2", ScoreOk(aB[1], "IsOnPositionNamedParam"), TRUE)
	aL = _StzDocGenBrief("IsAfterSubstringsWXTOrAfterSubstringsWhereXTNamedParam", "", [ ])
	Then("a very long name falls back to a shorter brief within 140 characters", StzLen(aL[1]) <= 140, TRUE)
	Then("and that one passes too", ScoreOk(aL[1], "IsAfterSubstringsWXTOrAfterSubstringsWhereXTNamedParam"), TRUE)
EndScenario()

Summary()

func ScoreOk(cBrief, cName)
	aS = StzDocScoreOf(cBrief, cName)
	return aS[1] = 1 and aS[2] = 1
