load "../../stzBase.ring"
load "../_narrated.ring"

# stzTablex -- the pattern parser and the checks.
# The parser slices with a start and an END position and @StzMid takes a COUNT: until the fix every slice was
# wrong, so a pattern parsed into a token of the right type with no value and Match answered FALSE (or raised)
# for about 90 patterns. Each scenario states what the pattern does AFTER the fix.

oT = new stzTable([
	[ :ID, :NAME, :AGE, :CITY ],
	[ 1, "Ali", 28, "Niamey" ],
	[ 2, "Sara", 32, "Paris" ],
	[ 3, "Omar", 41, "Niamey" ],
	[ 4, "Awa", 25, "Dakar" ]
])
oS = new stzTable([
	[ :KEY, :LABEL ],
	[ 1, "Ant" ],
	[ 2, "Bee" ],
	[ 3, "Cat" ]
])

Scenario("Parsing: the type, the value and the constraints of a token")
	aTok = TxTokens("{cols(3)}")
	Then("one token", len(aTok), 1)
	Then("of type cols", aTok[1][1][2], "cols")
	Then("with the number as an exact constraint", @@(aTok[1][3][2]), '[ [ [ "type", "exact" ], [ "value", 3 ] ] ]')
	Then("a comparison is a constraint of its own kind", @@(TxTokens("{cols(>3)}")[1][3][2]), '[ [ [ "type", "greater" ], [ "value", 3 ] ] ]')
	aAnd = TxTokens("{cols(2) & rows(3)}")
	Then("an & pattern is one conjunction", aAnd[1][1][2], "conjunction")
	Then("of two conditions", len(aAnd[1][2][2]), 2)
	Then("the second is a rows token", aAnd[1][2][2][2][1][2], "rows")
	Then("whose exact constraint is 3", "" + aAnd[1][2][2][2][3][2][1][2][2], "3")
	Then("an | pattern is an alternation", TxTokens("{cols(2) | rows(3)}")[1][1][2], "alternation")
	aU = TxTokens("{unique(name)}")
	Then("a column name keeps no trailing bracket", aU[1][2][2], "name")
	Then("a negated token is marked", TxTokens("{@!cols(3)}")[1][6][2], 1)
EndScenario()

Scenario("Counting rows and columns")
	Then("cols(4) is the 4 columns of the table", TxMatch("{cols(4)}"), TRUE)
	Then("cols(3) is not", TxMatch("{cols(3)}"), FALSE)
	Then("rows(4) is the 4 data rows", TxMatch("{rows(4)}"), TRUE)
	Then("rows(5) is not", TxMatch("{rows(5)}"), FALSE)
	Then("cols(>3) holds for 4 columns", TxMatch("{cols(>3)}"), TRUE)
	Then("cols(<3) does not", TxMatch("{cols(<3)}"), FALSE)
	Then("a pattern of two constraints needs both", TxMatch("{cols(4) & rows(5)}"), FALSE)
	Then("and holds when both hold", TxMatch("{cols(4) & rows(4)}"), TRUE)
EndScenario()

Scenario("Columns: names, uniqueness, sorting, types")
	Then("hascol(name)", TxMatch("{hascol(name)}"), TRUE)
	Then("hascol(zip) is absent", TxMatch("{hascol(zip)}"), FALSE)
	Then("unique(id)", TxMatch("{unique(id)}"), TRUE)
	Then("unique(city) has Niamey twice", TxMatch("{unique(city)}"), FALSE)
	Then("sorted(id) is ascending", TxMatch("{sorted(id)}"), TRUE)
	Then("sorted(name) is not: Ali, Sara, Omar", TxMatch("{sorted(name)}"), FALSE)
	Then("numeric(age)", TxMatch("{numeric(age)}"), TRUE)
	Then("numeric(name) is not", TxMatch("{numeric(name)}"), FALSE)
	Then("alphabetic(name)", TxMatch("{alphabetic(name)}"), TRUE)
	Then("alphabetic(age) is not", TxMatch("{alphabetic(age)}"), FALSE)
EndScenario()

