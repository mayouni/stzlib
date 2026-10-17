load "../../stzBase.ring"
load "../_narrated.ring"

# stzListProvidedAsString -- the six rows of the register (DEFECTS.md) and the splitter under them.
#
# Before: Items answered [ ] for every text (init split an empty text), IsListOfValues and
# ContainsOnlyValues raised R12 (they read This.List), and the four other tests were empty stubs
# answering "". Run from inside test/list.
#
# What a value, a variable name and "other" are, and the answers for the empty list and for a text
# that is not a list, are stated in the class header; every one is pinned here with a text that
# must answer 1 and a sibling that must answer 0. Accented and Hebrew items are built from char
# codes and never printed.

cLpE = char(195) + char(169)                           # e acute
cLpH = char(215) + char(144) + char(215) + char(145)   # alef bet
cLpQ = char(34)                                        # "
cLpA = char(39)                                        # '
cLpB = char(96)                                        # `
cLpBs = char(92)                                       # backslash

Scenario("A list of values: numbers, quoted texts, nested lists")
	cT = '[ 1, 2, "A", [ 5, "V" ] , [ :name = "Mansour", :job = "Programmer" ] ]'
	o = new stzListProvidedAsString(cT)
	Then("the text is well formed", o.IsWellFormed(), 1)
	Then("it has five items (the commas inside the nested lists do not cut)", len(o.Items()), 5)
	Then("the fourth item is the nested list as written", LpSame(o.Items()[4], '[ 5, "V" ]'), 1)
	Then("the fifth keeps its inner spaces and commas",
		LpSame(o.Items()[5], '[ :name = "Mansour", :job = "Programmer" ]'), 1)
	Then("the quoted item keeps its quotes", LpSame(o.Items()[3], '"A"'), 1)
	Then("all five are values", LpKinds(cT), "value value value value value")
	Then("IsListOfValues answers 1 (it raised R12)", o.IsListOfValues(), 1)
	Then("ContainsOnlyValues answers 1 (it raised R12)", o.ContainsOnlyValues(), 1)
	Then("IsListOfVariables answers 0, not an empty text", o.IsListOfVariables(), 0)
	Then("ContainsOnlyVariables answers 0, not an empty text", o.ContainsOnlyVariables(), 0)
	Then("IsListOfValuesAndVariables answers 0, not an empty text", o.IsListOfValuesAndVariables(), 0)
	Then("ContainsValuesAndVariables answers 0, not an empty text", o.ContainsValuesAndVariables(), 0)
	Then("the six answers are all numbers", isNumber(o.IsListOfVariables()) and isNumber(o.ContainsValuesAndVariables()), 1)
EndScenario()

Scenario("A list of variable names")
	cT = "[ n1, n2, aList1, oObj1 ]"
	o = new stzListProvidedAsString(cT)
	Then("four items", len(o.Items()), 4)
	Then("the items are the names", LpItems(cT), "n1|n2|aList1|oObj1")
	Then("all four are variables", LpKinds(cT), "variable variable variable variable")
	Then("IsListOfVariables answers 1 (it answered an empty text)", o.IsListOfVariables(), 1)
	Then("ContainsOnlyVariables answers 1 (it answered an empty text)", o.ContainsOnlyVariables(), 1)
	Then("IsListOfValues answers 0 (it raised R12)", o.IsListOfValues(), 0)
	Then("ContainsOnlyValues answers 0 (it raised R12)", o.ContainsOnlyValues(), 0)
	Then("IsListOfValuesAndVariables answers 0", o.IsListOfValuesAndVariables(), 0)
	Then("ContainsValuesAndVariables answers 0", o.ContainsValuesAndVariables(), 0)
EndScenario()

Scenario("A mixed list holds both")
	cT = "[ x, y, 3 ]"
	o = new stzListProvidedAsString(cT)
	Then("kinds", LpKinds(cT), "variable variable value")
	Then("IsListOfValuesAndVariables answers 1 (it answered an empty text)", o.IsListOfValuesAndVariables(), 1)
	Then("ContainsValuesAndVariables answers 1 (it answered an empty text)", o.ContainsValuesAndVariables(), 1)
	Then("it is not a list of values", o.IsListOfValues(), 0)
	Then("it is not a list of variables", o.IsListOfVariables(), 0)
	Then("ContainsOnlyValues answers 0", o.ContainsOnlyValues(), 0)
	Then("ContainsOnlyVariables answers 0", o.ContainsOnlyVariables(), 0)
	Then("one value and one name is enough", LpSix("[ a, 1 ]"), "001001")
	Then("a quoted name is a value, not a name", LpSix('[ "x", y ]'), "001001")
	Then("two values and no name is not a mix", LpSix("[ 1, 2 ]"), "100100")
