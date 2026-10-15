load "../../stzBase.ring"
load "../_narrated.ring"

# stzObject defects -- the guard behind the DOCREFORM stzObject batch (fix/obj).
# Every method below was called with real data on a stzString, a stzList, a stzNumber and a bare
# stzObject (one that wraps an object). Run from inside this folder.
#
# A positive assertion has a negative sibling: the right answer for one input and the right
# refusal for another, so a method that answers TRUE for everything cannot pass.

oS = new stzString("banana")
oL = new stzList([ 1, 2, 3 ])
oN = new stzNumber(42)
oB = new stzObject(oS)

# --------------------------------------------------------------------------------------------
Scenario("Values and AttributesAndValues read the object's attributes")
	Given("a stzString, a stzList, a stzNumber and a bare stzObject")
	aVs = oS.Values()
	aVl = oL.Values()
	aVn = oN.Values()
	aVb = oB.Values()
	Then("Values on a stzString has one value per attribute", len(aVs), len(oS.Attributes()))
	Then("Values on a stzList has one value per attribute", len(aVl), len(oL.Attributes()))
	Then("Values on a stzNumber has one value per attribute", len(aVn), len(oN.Attributes()))
	Then("Values on a bare stzObject has one value per attribute", len(aVb), len(oB.Attributes()))
	Then("a stzString's values hold its variable name", HasLiteral(aVs, '"@noname"'), 1)
	Then("and not a name it does not have", HasLiteral(aVs, '"apple"'), 0)
	Then("a stzNumber's values hold its digits as text", HasLiteral(aVn, '"42"'), 1)
	Then("and not other digits", HasLiteral(aVn, '"43"'), 0)
	Then("the stzList's items are among its values", HasLiteral(aVl, "[ 1, 2, 3 ]"), 1)
	Then("other items are not", HasLiteral(aVl, "[ 3, 2, 1 ]"), 0)
	Then("the bare stzObject holds the wrapped object as its first value", isObject(aVb[1]), 1)
	aAv = oS.AttributesAndValues()
	Then("AttributesAndValues has one pair per attribute", len(aAv), len(oS.Attributes()))
	Then("a pair is [ name, value ]", len(aAv[1]), 2)
	Then("the first pair carries the first attribute name", aAv[1][1], oS.Attributes()[1])
	Then("and its value", @@(aAv[1][2]), @@(aVs[1]))
	Then("the stzList's pairs count its attributes too", len(oL.AttributesAndValues()), len(oL.Attributes()))
	Then("so do the stzNumber's", len(oN.AttributesAndValues()), len(oN.Attributes()))
	Then("so do the bare stzObject's", len(oB.AttributesAndValues()), len(oB.Attributes()))
	Then("the other spellings answer the same", len(oS.ObjectValues()), len(aVs))
EndScenario()

# --------------------------------------------------------------------------------------------
Scenario("IsStringOrList, IsListOrString: the content is a text or a list")
	Then("a stzString holds a text", oS.IsStringOrList(), 1)
	Then("a stzString holds a text (the other order)", oS.IsListOrString(), 1)
	Then("a stzList holds a list", oL.IsListOrString(), 1)
	Then("a stzNumber holds neither", oN.IsListOrString(), 0)
	Then("a stzNumber holds neither (the first spelling)", oN.IsStringOrList(), 0)
	Then("a bare stzObject holds an object, neither", oB.IsListOrString(), 0)
	Then("a bare stzObject holds an object, neither (the first spelling)", oB.IsStringOrList(), 0)
EndScenario()

# --------------------------------------------------------------------------------------------
Scenario("IsFalseObject, IsTrueObject tell the two library objects apart")
	oF = AFalseObject()
	oT = ATrueObject()
	Then("the false object is a false object", oF.IsFalseObject(), 1)
	Then("the true object is not", oT.IsFalseObject(), 0)
	Then("the true object is a true object", oT.IsTrueObject(), 1)
	Then("the false object is not", oF.IsTrueObject(), 0)
	Then("a stzString is neither (false)", oS.IsFalseObject(), 0)
	Then("a stzString is neither (true)", oS.IsTrueObject(), 0)
	Then("a stzList is neither (false)", oL.IsFalseObject(), 0)
	Then("a stzNumber is neither (true)", oN.IsTrueObject(), 0)
	Then("a bare stzObject is neither (false)", oB.IsFalseObject(), 0)
	Then("a bare stzObject is neither (true)", oB.IsTrueObject(), 0)
	Then("the misspelt alias answers like IsFalseObject", oF.IsFalseObejct(), 1)
	Then("the misspelt alias refuses a stzString", oS.IsFalseObejct(), 0)