Scenario("Values: contains, sums, averages, bounds")
	Then("contains(Ali) anywhere", TxMatch("{contains(Ali)}"), TRUE)
	Then("contains(Zed) nowhere", TxMatch("{contains(Zed)}"), FALSE)
	Then("contains(28) finds a number cell (it used to raise)", TxMatch("{contains(28)}"), TRUE)
	Then("contains(99) does not", TxMatch("{contains(99)}"), FALSE)
	Then("cell(25..45) holds when a number cell lies in the range", TxMatch("{cell(25..45)}"), TRUE)
	Then("cell(90..99) does not", TxMatch("{cell(90..99)}"), FALSE)
	Then("cell({Ali;Zed}) holds when a cell equals one of the set", TxMatch("{cell({Ali;Zed})}"), TRUE)
	Then("cell({Zed;Yan}) does not", TxMatch("{cell({Zed;Yan})}"), FALSE)
	Then("sumcol(age:>100) holds: 126", TxMatch("{sumcol(age:>100)}"), TRUE)
	Then("sumcol(age:>200) does not", TxMatch("{sumcol(age:>200)}"), FALSE)
	Then("avgcol(age:>30) holds: 31.5", TxMatch("{avgcol(age:>30)}"), TRUE)
	Then("avgcol(age:>40) does not", TxMatch("{avgcol(age:>40)}"), FALSE)
	Then("mincol(age:>20) holds: 25", TxMatch("{mincol(age:>20)}"), TRUE)
	Then("maxcol(age:<50) holds: 41", TxMatch("{maxcol(age:<50)}"), TRUE)
EndScenario()

Scenario("Combining: & | and @!")
	Then("and", TxMatch("{cols(4) & unique(id)}"), TRUE)
	Then("or: the second holds", TxMatch("{cols(9) | unique(id)}"), TRUE)
	Then("or: neither holds", TxMatch("{cols(9) | rows(9)}"), FALSE)
	Then("not: @!cols(3) holds for 4 columns", TxMatch("{@!cols(3)}"), TRUE)
	Then("not: @!cols(4) does not", TxMatch("{@!cols(4)}"), FALSE)
EndScenario()

Scenario("The pattern as data")
	oX = new stzTablex("{cols(4) & rows(4)}")
	Then("Pattern keeps the braces", oX.Pattern(), "{cols(4) & rows(4)}")
	Then("a pattern of terms joined by & is ONE token, a conjunction", oX.NumberOfTokens(), 1)
	Then("CountTokens agrees", oX.CountTokens(), 1)
EndScenario()

Scenario("Comparisons are strict, and >= and <= are the at-least and at-most forms")
	Then("cols(>4) is false for exactly 4 columns", TxMatch("{cols(>4)}"), FALSE)
	Then("cols(<4) is false for exactly 4 columns", TxMatch("{cols(<4)}"), FALSE)
	Then("cols(>=4) holds", TxMatch("{cols(>=4)}"), TRUE)
	Then("cols(<=4) holds", TxMatch("{cols(<=4)}"), TRUE)
	Then("rows(>=5) does not", TxMatch("{rows(>=5)}"), FALSE)
	Then("rows(<=4) holds", TxMatch("{rows(<=4)}"), TRUE)
EndScenario()

Scenario("A name that does not exist, and terms without parentheses, do not raise")
	Then("sorted(zzz) is false for a missing column", TxMatch("{sorted(zzz)}"), FALSE)
	Then("unique(zzz) is false for a missing column", TxMatch("{unique(zzz)}"), FALSE)
	Then("property(zzz) is false for an unknown property", TxMatch("{property(zzz)}"), FALSE)
	Then("property(nonempty) holds", TxMatch("{property(nonempty)}"), TRUE)
	Then("{cols} with no parentheses parses and does not match", TxMatch("{cols}"), FALSE)
EndScenario()

Scenario("Rows, regex columns, completeness")
	Then("row(2,Sara,32,Paris) is a row of the table", TxMatch("{row(2,Sara,32,Paris)}"), TRUE)
	Then("row(2,Sara,32,Dakar) is not", TxMatch("{row(2,Sara,32,Dakar)}"), FALSE)
	Then("row(1,ali,28,niamey) ignores the case", TxMatch("{row(1,ali,28,niamey)}"), TRUE)
	Then("colpattern(name:^[A-Z][a-z]+$) holds for capitalised names", TxMatch("{colpattern(name:^[A-Z][a-z]+$)}"), TRUE)
	Then("colpattern(name:^[a-z]+$) does not", TxMatch("{colpattern(name:^[a-z]+$)}"), FALSE)
	Then("completeness(name:90) holds for a full column", TxMatch("{completeness(name:90)}"), TRUE)