EndScenario()

Scenario("A nested list is one value, and its inside is not examined")
	Then("a list of lists of names is a list of values", LpSix("[ [ n1, n2 ], [ 1 ] ]"), "100100")
	Then("a name next to a nested list is a mix", LpSix("[ n1, [ 1 ] ]"), "001001")
	Then("a nested list of values and a name is a mix", LpSix("[ [ 1, 2 ], v ]"), "001001")
	Then("a nested list with a name inside does not make the outer a mix", LpSix("[ [ 1, x ], 2 ]"), "100100")
	Then("a deep nesting is still one item", LpCount("[ [ [ [ 1 ] ] ], 2 ]", "Items"), 2)
	Then("a single deep item is kept as written",
		LpSame(LpItems("[ [ [ [ 1 ] ] ] ]"), "[ [ [ 1 ] ] ]"), 1)
	Then("a list followed by something is not a list item",
		LpKinds("[ [ 1 ][ 1 ] ]"), "other")
EndScenario()

Scenario("The empty list: no value, no name, so all three tests answer 0")
	Then("the compact empty list is well formed", LpAsk("[]", "IsWellFormed"), 1)
	Then("it has no items", LpCount("[]", "Items"), 0)
	Then("and no kinds", LpCount("[]", "ItemKinds"), 0)
	Then("no test answers 1 for [] (a list of values needs a value)", LpSix("[]"), "000000")
	Then("nor for [ ] with spaces", LpSix("[ ]"), "000000")
	Then("nor for brackets around spaces, tabs and new lines",
		LpSix("[" + char(9) + " " + char(10) + char(13) + "]"), "000000")
	Then("a one-item list is not empty", LpSix("[ 1 ]"), "100100")
	Then("a one-name list is not empty", LpSix("[ a ]"), "010010")
	Then("an empty list is well formed, unlike an empty text", LpAsk("", "IsWellFormed"), 0)
EndScenario()

Scenario("A text that is not a list: not well formed, no items, every test 0")
	aBad = [ "", "   ", "1, 2", "[ 1, 2", "1, 2 ]", "[ 1, 2 ] 3", "3 [ 1 ]", "[ 1, 2 ]]", "[[ 1, 2 ]",
	         "[ 1,, 2 ]", "[ , 1 ]", "[ , ]", "[ 1, 2 )", "( 1, 2 )", "{ 1, 2 }", "[ 1, ( 2 ]",
	         '[ "abc ]', "[ 'abc ]", "[ `abc ]", '[ "C:' + cLpBs + 'dir' + cLpBs + '"x" ]' ]
	nOk = 0
	nItems = 0
	nWF = 0
	cWhich = ""
	for i = 1 to len(aBad)
		o = new stzListProvidedAsString(aBad[i])
		nWF += o.IsWellFormed()
		nItems += len(o.Items()) + len(o.ItemKinds())
		if LpSame(LpSix(aBad[i]), "000000") = 1
			nOk++
		else
			cWhich += "" + i + " "
		ok
	next
	Then("none of the " + len(aBad) + " malformed texts is well formed", nWF, 0)
	Then("none has an item", nItems, 0)
	Then("all of them answer 0 on all six tests (failing: " + cWhich + ")", nOk, len(aBad))
	Then("a number is not a list text", LpSix(5), "000000")
	Then("a list is not a list text", LpSix([ 1, 2 ]), "000000")
	Then("a well formed sibling answers 1", LpSix("[ 1, 2 ]"), "100100")
EndScenario()

