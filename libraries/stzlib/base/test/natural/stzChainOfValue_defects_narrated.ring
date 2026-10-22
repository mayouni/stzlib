load "../../stzBase.ring"
load "../_narrated.ring"

# stzChainOfValue -- the register's three rows (IsANumber, IsAList, IsAnObject) and what they shared.
# Run from inside test/natural.
#
#   IsANumber   returned the chain itself whatever the value held, so it never said whether the value
#               was a number, and IsNotANumber (the negation of that chain) answered 0 for everything.
#   IsAList / IsAnObject   had an EMPTY body: the answer was an empty text.
#
# The convention is the one of the working sibling IsAString: a PLAIN 1 or 0, read from the type of
# the value (Ring's own type, so a numeric text such as "12" is a TEXT). The Q forms
# (IsANumberQ, IsAStringQ ...) are the fluent ones: they answer the chain and STOP it when the value
# is not of the type, so that a sentence goes on or does not.
#
# Further failures of the same shape, found by running every public method on a number, a text, a
# list and an object:
#   the type read once, at build time, so Update("abc") left a number chain answering "number";
#   StopChain() called with no reason in every Q form (error R19);
#   ToStzObject on a number raised (it handed the number to stzList), and so did _Which/_That/...;
#   Do_ returned nothing instead of the chain; ThisValue only worked for a number (the value was
#   used as the NAME of a variable); Update with a with/by/using pair read an undefined variable.
#
# The expectations are written by hand. Texts beyond ASCII are built from char codes and never
# printed. Every positive has a negative sibling.

eAc   = char(195) + char(169)                              # e acute
alef  = char(215) + char(144)                              # Hebrew alef
bet   = char(215) + char(145)
emo   = char(240) + char(159) + char(152) + char(128)      # grinning face
nBig  = 1
for i = 1 to 30
	nBig = nBig * 10
next

vNum  = 5
vTxt  = "abc"
vList = [ 1, 2, 3 ]
vObj  = new CvTiny
vNumTxt = "12"

Scenario("The register rows: IsANumber, IsAList and IsAnObject answer 1 or 0")
	Given("a chain over a number, a text, a list and an object")
	oN = new stzChainOfValue("vNum")
	oT = new stzChainOfValue("vTxt")
	oL = new stzChainOfValue("vList")
	oO = new stzChainOfValue("vObj")
	Then("IsANumber holds for the number", oN.IsANumber(), 1)
	Then("IsANumber does not hold for the text", oT.IsANumber(), 0)
	Then("IsANumber does not hold for the list", oL.IsANumber(), 0)
	Then("IsANumber does not hold for the object", oO.IsANumber(), 0)
	Then("IsAList holds for the list", oL.IsAList(), 1)
	Then("IsAList does not hold for the number", oN.IsAList(), 0)
	Then("IsAList does not hold for the text", oT.IsAList(), 0)
	Then("IsAList does not hold for the object", oO.IsAList(), 0)
	Then("IsAnObject holds for the object", oO.IsAnObject(), 1)
	Then("IsAnObject does not hold for the number", oN.IsAnObject(), 0)
	Then("IsAnObject does not hold for the text", oT.IsAnObject(), 0)
	Then("IsAnObject does not hold for the list", oL.IsAnObject(), 0)
	Then("the answer is a plain 1 or 0, not a chain", isNumber(oN.IsANumber()), 1)
	Then("and not a chain for IsAList either", isNumber(oL.IsAList()), 1)
	Then("nor for IsAnObject", isNumber(oO.IsAnObject()), 1)
	Then("IsNotANumber is 0 for the number", oN.IsNotANumber(), 0)
	Then("IsNotANumber is 1 for the text", oT.IsNotANumber(), 1)
	Then("IsNotANumber is 1 for the list", oL.IsNotANumber(), 1)
	Then("NotANumber is the same call", oN.NotANumber() = oN.IsNotANumber(), 1)
	Then("ANumber is the same call as IsANumber", oN.ANumber(), 1)
	Then("and answers 0 for the text", oT.ANumber(), 0)
EndScenario()