EndScenario()

# --------------------------------------------------------------------------------------------
Scenario("HasSameStzTypeAs compares the two objects' library classes")
	oS2 = new stzString("kiwi")
	oL2 = new stzList([ 9 ])
	oN2 = new stzNumber(7)
	oB2 = new stzObject(oL)
	Then("two stzString are of the same type", oS.HasSameStzTypeAs(oS2), 1)
	Then("two stzList are of the same type", oL.HasSameStzTypeAs(oL2), 1)
	Then("two stzNumber are of the same type", oN.HasSameStzTypeAs(oN2), 1)
	Then("two bare stzObject are of the same type", oB.HasSameStzTypeAs(oB2), 1)
	Then("a stzString and a stzList are not", oS.HasSameStzTypeAs(oL), 0)
	Then("a stzList and a stzNumber are not", oL.HasSameStzTypeAs(oN), 0)
	Then("a stzNumber and a stzString are not", oN.HasSameStzTypeAs(oS), 0)
	Then("a bare stzObject and a stzString are not", oB.HasSameStzTypeAs(oS), 0)
	Then("a text is not an object at all", oS.HasSameStzTypeAs("kiwi"), 0)
	Then("a number is not an object at all", oN.HasSameStzTypeAs(7), 0)
EndScenario()

# --------------------------------------------------------------------------------------------
Scenario("IsText asks whether the object IS a stzText, the library's text class")
	oTx = new stzText("hello")
	Then("a stzText is a stzText", oTx.IsText(), 1)
	Then("a stzString is not (it is the plain text class)", oS.IsText(), 0)
	Then("a stzList is not", oL.IsText(), 0)
	Then("a stzNumber is not", oN.IsText(), 0)
	Then("a bare stzObject is not", oB.IsText(), 0)
EndScenario()

# --------------------------------------------------------------------------------------------
Scenario("WhichAreBoth keeps a pair and refuses anything else")
	oP = new stzList([ 1, 2 ])
	oT3 = new stzList([ 1, 2, 3 ])
	Then("a list of two items is kept", classname(oP.WhichAreBoth()), "stzlist")
	Then("a list of three is a false object", classname(oT3.WhichAreBoth()), "stzfalseobject")
	Then("a list of one is a false object", classname(Q([ 1 ]).WhichAreBoth()), "stzfalseobject")
	Then("a stzString is a false object", classname(oS.WhichAreBoth()), "stzfalseobject")
	Then("a stzNumber is a false object", classname(oN.WhichAreBoth()), "stzfalseobject")
	Then("a bare stzObject is a false object", classname(oB.WhichAreBoth()), "stzfalseobject")
EndScenario()

# --------------------------------------------------------------------------------------------
Scenario("AreBothA and AreTwo test each of the two items, not the pair as a whole")
	oWords = new stzList([ "a", "b" ])
	oNums = new stzList([ 1, 2 ])
	oMix = new stzList([ 1, "b" ])
	Then("two texts are both strings", oWords.AreBothA(:String), 1)
	Then("two texts are not both lists (the pair itself is a list)", oWords.AreBothA(:List), 0)
	Then("two numbers are both numbers", oNums.AreBothA(:Number), 1)
	Then("two numbers are not both strings", oNums.AreBothA(:String), 0)
	Then("a number and a text are not both numbers", oMix.AreBothA(:Number), 0)
	Then("a number and a text are not both strings", oMix.AreBothA(:String), 0)
	Then("AreTwo is the same question: yes", oWords.AreTwo(:String), 1)
	Then("AreTwo is the same question: no", oWords.AreTwo(:List), 0)
	Then("a list of three is a false object", classname(oL.AreBothA(:Number)), "stzfalseobject")
	Then("a stzString is a false object", classname(oS.AreBothA(:String)), "stzfalseobject")
	Then("the pair is left as it was", @@(oWords.Content()), '[ "a", "b" ]')