Scenario("Quotes, brackets and commas inside quoted texts do not cut")
	cT = "[ " + cLpA + "a,b" + cLpA + ", " + cLpQ + "c]d" + cLpQ + ", " + cLpB + "e[f" + cLpB + ", " + cLpQ + "g'h" + cLpQ + " ]"
	o = new stzListProvidedAsString(cT)
	Then("four items", len(o.Items()), 4)
	Then("first, comma kept", LpSame(o.Items()[1], cLpA + "a,b" + cLpA), 1)
	Then("second, closing bracket kept", LpSame(o.Items()[2], cLpQ + "c]d" + cLpQ), 1)
	Then("third, backquote text with an opening bracket", LpSame(o.Items()[3], cLpB + "e[f" + cLpB), 1)
	Then("fourth, an apostrophe inside double quotes", LpSame(o.Items()[4], cLpQ + "g'h" + cLpQ), 1)
	Then("all four are values", LpKinds(cT), "value value value value")
	Then("so it is a list of values", o.IsListOfValues(), 1)
	cT2 = "[ " + cLpQ + "a b" + cLpQ + ", [ 1,   2 ] , x ]"
	Then("the inside of an item keeps its spaces; the ends are trimmed",
		LpSame(LpItems(cT2), cLpQ + "a b" + cLpQ + "|[ 1,   2 ]|x"), 1)
	Then("a quoted item with outer spaces inside the quotes keeps them",
		LpSame(LpItems("[" + cLpQ + "  p  " + cLpQ + "]"), cLpQ + "  p  " + cLpQ), 1)
	Then("a quoted bracket does not close the list: a stray one after it does",
		LpAsk("[ " + cLpQ + "]" + cLpQ + " ]", "IsWellFormed"), 1)
	Then("but the same bracket unquoted closes it early", LpAsk("[ ] ]", "IsWellFormed"), 0)
EndScenario()

Scenario("Ring has no string escapes: a backslash is an ordinary character")
	cT = "[ " + cLpQ + "C:" + cLpBs + "dir" + cLpBs + cLpQ + ", 2 ]"
	o = new stzListProvidedAsString(cT)
	Then("a text ending in a backslash is one whole text", len(o.Items()), 2)
	Then("its item is kept as written", LpSame(o.Items()[1], cLpQ + "C:" + cLpBs + "dir" + cLpBs + cLpQ), 1)
	Then("both are values", o.IsListOfValues(), 1)
	cT2 = "[ " + cLpQ + "a" + cLpBs + cLpQ + "b" + cLpQ + " ]"
	Then("a quote after a backslash closes the text, so the rest is unbalanced",
		LpAsk(cT2, "IsWellFormed"), 0)
	Then("a different quote inside is fine",
		LpAsk("[ " + cLpQ + "it" + cLpA + "s" + cLpQ + " ]", "IsListOfValues"), 1)
	Then("two quoted texts side by side are one item of kind other, not a value",
		LpKinds("[ " + cLpA + "x" + cLpA + " " + cLpQ + "y" + cLpQ + " ]"), "other")
EndScenario()

Scenario("Accented and Hebrew items")
	cT = "[ " + cLpQ + cLpE + "t" + cLpE + cLpQ + ", " + cLpA + cLpH + cLpA + ", [ " + cLpQ + cLpH + cLpQ + " ] ]"
	o = new stzListProvidedAsString(cT)
	Then("three items", len(o.Items()), 3)
	Then("the accented text is intact, bytes and all",
		LpSame(o.Items()[1], cLpQ + cLpE + "t" + cLpE + cLpQ), 1)
	Then("the Hebrew text is intact", LpSame(o.Items()[2], cLpA + cLpH + cLpA), 1)
	Then("the nested list holding Hebrew is intact", LpSame(o.Items()[3], "[ " + cLpQ + cLpH + cLpQ + " ]"), 1)
	Then("all values", o.IsListOfValues(), 1)
	Then("and not variables", o.IsListOfVariables(), 0)
	cV = "[ " + cLpE + "t" + cLpE + ", " + cLpH + ", n1 ]"
	ov = new stzListProvidedAsString(cV)
	Then("bare accented and Hebrew names are variables, as Ring reads them", LpKinds(cV), "variable variable variable")
	Then("so it is a list of variables", ov.IsListOfVariables(), 1)
	Then("and the bare accented name is kept whole", LpSame(ov.Items()[1], cLpE + "t" + cLpE), 1)
	Then("a Hebrew name next to a number mixes", LpSix("[ " + cLpH + ", 7 ]"), "001001")
	Then("a Hebrew letter in a text with a comma does not cut",
		LpSame(LpItems("[ " + cLpQ + cLpH + "," + cLpH + cLpQ + " ]"), cLpQ + cLpH + "," + cLpH + cLpQ), 1)
	Then("a multibyte letter after the closing bracket is not a list",
		LpAsk("[ 1 ]" + cLpE, "IsWellFormed"), 0)