Scenario("A numeric text is a text; exactly one of the four type questions holds for every value")
	Given("eighteen values, among them numbers of every shape, texts beyond ASCII, lists and objects")
	aCases = Cases()
	nCases = len(aCases)
	Then("there are at least twelve values", nCases >= 12, 1)
	for i = 1 to nCases
		cMask = MaskOf(aCases[i][2])
		cWant = aCases[i][3]
		Then("partition mask of " + aCases[i][1] + " is " + cWant + " (number string list object)", cMask, cWant)
		nOnes = Ones(cMask)
		Then("and exactly one holds for " + aCases[i][1], nOnes, 1)
	next
	Then("12 as a number is a number", MaskOf(12), "1000")
	Then("12 as a text is a text, not a number", MaskOf("12"), "0100")
EndScenario()

Scenario("The verdict reads the type, not the identity: an object is an object whichever copy the chain holds")
	Given("a chain over an object, the object then changed and replaced")
	oX = new stzChainOfValue("vObj")
	Then("the chain over the object holds an object", oX.IsAnObject(), 1)
	vObj.x = 99
	oY = new stzChainOfValue("vObj")
	Then("a chain built after the object changed holds an object", oY.IsAnObject(), 1)
	Then("the chain built before still holds an object", oX.IsAnObject(), 1)
	oZ = oY.Copy()
	Then("a copy of the chain is an object chain", oZ.IsAnObject(), 1)
	Then("and is not a list", oZ.IsAList(), 0)
	vObj = [ 1 ]
	oW = oX.Copy()
	Then("after the variable became a list, a copy of the chain reads a list", oW.IsAList(), 1)
	Then("and no longer an object", oW.IsAnObject(), 0)
	Then("while the chain built before keeps the object it read", oX.IsAnObject(), 1)
	vObj = new CvTiny
EndScenario()

Scenario("The type follows Update (it was read once, at build time)")
	Given("a chain over a number, updated to a text, a list, an object and back")
	oU = new stzChainOfValue("vNum")
	Then("it starts as a number", oU.IsANumber(), 1)
	oU.Update("abc")
	Then("after Update with a text it is a text", oU.IsAString(), 1)
	Then("and is no longer a number", oU.IsANumber(), 0)
	oU.Update([ 1, 2 ])
	Then("after Update with a list it is a list", oU.IsAList(), 1)
	Then("and no longer a text", oU.IsAString(), 0)
	oU.UpdateWith(new CvTiny)
	Then("after UpdateWith an object it is an object", oU.IsAnObject(), 1)
	Then("and no longer a list", oU.IsAList(), 0)
	oU.UpdateBy(7)
	Then("after UpdateBy a number it is a number again", oU.IsANumber(), 1)
	Then("and not an object", oU.IsAnObject(), 0)
	oU.UpdateUsing("x")
	Then("UpdateUsing a text makes it a text", oU.IsAString(), 1)
	Then("the held value is read through Value", oU.Value(), "x")
	Then("the caller's variable was left as it was", vNum, 5)
	oU.Update([ :With, 7 ])
	Then("a with pair gives the second item, not an error (it read an undefined variable)", oU.Value(), 7)
	Then("so the chain is a number", oU.IsANumber(), 1)
	oU.Update([ 1, 7 ])
	Then("a list that is not a pair of that kind is kept whole", len(oU.Value()), 2)
	Then("and is a list", oU.IsAList(), 1)
EndScenario()