EndScenario()

# --------------------------------------------------------------------------------------------
Scenario("The Of family compares with the last value remembered")
	SetLastValue(8)
	Then("OfCSB: the number is the last value", Q(8).OfCSB(8, 1), 1)
	Then("OfCSB: another number is not", Q(8).OfCSB(7, 1), 0)
	Then("OfXTCSB ignores the filler word and compares: yes", Q(8).OfXTCSB(8, "to", 1), 1)
	Then("OfXTCSB ignores the filler word and compares: no", Q(8).OfXTCSB(7, "to", 1), 0)
	Then("OfXTBQ keeps the object when equal", classname(Q(8).OfXTBQ(8)), "stznumber")
	Then("OfXTBQ answers a false object when not", classname(Q(8).OfXTBQ(7)), "stzfalseobject")
	Then("OfBQ agrees with OfXTBQ: equal", classname(Q(8).OfBQ(8)), "stznumber")
	Then("OfBQ agrees with OfXTBQ: not equal", classname(Q(8).OfBQ(7)), "stzfalseobject")
	SetLastValue("kiwi")
	Then("on a text: equal", oS.OfXTCSB("kiwi", "to", 1), 1)
	Then("on a text: not equal", oS.OfXTCSB("plum", "to", 1), 0)
	Then("on a text: case-sensitive refusal", oS.OfXTCSB("KIWI", "to", 1), 0)
	Then("on a text: case-insensitive agreement", oS.OfXTCSB("KIWI", "to", 0), 1)
	Then("on a list receiver: equal", oL.OfXTCSB("kiwi", "to", 1), 1)
	Then("on a bare stzObject: equal", oB.OfXTCSB("kiwi", "to", 1), 1)
	Then("on a bare stzObject: not equal", oB.OfXTCSB("plum", "to", 1), 0)
	Then("OfXTBQ on a text: equal", classname(oS.OfXTBQ("kiwi")), "stzstring")
	Then("OfXTBQ on a text: not equal", classname(oS.OfXTBQ("plum")), "stzfalseobject")
EndScenario()

# --------------------------------------------------------------------------------------------
Scenario("OccursForTheNthTime, First, Last: the content is the nth occurrence at a position")
	oStar = new stzString("*")
	Then("the 1st star of a*b*c*d is at 2", oStar.OccursForTheNthTime(1, :In = "a*b*c*d", :AtPosition = 2), 1)
	Then("the 2nd star is at 4, not at 2", oStar.OccursForTheNthTime(2, :In = "a*b*c*d", :AtPosition = 2), 0)
	Then("the 3rd star is at 6", oStar.OccursForTheNthTime(3, :In = "a*b*c*d", :AtPosition = 6), 1)
	Then("there is no 4th star", oStar.OccursForTheNthTime(4, :In = "a*b*c*d", :AtPosition = 6), 0)
	Then("the first star: at 2", oStar.OccursForTheFirstTime(:In = "a*b*c*d", :At = 2), 1)
	Then("the first star: not at 4", oStar.OccursForTheFirstTime(:In = "a*b*c*d", :At = 4), 0)
	Then("the last star: at 6", oStar.OccursForTheLastTime(:In = "a*b*c*d", :At = 6), 1)
	Then("the last star: not at 2", oStar.OccursForTheLastTime(:In = "a*b*c*d", :At = 2), 0)
	Then("the last star: not at 4", oStar.OccursForTheLastTime(:In = "a*b*c*d", :At = 4), 0)
	Then("the aliases agree", oStar.OccursForTheFirstTimeAt(:In = "a*b*c*d", :At = 2), 1)
	oAn = new stzString("AN")
	Then("case-sensitive: AN is not in banana", oAn.OccursForTheFirstTimeCS(:In = "banana", :At = 2, 1), 0)
	Then("case-insensitive: AN first occurs at 2 in banana", oAn.OccursForTheFirstTimeCS(:In = "banana", :At = 2, 0), 1)
	oB1 = new stzString("b")
	Then("in a list of texts: 2nd b is at 4", oB1.OccursForTheNthTime(2, :In = [ "a", "b", "c", "b" ], :At = 4), 1)
	Then("in a list of texts: 2nd b is not at 2", oB1.OccursForTheNthTime(2, :In = [ "a", "b", "c", "b" ], :At = 2), 0)
	Then("in a list of texts: the last b is at 4", oB1.OccursForTheLastTime(:In = [ "a", "b", "c", "b" ], :At = 4), 1)
	Then("in a list of texts: the last b is not at 2", oB1.OccursForTheLastTime(:In = [ "a", "b", "c", "b" ], :At = 2), 0)
	Then("in a list of texts: case-insensitive", Q("B").OccursForTheFirstTimeCS(:In = [ "a", "b" ], :At = 2, 0), 1)
	Then("in a list of texts: case-sensitive refuses", Q("B").OccursForTheFirstTimeCS(:In = [ "a", "b" ], :At = 2, 1), 0)
	Then("a stzNumber in a mixed list: 2nd 2 is at 4", oN2x().OccursForTheNthTime(2, :In = [ 1, 2, 3, 2 ], :At = 4), 1)
	Then("a stzNumber in a mixed list: 2nd 2 is not at 2", oN2x().OccursForTheNthTime(2, :In = [ 1, 2, 3, 2 ], :At = 2), 0)