EndScenario()

Scenario("What is a number")
	aYes = [ "0", "7", "-3", "+2", "2.5", "-0.5", "1e3", "1E3", "1.5e-2", "2e+4", "0x1F", "0Xff", "-0x10", "007" ]
	aNo = [ "1+2", "5abc", "1.", ".5", "1e", "1e+", "0x", "0xG", "- 5", "--5", "1.2.3", "1,5", "1_000" ]
	nYes = 0
	nNo = 0
	cYes = ""
	cNo = ""
	for i = 1 to len(aYes)
		if LpSame(LpKinds("[ " + aYes[i] + " ]"), "value") = 1
			nYes++
		else
			cYes += aYes[i] + " "
		ok
	next
	for i = 1 to len(aNo)
		if LpSame(LpKinds("[ " + aNo[i] + " ]"), "value") = 0
			nNo++
		else
			cNo += aNo[i] + " "
		ok
	next
	Then("every written number is a value (not: " + cYes + ")", nYes, len(aYes))
	Then("none of the look-alikes is a value (wrongly: " + cNo + ")", nNo, len(aNo))
	Then("5abc is not a number and not a name either: other", LpKinds("[ 5abc ]"), "other")
	Then("1+2 is an expression: other", LpKinds("[ 1+2 ]"), "other")
	Then("1,5 is two items", LpCount("[ 1,5 ]", "Items"), 2)
EndScenario()

Scenario("What is a variable name")
	aYes = [ "n1", "aList1", "oObj1", "_x", "x_1", "@x", "$g", "oObj.name", "a.b.c", "TRUE", "FALSE", "NULL" ]
	aNo = [ "1x", "a..b", "a.", ".a", "@", "$", "@1", "a-b", "a b", "f(x)", "a[1]", "x=1", "@@" ]
	nYes = 0
	nNo = 0
	cYes = ""
	cNo = ""
	for i = 1 to len(aYes)
		if LpSame(LpKinds("[ " + aYes[i] + " ]"), "variable") = 1
			nYes++
		else
			cYes += aYes[i] + " "
		ok
	next
	for i = 1 to len(aNo)
		if LpSame(LpKinds("[ " + aNo[i] + " ]"), "variable") = 0
			nNo++
		else
			cNo += aNo[i] + " "
		ok
	next
	Then("every bare name is a variable (not: " + cYes + ")", nYes, len(aYes))
	Then("none of the look-alikes is a variable (wrongly: " + cNo + ")", nNo, len(aNo))
	Then("TRUE, FALSE and NULL are names here: the text is not evaluated", LpSix("[ TRUE, FALSE, NULL ]"), "010010")
	Then("a number next to TRUE is a mix", LpSix("[ TRUE, 1 ]"), "001001")
EndScenario()

Scenario("A :name is a Ring text, so a value")
	Then(":name is a value", LpKinds("[ :name ]"), "value")
	Then("a list of :names is a list of values", LpSix("[ :a, :b ]"), "100100")
	Then(": alone is not a value", LpKinds("[ : ]"), "other")
	Then(":1 is not a value", LpKinds("[ :1 ]"), "other")
	Then(":a.b is not a value", LpKinds("[ :a.b ]"), "other")
	Then("a bare name is not a :name", LpKinds("[ name ]"), "variable")
EndScenario()

Scenario("Items of kind other: neither value nor variable")
	Then("an expression is other", LpKinds("[ 1+2, f(x), a[1] ]"), "other other other")
	Then("a comma inside parentheses does not cut", LpCount("[ f(1,2), g(3) ]", "Items"), 2)
	Then("a comma inside braces does not cut", LpCount("[ { 1, 2 }, 3 ]", "Items"), 2)
	Then("a pair written directly in the list is other", LpKinds("[ :name = " + cLpQ + "v" + cLpQ + " ]"), "other")
	Then("an other item keeps a list from being only values", LpSix("[ 1, 2+3 ]"), "000000")
	Then("an other item keeps a list from being only names", LpSix("[ a, f(x) ]"), "000000")
	Then("an other item does not prevent a mix", LpSix("[ 1, n1, 2+3 ]"), "001001")
	Then("an other item alone is no mix", LpSix("[ 2+3 ]"), "000000")