Scenario("The fluent forms stop the chain when the value is not of the type, and let it go on when it is")
	Given("chains over a number and a text")
	oA = new stzChainOfValue("vNum")
	r = oA.IsANumberQ()
	Then("IsANumberQ on a number answers the chain", lower(classname(r)), "stzchainofvalue")
	Then("and leaves it ongoing", oA.ChainStatus(), :ongoing)
	oB = new stzChainOfValue("vTxt")
	r = oB.IsANumberQ()
	Then("IsANumberQ on a text answers the chain (it raised R19)", lower(classname(r)), "stzchainofvalue")
	Then("and stops it", oB.ChainStatus(), :stopped)
	aWhy = oB.WhyChainStopped()
	Then("with the reason", aWhy[1], "Because the value is not a number!")
	oC = new stzChainOfValue("vTxt")
	oC.IsAStringQ()
	Then("IsAStringQ on a text leaves the chain ongoing", oC.ChainStatus(), :ongoing)
	oD = new stzChainOfValue("vNum")
	oD.IsAStringQ()
	Then("IsAStringQ on a number stops it", oD.ChainStatus(), :stopped)
	aWhy = oD.WhyChainStopped()
	Then("with the reason", aWhy[1], "Because the value is not a text!")
	oE = new stzChainOfValue("vNum")
	oE.IsNotANumberQ()
	Then("IsNotANumberQ on a number stops the chain", oE.ChainStatus(), :stopped)
	oF = new stzChainOfValue("vTxt")
	oF.IsNotANumberQ()
	Then("IsNotANumberQ on a text leaves it ongoing", oF.ChainStatus(), :ongoing)
	oG = new stzChainOfValue("vTxt")
	oG.IsNotAStringQ()
	Then("IsNotAStringQ on a text stops the chain", oG.ChainStatus(), :stopped)
	oH = new stzChainOfValue("vNum")
	oH.IsNotAStringQ()
	Then("IsNotAStringQ on a number leaves it ongoing", oH.ChainStatus(), :ongoing)
	oI = new stzChainOfValue("vNum")
	oI.getIsNot()
	oI.IsANumberQ()
	Then("after getIsNot, IsANumberQ stops a number chain", oI.ChainStatus(), :stopped)
	aWhy = oI.WhyChainStopped()
	Then("with the opposite reason", aWhy[1], "Because the value is a number!")
	oJ = new stzChainOfValue("vTxt")
	oJ.getIsNot()
	oJ.IsANumberQ()
	Then("after getIsNot, IsANumberQ lets a text chain go on", oJ.ChainStatus(), :ongoing)
	oK = new stzChainOfValue("vNum")
	oK.ANumberQ()
	Then("ANumberQ is the same call, ongoing on a number", oK.ChainStatus(), :ongoing)
	oK2 = new stzChainOfValue("vTxt")
	oK2.ANumberQ()
	Then("and stopped on a text", oK2.ChainStatus(), :stopped)
	oM = new stzChainOfValue("vTxt")
	oM.NotANumberQ()
	Then("NotANumberQ is the same call, ongoing on a text", oM.ChainStatus(), :ongoing)
	oP = new stzChainOfValue("vNum")
	oP.NotAStringQ()
	Then("NotAStringQ on a number is ongoing", oP.ChainStatus(), :ongoing)
	oQ = new stzChainOfValue("vTxt")
	oQ.AStringQ()
	Then("AStringQ on a text is ongoing", oQ.ChainStatus(), :ongoing)
	oQ2 = new stzChainOfValue("vNum")
	oQ2.AStringQ()
	Then("AStringQ on a number is stopped", oQ2.ChainStatus(), :stopped)
EndScenario()

Scenario("A sentence goes on or not: the code runs only when the type question is met")
	Given("a counter variable holding a number")
	vSent = 5
	Whatever(:vSent).IsANumberQ().DoThis('{ vSent = vSent + 1 }')
	Then("the code ran after the number was recognised", vSent, 6)
	vSent = "ab"
	Whatever(:vSent).IsANumberQ().DoThis('{ vSent = "ran" }')
	Then("the code did not run for a text", vSent, "ab")
	Whatever(:vSent).IsAStringQ().DoThis('{ vSent = "ran" }')
	Then("and runs when the question is about a text", vSent, "ran")
	vSent = 3
	Whatever(:vSent).IsAStringQ().DoThis('{ vSent = "ran" }')
	Then("and does not run for a number", vSent, 3)
	o1 = Whatever(:vSent).Do_('{ vSent = 8 }')
	Then("Do_ runs the code", vSent, 8)
	Then("and answers the chain (it answered nothing)", lower(classname(o1)), "stzchainofvalue")
	Then("so that the sentence goes on", o1.CodeStatus(), :hasbeenexecuted)
EndScenario()