EndScenario()

# --------------------------------------------------------------------------------------------
Scenario("SizeInBytesXT32 and SizeInBytesXT64 give the size breakdown of each build")
	aX32s = oS.SizeInBytesXT32()
	aX64s = oS.SizeInBytesXT64()
	Then("32-bit: a list of [ label, bytes ] pairs", isList(aX32s) and len(aX32s) > 0, 1)
	Then("64-bit: a list of [ label, bytes ] pairs", isList(aX64s) and len(aX64s) > 0, 1)
	Then("32-bit labels are the 32-bit ones", StzFindFirst("32BIT", aX32s[1][1]) > 0, 1)
	Then("32-bit labels are not the 64-bit ones", StzFindFirst("64BIT", aX32s[1][1]), 0)
	Then("64-bit labels are the 64-bit ones", StzFindFirst("64BIT", aX64s[1][1]) > 0, 1)
	Then("64-bit labels are not the 32-bit ones", StzFindFirst("32BIT", aX64s[1][1]), 0)
	Then("a pair carries a number of bytes", isNumber(aX32s[1][2]), 1)
	Then("a stzList answers too (32)", len(oL.SizeInBytesXT32()) > 0, 1)
	Then("a stzList answers too (64)", len(oL.SizeInBytesXT64()) > 0, 1)
	Then("a stzNumber answers too (32)", len(oN.SizeInBytesXT32()) > 0, 1)
	Then("a stzNumber answers too (64)", len(oN.SizeInBytesXT64()) > 0, 1)
	Then("a bare stzObject answers too (32)", len(oB.SizeInBytesXT32()) > 0, 1)
	Then("a bare stzObject answers too (64)", len(oB.SizeInBytesXT64()) > 0, 1)
	Then("the 64-bit total exceeds the 32-bit total", SumBytes(aX64s) > SumBytes(aX32s), 1)
	Then("the alias answers the same", len(oS.MSizeInBytesXT32()), len(aX32s))
EndScenario()

# --------------------------------------------------------------------------------------------
Scenario("AddTimeValue, AddExecutionTimeValue, AddExecutionTime keep the elapsed time")
	CleanTimeValues()
	SetKeepingTimeTo(1)
	oS.AddTimeValue()
	oL.AddExecutionTimeValue()
	oN.AddExecutionTime()
	oB.AddTimeValue()
	aT = oS.TimeValues()
	Then("four calls on four receivers keep four values", len(aT), 4)
	Then("each value is a number of seconds", isNumber(aT[1]) and isNumber(aT[4]), 1)
	Then("and none is negative", aT[1] >= 0 and aT[2] >= 0 and aT[3] >= 0 and aT[4] >= 0, 1)
	Then("the values do not decrease", aT[4] >= aT[1], 1)
	CleanTimeValues()
	Then("cleaning empties the list", len(oS.TimeValues()), 0)
	SetKeepingTimeTo(0)
	bRaised = 0
	try
		oS.AddTimeValue()
	catch
		bRaised = 1
	done
	Then("with time keeping off it refuses, as ExecutionTime does", bRaised, 1)
	Then("and keeps nothing", len(oS.TimeValues()), 0)