EndScenario()

Scenario("The case, and the sequence")
	oK = new stzTable([ [ :K ], [ "a" ], [ "A" ] ])
	oU = new stzTablex("{unique(k)}")
	oUc = new stzTablex("{@cs:unique(k)}")
	oSo = new stzTablex("{sorted(k)}")
	oSc = new stzTablex("{@cs:sorted(k)}")
	Then("unique ignores the case: a and A repeat", oU.Match(oK), FALSE)
	Then("@cs: makes them two values", oUc.Match(oK), TRUE)
	Then("sorted ignores the case: a, A is in order", oSo.Match(oK), TRUE)
	Then("@cs: puts a after A, so a, A is not in order", oSc.Match(oK), FALSE)
	oSeq = new stzTablex("{cols(4) -> rows(4)}")
	Then("terms joined by -> are one token each", oSeq.NumberOfTokens(), 2)
	Then("and all must hold", oSeq.Match(oT), TRUE)
	oSeq2 = new stzTablex("{cols(4) -> rows(5)}")
	Then("one failing term fails the sequence", oSeq2.Match(oT), FALSE)
	Then("a non-text pattern raises", TxRaises(12), TRUE)
EndScenario()

Scenario("What reads as a number")
	oN = new stzTablex("{cols(1)}")
	Then("an integer", oN.IsNumeric("123"), TRUE)
	Then("a decimal", oN.IsNumeric("1.5"), TRUE)
	Then("a negative", oN.IsNumeric("-3"), TRUE)
	Then("1-2 is not a number (a range is not one)", oN.IsNumeric("1-2"), FALSE)
	Then("1.2.3 is not", oN.IsNumeric("1.2.3"), FALSE)
	Then("a lone minus is not", oN.IsNumeric("-"), FALSE)
	Then("empty is not", oN.IsNumeric(""), FALSE)
	Then("rows(2-5) is parsed without raising, as no constraint", len(TxTokens("{rows(2-5)}")[1][3][2]), 0)
EndScenario()

Scenario("Building patterns from patterns")
	oA = new stzTablex("{cols(4)}")
	oB = new stzTablex("{rows(4)}")
	oAnd = oA.And_(oB)
	Then("And_ joins with & and keeps the braces", oAnd.Pattern(), "{cols(4) & rows(4)}")
	Then("the joined pattern matches", oAnd.Match(oT), TRUE)
	oOr = oA.Or_(oB)
	Then("Or_ joins with |", oOr.Pattern(), "{cols(4) | rows(4)}")
	oNot = oA.Not_()
	Then("Not_ puts @! in front", oNot.Pattern(), "{@!cols(4)}")
	Then("and negates", oNot.Match(oT), FALSE)
	aParts = oA.SplitByOperator("a->b->(c->d)", "->")
	Then("SplitByOperator splits outside brackets only", len(aParts), 3)
	Then("and keeps a bracketed part whole", aParts[3], "(c->d)")
EndScenario()

Scenario("The parts of a match, and the tables that match")
	oM = new stzTablex("{cols(4) & rows(4)}")
	oM.Match(oT)
	Then("CountMatchedParts counts the recorded parts", oM.CountMatchedParts(), 4)
	Then("HowManyMatchedParts agrees", oM.HowManyMatchedParts(), 4)
	Then("MatchingTables keeps the table that matches", len(oM.MatchingTables([ oT, oS ])), 1)
	Then("CountMatchingTables counts it", oM.CountMatchingTables([ oT, oS ]), 1)
EndScenario()

Summary()

func TxMatch(cPattern)
	oX = new stzTablex(cPattern)
	return oX.Match(oT)

func TxTokens(cPattern)
	oX = new stzTablex(cPattern)
	return oX.Tokens()

func TxRaises(x)
	try
		oX = new stzTablex(x)
		return FALSE
	catch
		return TRUE
	done