Scenario("ToStzObject and the sentence words work on a number, which they did not")
	Given("chains over a number, a text, a list and an object")
	oN = new stzChainOfValue("vNum")
	oT = new stzChainOfValue("vTxt")
	oL = new stzChainOfValue("vList")
	oO = new stzChainOfValue("vObj")
	r = oN.ToStzObject()
	Then("a number is wrapped in a stzNumber (it raised)", lower(classname(r)), "stznumber")
	r = oT.ToStzObject()
	Then("a text in a stzString", lower(classname(r)), "stzstring")
	r = oL.ToStzObject()
	Then("a list in a stzList", lower(classname(r)), "stzlist")
	r = oO.ToStzObject()
	Then("an object in a stzObject", lower(classname(r)), "stzobject")
	r = oN._Which()
	Then("_Which on a number does not raise and wraps it", lower(classname(r)), "stznumber")
	r = oN._That()
	Then("_That the same", lower(classname(r)), "stznumber")
	r = oN._AND()
	Then("_AND the same", lower(classname(r)), "stznumber")
	r = oN._OR()
	Then("_OR the same", lower(classname(r)), "stznumber")
	r = oN._But()
	Then("_But the same", lower(classname(r)), "stznumber")
	r = oT._Which()
	Then("_Which on a text still wraps it in a stzString", lower(classname(r)), "stzstring")
	cC = r.Content()
	Then("and the stzString holds the text", cC, "abc")
	r = oN.ToStzObject()
	nC = r.Content()
	Then("the stzNumber holds the number", nC, "5")
EndScenario()

Scenario("ThisValue builds a chain over a value, not over the name of a variable")
	Given("ThisValue over a number, a text, a list and an object")
	o1 = ThisValue(42)
	Then("a number is a number", o1.IsANumber(), 1)
	Then("and holds 42", o1.Value(), 42)
	o2 = ThisValue("abc")
	Then("a text is a text (it was an empty stopped chain)", o2.IsAString(), 1)
	Then("and holds abc", o2.Value(), "abc")
	Then("the chain is ongoing", o2.ChainStatus(), :ongoing)
	o3 = ThisValue([ 1, 2 ])
	Then("a list is a list (it raised R21)", o3.IsAList(), 1)
	Then("and holds two items", len(o3.Value()), 2)
	o4 = ThisValue(new CvTiny)
	Then("an object is an object", o4.IsAnObject(), 1)
	Then("and is not a list", o4.IsAList(), 0)
	Then("the first chain kept its own value after the later calls", o1.Value(), 42)
	Then("the second kept its own value too", o2.Value(), "abc")
	o5 = o2.Copy()
	Then("a copy of a ThisValue chain holds the value of that chain", o5.Value(), "abc")
	o6 = ThisValue("zzz")
	Then("whatever the later ThisValue calls were", o5.Value(), "abc")
	oV = new stzChainOfValue("vTxt")
	oV2 = oV.Copy()
	Then("a copy of a variable chain still reads the variable", oV2.Value(), "abc")
EndScenario()

Scenario("Every public method, once, on a number, a text, a list and an object")
	Given("the methods of the class, each called on a fresh chain with the shared flags reset")
	acKinds = [ "vNum", "vTxt", "vList", "vObj" ]
	acCalls = Calls()
	nCalls = len(acCalls)
	for k = 1 to 4
		cFail = ""
		for j = 1 to nCalls
			cOne = RunOne(acKinds[k], acCalls[j])
			if cOne != ""
				cFail += acCalls[j] + " -> " + cOne + "; "
			ok
		next
		Then("on " + acKinds[k] + ": none of the " + nCalls + " calls raises", cFail, "")
	next
	Then("the sweep covered more than sixty calls", nCalls > 60, 1)
EndScenario()

Scenario("The type forms agree with each other for every kind of value")
	Given("the four kinds through the variables")
	acKinds = [ "vNum", "vTxt", "vList", "vObj" ]
	acWant = [ "1000", "0100", "0010", "0001" ]
	for k = 1 to 4
		o = new stzChainOfValue(acKinds[k])
		cMask = "" + o.IsANumber() + o.IsAString() + o.IsAList() + o.IsAnObject()
		Then(acKinds[k] + " has the mask " + acWant[k], cMask, acWant[k])
		nA = o.IsNotANumber()
		nB = 1 - o.IsANumber()
		Then(acKinds[k] + ": IsNotANumber is the negation", nA, nB)
		nA = o.IsNotAString()
		nB = 1 - o.IsAString()
		Then(acKinds[k] + ": IsNotAString is the negation", nA, nB)
		cA = "" + o.ANumber() + o.AString()
		cB = "" + o.IsANumber() + o.IsAString()
		Then(acKinds[k] + ": ANumber, AString are the same calls", cA, cB)
		cA = "" + o.NotANumber() + o.NotAString()
		cB = "" + o.IsNotANumber() + o.IsNotAString()
		Then(acKinds[k] + ": NotANumber, NotAString are the same calls", cA, cB)
	next