EndScenario()

# --------------------------------------------------------------------------------------------
Scenario("ToPointer answers a pointer to the object itself")
	pS = oS.ToPointer()
	pL = oL.ToPointer()
	pN = oN.ToPointer()
	pB = oB.ToPointer()
	Then("a stzString answers a pointer", type(pS), "OBJECTPOINTER")
	Then("a stzList answers a pointer", type(pL), "OBJECTPOINTER")
	Then("a stzNumber answers a pointer", type(pN), "OBJECTPOINTER")
	Then("a bare stzObject answers a pointer", type(pB), "OBJECTPOINTER")
	Then("it is the pointer Ring's own object2pointer gives", ptrcmp(pS, object2pointer(oS)), 1)
	Then("two objects have two pointers", ptrcmp(pS, pL), 0)
	Then("a stzNumber is not a stzString", ptrcmp(pN, pS), 0)
	Then("the bare stzObject is not the object it wraps", ptrcmp(pB, pS), 0)
EndScenario()

# --------------------------------------------------------------------------------------------
Scenario("Numberified turns the content into a number")
	Then("a stzNumber 42 is 42", oN.Numberified(), 42)
	Then("a stzNumber 7.5 is 7.5", Q(7.5).Numberified(), 7.5)
	Then("and it is a number, not a text", isNumber(oN.Numberified()), 1)
	Then("a text of digits is a number", Q("12").Numberified(), 12)
	Then("a list of numbers and numeric texts is a list of numbers", @@(Q([ 1, "2", 3 ]).Numberified()), "[ 1, 2, 3 ]")
	bRaised = 0
	try
		x = oS.Numberified()
	catch
		bRaised = 1
	done
	Then("a text that is not a number is refused", bRaised, 1)
	bRaised = 0
	try
		x = oB.Numberified()
	catch
		bRaised = 1
	done
	Then("a bare stzObject is refused", bRaised, 1)
EndScenario()

# --------------------------------------------------------------------------------------------
Scenario("IfQ keeps the object when the condition holds, answers a false object otherwise")
	Then("a stzString and a true condition", classname(oS.IfQ("1 = 1")), "stzstring")
	Then("a stzString and a false condition", classname(oS.IfQ("1 = 2")), "stzfalseobject")
	Then("a stzList and a true condition", classname(oL.IfQ("2 > 1")), "stzlist")
	Then("a stzList and a false condition", classname(oL.IfQ("2 < 1")), "stzfalseobject")
	Then("a stzNumber and a true condition", classname(oN.IfQ("1 = 1")), "stznumber")
	Then("a stzNumber and a false condition", classname(oN.IfQ("1 = 2")), "stzfalseobject")
	Then("a bare stzObject and a true condition", classname(oB.IfQ("1 = 1")), "stzobject")
	Then("a bare stzObject and a false condition", classname(oB.IfQ("1 = 2")), "stzfalseobject")
	bRaised = 0
	try
		x = oS.IfQ(5)
	catch
		bRaised = 1
	done
	Then("a condition that is not a text is still refused", bRaised, 1)
EndScenario()