EndScenario()

Scenario("Whitespace, trailing comma, and independence of objects")
	cNl = char(10)
	cT = "  [" + cNl + char(9) + "1 ," + cNl + "  x" + char(13) + cNl + " ]  "
	o = new stzListProvidedAsString(cT)
	Then("spaces, tabs and new lines around items and the list are free", LpItems(cT), "1|x")
	Then("and the list is a mix", o.IsListOfValuesAndVariables(), 1)
	Then("a single trailing comma is accepted, as Ring does", LpItems("[ 1, 2, ]"), "1|2")
	Then("two trailing commas are not", LpAsk("[ 1, 2,, ]", "IsWellFormed"), 0)
	Then("a leading comma is not", LpAsk("[ ,1 ]", "IsWellFormed"), 0)
	o1 = new stzListProvidedAsString("[ 1, 2 ]")
	o2 = new stzListProvidedAsString("[ a, b ]")
	Then("two objects do not share state: first", o1.IsListOfValues(), 1)
	Then("two objects do not share state: second", o2.IsListOfValues(), 0)
	Then("asking twice gives the same answer", o1.IsListOfValues(), 1)
	Then("asking in another order too", o2.IsListOfVariables() + o1.IsListOfVariables(), 1)
	Then("the text is kept as given", LpSame(o1.Items()[1], "1"), 1)
EndScenario()

Scenario("A longer list is read in one pass")
	cT = "["
	for i = 1 to 300
		if i > 1
			cT += ", "
		ok
		cT += "" + i
	next
	cT += "]"
	o = new stzListProvidedAsString(cT)
	Then("300 items", len(o.Items()), 300)
	Then("the last one is 300", LpSame(o.Items()[300], "300"), 1)
	Then("all values", o.IsListOfValues(), 1)
	cT = "[ v1"
	for i = 2 to 300
		cT += ", v" + i
	next
	cT += " ]"
	Then("300 names make a list of variables", LpAsk(cT, "IsListOfVariables"), 1)
	Then("and not a list of values", LpAsk(cT, "IsListOfValues"), 0)
EndScenario()

Summary()

# helpers: below the main code, because code after a func belongs to that func
# one object per text, all six answers, as a six-character string of 0/1
func LpSix(cText)
	o = new stzListProvidedAsString(cText)
	return "" + o.IsListOfValues() + o.IsListOfVariables() + o.IsListOfValuesAndVariables() +
	       o.ContainsOnlyValues() + o.ContainsOnlyVariables() + o.ContainsValuesAndVariables()

func LpItems(cText)
	o = new stzListProvidedAsString(cText)
	aI = o.Items()
	cOut = ""
	for i = 1 to len(aI)
		if i > 1
			cOut += "|"
		ok
		cOut += aI[i]
	next
	return cOut

func LpKinds(cText)
	o = new stzListProvidedAsString(cText)
	aK = o.ItemKinds()
	cOut = ""
	for i = 1 to len(aK)
		if i > 1
			cOut += " "
		ok
		cOut += aK[i]
	next
	return cOut

# case-sensitive text equality as 1/0 (= on texts folds case)
func LpSame(cA1, cB1)
	if strcmp(cA1, cB1) = 0
		return 1
	ok
	return 0

# one answer of one object, by method name
func LpAsk(cText, cMethod)
	o = new stzListProvidedAsString(cText)
	if strcmp(cMethod, "IsWellFormed") = 0
		return o.IsWellFormed()
	ok
	if strcmp(cMethod, "IsListOfValues") = 0
		return o.IsListOfValues()
	ok
	if strcmp(cMethod, "IsListOfVariables") = 0
		return o.IsListOfVariables()
	ok
	return "unknown method " + cMethod

# the number of items or of kinds
func LpCount(cText, cMethod)
	o = new stzListProvidedAsString(cText)
	if strcmp(cMethod, "Items") = 0
		return len(o.Items())
	ok
	return len(o.ItemKinds())