EndScenario()

Summary()

func Cases()
	acL = []
	acL + [ "an integer", 42, "1000" ]
	acL + [ "a negative", -7, "1000" ]
	acL + [ "a decimal", 3.14, "1000" ]
	acL + [ "zero", 0, "1000" ]
	acL + [ "a huge number", nBig, "1000" ]
	acL + [ "a numeric text", "12", "0100" ]
	acL + [ "the empty text", "", "0100" ]
	acL + [ "an accented text", "caf" + eAc, "0100" ]
	acL + [ "a Hebrew text", alef + bet, "0100" ]
	acL + [ "an emoji text", emo, "0100" ]
	acL + [ "the empty list", [], "0010" ]
	acL + [ "a nested list", [ 1, [ 2, 3 ] ], "0010" ]
	acL + [ "a list of lists", [ [ 1, 2 ], [ 3, 4 ] ], "0010" ]
	acL + [ "a list of texts", [ "a", "b" ], "0010" ]
	acL + [ "a stzString", new stzString("hello"), "0001" ]
	acL + [ "a stzList", new stzList([ 1, 2 ]), "0001" ]
	acL + [ "a stzNumber", new stzNumber(5), "0001" ]
	acL + [ "a tiny object", new CvTiny, "0001" ]
	return acL

func MaskOf(pValue)
	oM1 = ThisValue(pValue)
	cM1 = "" + oM1.IsANumber() + oM1.IsAString() + oM1.IsAList() + oM1.IsAnObject()
	return cM1

func Ones(pcMask)
	nOnes = 0
	for iO = 1 to len(pcMask)
		if pcMask[iO] = "1"
			nOnes++
		ok
	next
	return nOnes

func Calls()
	return [
		"VarName()", "Value()", "_Type()", "Copy().Value()", "Code()", "StopValue()",
		"getIs().ChainStatus()", "getIsNot().ChainStatus()", "get_Not().ChainStatus()", "getBecomes().ChainStatus()",
		"_Which()", "_That()", "_AND()", "_OR()", "_But()",
		"Is(5)", "IsEqualTo(5)", "Equals(5)", "Becomes(7)", "BecomesEqualTo(7)",
		"BecomesIsUsedBeforeDoThis()", "BecomesIsUsedAfterDoThis()",
		"StopWhen(3)", "StopWhen('x')", "StopWhen([ 1, 2 ])",
		"DoThis('{ vSweep = 1 }')", "Do_('{ vSweep = 1 }')", "GetDo_().ChainStatus()", "GetCodeExecute().ChainStatus()",
		"This_('{ vSweep = 1 }')", "ValueInitiator()", "StopChain([ 'x' ])", "ChainStatus()",
		"WhyChainIsStopped()", "WhyChainStopped()", "OneOrManyLoops()", "RequiresStopValue()",
		"CodeStatus()", "WhyCodeNotYetExecuted()", "WhyCodeHasNotBeenExecuted()",
		"CodeHasBeenCalled()", "CodeHasBeenExecuted()", "CodeIsStillWaitingForExecution()", "ToStzObject()",
		"IsANumber()", "IsANumberQ()", "ANumber()", "ANumberQ()",
		"IsNotANumber()", "IsNotANumberQ()", "NotANumber()", "NotANumberQ()",
		"IsAString()", "IsAStringQ()", "IsNotAString()", "IsNotAStringQ()",
		"NotAString()", "NotAStringQ()", "AString()", "AStringQ()",
		"IsAList()", "IsAnObject()",
		"Update(9)", "UpdateQ(9)", "UpdateWith(9)", "UpdateWithQ(9)", "UpdateBy(9)", "UpdateByQ(9)",
		"UpdateUsing(9)", "UpdateUsingQ(9)", "Updated(9)", "UpdatedWith(9)", "UpdatedBy(9)", "UpdatedUsing(9)"
	]

func RunOne(pcVar, pcCall)
	$cOneOrManyLoops = :One
	$bExecuteCode = 1
	$pStopValue = ""
	$cValueInitiator = :OnlyWhen
	$bRandomPass = 1
	oRun = new stzChainOfValue(pcVar)
	cErr = ""
	try
		eval("xRun = oRun." + pcCall)
	catch
		cErr = cCatchError
	done
	return cErr

class CvTiny
	x = 1