# --------------------------------------------------------------------------------------------
Scenario("SwapWith exchanges the content of two objects")
	a1 = new stzString("abc")
	a2 = new stzString("xyz")
	a1.SwapWith(a2)
	Then("stzString: the first holds the second's text", a1.Content(), "xyz")
	Then("stzString: the second holds the first's", a2.Content(), "abc")
	l1 = new stzList([ 1, 2 ])
	l2 = new stzList([ 3, 4, 5 ])
	l1.SwapWith(l2)
	Then("stzList: the first holds the second's items", @@(l1.Content()), "[ 3, 4, 5 ]")
	Then("stzList: the second holds the first's", @@(l2.Content()), "[ 1, 2 ]")
	n1 = new stzNumber(1)
	n2 = new stzNumber(2)
	n1.SwapWith(n2)
	Then("stzNumber: the first holds 2", n1.NumericValue(), 2)
	Then("stzNumber: the second holds 1", n2.NumericValue(), 1)
	oIn1 = new stzString("one")
	oIn2 = new stzList([ 2 ])
	b1 = new stzObject(oIn1)
	b2 = new stzObject(oIn2)
	b1.SwapWith(b2)
	Then("bare: the first wraps the second's object", classname(b1.Content()), "stzlist")
	Then("bare: the second wraps the first's object", classname(b2.Content()), "stzstring")
	bRaised = 0
	try
		a1.SwapWith("text")
	catch
		bRaised = 1
	done
	Then("a value that is not a stzObject is refused", bRaised, 1)
	Then("and the content is untouched", a1.Content(), "xyz")
EndScenario()

# --------------------------------------------------------------------------------------------
Scenario("IsA and AnObjectQ on a bare stzObject, and on the others")
	Then("a bare stzObject is an object", oB.IsA(:Object), 1)
	Then("a bare stzObject is not a string", oB.IsA(:String), 0)
	Then("a bare stzObject is not a list", oB.IsA(:List), 0)
	Then("a bare stzObject is not a number", oB.IsA(:Number), 0)
	Then("AnObjectQ keeps a bare stzObject", classname(oB.AnObjectQ()), "stzobject")
	Then("AnObjectQ refuses a stzString", classname(oS.AnObjectQ()), "stzfalseobject")
	Then("AnObjectQ refuses a stzList", classname(oL.AnObjectQ()), "stzfalseobject")
	Then("AnObjectQ refuses a stzNumber", classname(oN.AnObjectQ()), "stzfalseobject")
	Then("IsA(:String) still says yes to a stzString", oS.IsA(:String), 1)
	Then("IsA(:String) still says no to a stzList", oL.IsA(:String), 0)
	Then("IsA(:List) still says yes to a stzList", oL.IsA(:List), 1)
	Then("IsA(:Number) says yes to a stzNumber", oN.IsA(:Number), 1)
	Then("IsA(:Number) says no to a stzString", oS.IsA(:Number), 0)
	Then("a list of kinds must all hold: yes", Q("ring").IsA([ :Lowercase, :String ]), 1)
	Then("a list of kinds must all hold: no", Q("Ring").IsA([ :Lowercase, :String ]), 0)
EndScenario()

# --------------------------------------------------------------------------------------------
Scenario("ALengthN counts what the object holds")
	Then("a stzString counts characters", oS.ALengthN(), 6)
	Then("a stzList counts items", oL.ALengthN(), 3)
	Then("a stzList of two texts has 2, not 0 characters", Q([ "ab", "cd" ]).ALengthN(), 2)
	Then("a stzList of four letters has 4", Q([ "a", "b", "c", "d" ]).ALengthN(), 4)
	Then("a list of one text has 1 item, not 5 characters", Q([ "hello" ]).ALengthN(), 1)
	Then("a stzNumber counts digits", oN.ALengthN(), 2)
	Then("an empty list has none", Q([]).ALengthN(), 0)
	bRaised = 0
	try
		x = oB.ALengthN()
	catch
		bRaised = 1
	done
	Then("a bare stzObject has no length to speak of", bRaised, 1)
EndScenario()

Summary()

func HasLiteral(aValues, cLiteral)
	for i = 1 to len(aValues)
		if NOT isObject(aValues[i])
			if @@(aValues[i]) = cLiteral
				return 1
			ok
		ok
	next
	return 0

func SumBytes(aPairs)
	nSum = 0
	for i = 1 to len(aPairs)
		nSum += aPairs[i][2]
	next
	return nSum

func oN2x()
	return new stzNumber(2)

func CleanTimeValues()
	$aStzObjectTimeValues = []
