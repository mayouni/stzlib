load "../../stzBase.ring"
load "../_narrated.ring"

# Guard for the stzListWalker registry (DEFECTS.md, stzListWalker, fixed on fix/lw): AddWalker, Walkers
# and Walker raised R24 "Using uninitialized variable: @awalkers" on any list, because the class read
# the attribute @aWalkers without ever declaring it. One cause, three rows. The class is a PLANNER of
# walks, not a cursor: its registry keeps named stzWalker objects (a start, an end, the steps to
# repeat), and there is no position that could advance, so no navigation API is written.
#
# THE SEMANTICS, written down and checked here:
#   - the registry is a list of [ name, stzWalker ] pairs in the order of registration (the shape the
#     sibling stzStringWalker keeps); the empty registry answers [ ]
#   - the registry belongs to ONE object: two walkers share nothing, a copy of an object carries its own
#   - names are folded to lowercase with the engine (accents too) and compared by bytes: "W" and "w", or
#     an accented capital and its small letter, are one name; "e" and an accented "e" are two
#   - a name already registered raises CanNotAddWalkerAlreadyExistant and keeps the first walker
#   - an unknown name in Walker raises (the sibling stzStringWalker raises too); a name that is not a
#     string raises in both methods
#   - the step may be a number (one step, repeated) or a list of steps taken in turn
#   - Walker and Walkers answer COPIES, like every object Ring stores: moving a fetched walker never
#     moves the registered one. There is no cursor in the registry to share, so this is proven, not
#     worked around.
#
# Accented and Hebrew texts are built from char codes and never printed.

cE1 = char(195) + char(169)                # a small e acute
cE2 = char(195) + char(137)                # a capital E acute
cAccLo = cE1 + "t" + cE1                   # "ete" with accents, lowercase
cAccUp = cE2 + "T" + cE2                   # the same, uppercase
cHeb = char(215) + char(169) + char(215) + char(156) + char(215) + char(149) + char(215) + char(157)
cQ = char(34)

# oN walks numbers; oT walks texts with accents and Hebrew
aNums = [ 5, 12, 7, 20, 3, 18, 9 ]
aTexts = [ "a", cAccLo, cHeb, "xyz", "b" ]
oN = new stzListWalker(aNums)
oT = new stzListWalker(aTexts)

Scenario("AddWalker, Walkers and Walker work on a list of numbers and on a list of texts")
	ThenV("the registry of a fresh number walker is empty", len(oN.Walkers()), 0)
	ThenV("the registry of a fresh text walker is empty", len(oT.Walkers()), 0)
	oN.AddWalker("w", 1, 10, 3)
	oT.AddWalker("w", 1, 10, 3)
	ThenV("the number walker holds one", len(oN.Walkers()), 1)
	ThenV("the text walker holds one", len(oT.Walkers()), 1)
	aWalked = oN.Walker("w").Walkables()
	ThenV("Walker answers the walker: 1 to 10 by 3 visits 1, 4, 7, 10", aWalked, [ 1, 4, 7, 10 ])
	aWalkedT = oT.Walker("w").Walkables()
	ThenV("the same on the text walker", aWalkedT, [ 1, 4, 7, 10 ])
	ThenV("adding to one registry did not touch the other", len(oN.Walkers()), 1)
	cErr = ErrOf("oN.Walker(" + cQ + "nope" + cQ + ")")
	ThenV("a registry that is not empty still refuses an unknown name", len(cErr) > 0, 1)
EndScenario()

Scenario("The shape: [ name, object ] pairs, in the order of registration")
	oS = new stzListWalker(aNums)
	oS.AddWalker("zeta", 1, 7, 1)
	oS.AddWalker("alpha", 2, 6, 2)
	oS.AddWalker(cHeb, 1, 3, 1)
	aW = oS.Walkers()
	ThenV("three pairs", len(aW), 3)
	ThenV("each is a pair", len(aW[1]) + len(aW[2]) + len(aW[3]), 6)
	ThenV("the first name is the first added", aW[1][1], "zeta")
	ThenV("the second is the second added, not sorted", aW[2][1], "alpha")
	ThenV("the Hebrew name is stored as it was written", strcmp(aW[3][1], cHeb), 0)
	ThenV("the second item of a pair is a stzWalker object", isObject(aW[2][2]), 1)
	ThenV("and it keeps its steps", aW[2][2].Walkables(), [ 2, 4, 6 ])
	ThenV("a name is never a number", isNumber(aW[1][1]), 0)
	ThenV("Walker finds the Hebrew name", oS.Walker(cHeb).Walkables(), [ 1, 2, 3 ])
	ThenV("WalkerQ is the same call", oS.WalkerQ("alpha").Walkables(), [ 2, 4, 6 ])
EndScenario()

Scenario("Names fold to lowercase, with the engine, accents included")
	oC = new stzListWalker(aNums)
	oC.AddWalker("MiXeD", 1, 5, 2)
	ThenV("the stored name is lowercase", oC.Walkers()[1][1], "mixed")
	ThenV("it is found in lowercase", oC.Walker("mixed").Walkables(), [ 1, 3, 5 ])
	ThenV("it is found in uppercase", oC.Walker("MIXED").Walkables(), [ 1, 3, 5 ])
	ThenV("it is found as it was written", oC.Walker("MiXeD").Walkables(), [ 1, 3, 5 ])
	oC.AddWalker(cAccUp, 1, 2, 1)
	ThenV("an accented capital name is stored with its small letters", strcmp(oC.Walkers()[2][1], cAccLo), 0)
	ThenV("it is found by the small-letter spelling", oC.Walker(cAccLo).Walkables(), [ 1, 2 ])
	ThenV("it is found by the capital spelling", oC.Walker(cAccUp).Walkables(), [ 1, 2 ])
	oC.AddWalker("ete", 1, 4, 1)
	ThenV("'ete' without accents is another name", len(oC.Walkers()), 3)
	ThenV("and walks its own range", oC.Walker("ete").Walkables(), [ 1, 2, 3, 4 ])
	ThenV("while the accented one kept its own", oC.Walker(cAccLo).Walkables(), [ 1, 2 ])
EndScenario()

Scenario("A name already registered raises, in any case, and keeps the first walker")
	oD = new stzListWalker(aNums)
	oD.AddWalker("w", 1, 7, 2)
	cErr1 = ErrOf("oD.AddWalker(" + cQ + "w" + cQ + ", 1, 3, 1)")
	ThenV("the same name raises", len(cErr1) > 0, 1)
	ThenV("the message says the name already exists", substr(cErr1, "already exists") > 0, 1)
	cErr2 = ErrOf("oD.AddWalker(" + cQ + "W" + cQ + ", 1, 3, 1)")
	ThenV("the same name in uppercase raises as well", len(cErr2) > 0, 1)
	ThenV("still one walker", len(oD.Walkers()), 1)
	ThenV("and it is the first one", oD.Walker("w").Walkables(), [ 1, 3, 5, 7 ])
	oD.AddWalker(cAccLo, 1, 2, 1)
	cErr3 = ErrOf("oD.AddWalker(cAccUp, 1, 3, 1)")
	ThenV("an accented name in the other case raises", len(cErr3) > 0, 1)
	ThenV("two walkers", len(oD.Walkers()), 2)
	oD.AddWalker("w2", 1, 3, 1)
	ThenV("a different name is accepted: three walkers", len(oD.Walkers()), 3)
EndScenario()

Scenario("The name may be written as a pair, and must be a string")
	oP = new stzListWalker(aNums)
	oP.AddWalker([ :Named, "p" ], 2, 9, [ 1, 3 ])
	ThenV("a [ :Named, name ] pair registers under the name", oP.Walkers()[1][1], "p")
	ThenV("with a list of steps taken in turn: 2, 3, 6, 7", oP.Walker("p").Walkables(), [ 2, 3, 6, 7 ])
	ThenV("Walker accepts the pair too", oP.Walker([ :Named, "P" ]).Walkables(), [ 2, 3, 6, 7 ])
	cErrN = ErrOf("oP.AddWalker(5, 1, 2, 1)")
	ThenV("a number as a name raises", len(cErrN) > 0, 1)
	ThenV("the message names the type", substr(cErrN, "pcName must be a string") > 0, 1)
	cErrL = ErrOf("oP.AddWalker([ 1, 2, 3 ], 1, 2, 1)")
	ThenV("a list that is not a name pair raises", len(cErrL) > 0, 1)
	cErrW = ErrOf("oP.Walker(5)")
	ThenV("Walker with a number raises", len(cErrW) > 0, 1)
	ThenV("nothing was added by the refused calls", len(oP.Walkers()), 1)
EndScenario()

Scenario("An unknown name raises in Walker, a known one does not")
	oU = new stzListWalker(aNums)
	cErrE = ErrOf("oU.Walker(" + cQ + "w" + cQ + ")")
	ThenV("on an empty registry an unknown name raises", len(cErrE) > 0, 1)
	ThenV("the message says no such walker is registered", substr(cErrE, "name of a registered walker") > 0, 1)
	oU.AddWalker("w", 1, 3, 1)
	cErrK = ErrOf("oU.Walker(" + cQ + "w" + cQ + ")")
	ThenV("once registered the name raises nothing", cErrK, "")
	cErrO = ErrOf("oU.Walker(" + cQ + "w2" + cQ + ")")
	ThenV("a near name still raises", len(cErrO) > 0, 1)
	cErrWQ = ErrOf("oU.WalkerQ(" + cQ + "w2" + cQ + ")")
	ThenV("so does WalkerQ", len(cErrWQ) > 0, 1)
EndScenario()

Scenario("The steps: a number or a list, and a refused walker leaves the registry as it was")
	oRg = new stzListWalker(aNums)
	oRg.AddWalker("num", 1, 10, 4)
	ThenV("a number is one step, repeated: 1, 5, 9", oRg.Walker("num").Walkables(), [ 1, 5, 9 ])
	oRg.AddWalker("lst", 1, 10, [ 4 ])
	ThenV("a list of one step is the same walk", oRg.Walker("lst").Walkables(), [ 1, 5, 9 ])
	oRg.AddWalker("back", 10, 1, -3)
	ThenV("a negative step walks backward: 10, 7, 4, 1", oRg.Walker("back").Walkables(), [ 10, 7, 4, 1 ])
	ThenV("three walkers so far", len(oRg.Walkers()), 3)
	cErrS = ErrOf("oRg.AddWalker(" + cQ + "bad" + cQ + ", 1, 10, " + cQ + "x" + cQ + ")")
	ThenV("a text as the step raises", substr(cErrS, "non-empty list of numbers") > 0, 1)
	cErrB = ErrOf("oRg.AddWalker(" + cQ + "bad" + cQ + ", " + cQ + "a" + cQ + ", 10, 1)")
	ThenV("a text as the start raises", substr(cErrB, "must be numbers") > 0, 1)
	cErrZ = ErrOf("oRg.AddWalker(" + cQ + "bad" + cQ + ", 1, 10, [ ])")
	ThenV("an empty list of steps raises", len(cErrZ) > 0, 1)
	ThenV("the registry still holds three", len(oRg.Walkers()), 3)
	oRg.AddWalker("bad", 1, 3, 1)
	ThenV("and the refused name is still free", len(oRg.Walkers()), 4)
EndScenario()

Scenario("Walker and Walkers answer COPIES: changing the answer never changes the registry")
	oK = new stzListWalker(aNums)
	oK.AddWalker("w", 1, 10, 3)
	oWk = oK.Walker("w")
	oWk.WalkNumberOfTimes(2)
	ThenV("the fetched copy was changed: two numbers", oWk.Walkables(), [ 1, 4 ])
	ThenV("a second fetch is unchanged: four numbers", oK.Walker("w").Walkables(), [ 1, 4, 7, 10 ])
	aReg = oK.Walkers()
	aReg[1][1] = "renamed"
	ThenV("the copy of the list of pairs holds the new name", aReg[1][1], "renamed")
	ThenV("the registry keeps its own", oK.Walkers()[1][1], "w")
	aReg2 = oK.Walkers()
	del(aReg2, 1)
	ThenV("removing from the copy empties the copy", len(aReg2), 0)
	ThenV("and not the registry", len(oK.Walkers()), 1)
	oK.Walkers()[1][2].WalkNumberOfTimes(1)
	ThenV("a call chained on an object reached through Walkers() does not reach the registry either",
		oK.Walker("w").Walkables(), [ 1, 4, 7, 10 ])
	oK.Walker("w").WalkNumberOfTimes(2)
	ThenV("nor does a call chained on Walker",
		oK.Walker("w").Walkables(), [ 1, 4, 7, 10 ])
	oK.WalkerQ("w").WalkNumberOfTimes(2)
	ThenV("nor one chained on WalkerQ",
		oK.Walker("w").Walkables(), [ 1, 4, 7, 10 ])
EndScenario()

Scenario("Two registries on two lists share nothing, and a copy of an object carries its own")
	oA = new stzListWalker(aNums)
	oB = new stzListWalker(aTexts)
	oA.AddWalker("onlya", 1, 3, 1)
	ThenV("the registry of the first holds it", len(oA.Walkers()), 1)
	ThenV("the registry of the second does not", len(oB.Walkers()), 0)
	cErrX = ErrOf("oB.Walker(" + cQ + "onlya" + cQ + ")")
	ThenV("and cannot fetch it", len(cErrX) > 0, 1)
	oB.AddWalker("onlya", 2, 4, 1)
	ThenV("the same name is free on the second list", oB.Walker("onlya").Walkables(), [ 2, 3, 4 ])
	ThenV("with its own walk on the first", oA.Walker("onlya").Walkables(), [ 1, 2, 3 ])
	oA2 = oA
	ThenV("a copy starts with the registry of the original", len(oA2.Walkers()), 1)
	oA.AddWalker("later", 1, 2, 1)
	ThenV("what the original adds afterwards is not in the copy", len(oA2.Walkers()), 1)
	oA2.AddWalker("copyonly", 1, 2, 1)
	ThenV("what the copy adds is not in the original", len(oA.Walkers()), 2)
	ThenV("the copy holds two", len(oA2.Walkers()), 2)
	cErrC = ErrOf("oA.Walker(" + cQ + "copyonly" + cQ + ")")
	ThenV("the original cannot fetch what the copy added", len(cErrC) > 0, 1)
	oNoInit = new stzListWalker
	ThenV("an object built without parentheses has an empty registry", len(oNoInit.Walkers()), 0)
	oNoInit.AddWalker("w", 1, 3, 1)
	ThenV("and registers a walker", len(oNoInit.Walkers()), 1)
	oNoInit2 = new stzListWalker
	ThenV("while the next one built the same way does not see it", len(oNoInit2.Walkers()), 0)
EndScenario()

Scenario("Every public method of the class, once, on numbers and on texts")
	cGt = "@item > 10"
	cEq = "@item = " + cQ + "xyz" + cQ
	# the list of numbers: 5, 12, 7, 20, 3, 18, 9
	ThenV("Content gives the list", oN.Content(), aNums)
	ThenV("List is the same", oN.List(), aNums)
	ThenV("NumberOfItems", oN.NumberOfItems(), 7)
	ThenV("IsEmpty is false", oN.IsEmpty(), 0)
	ThenV("IsEmpty is true on an empty list", (new stzListWalker([])).IsEmpty(), 1)
	ThenV("WalkNForward", oN.WalkNForward(3), [ 1, 4, 7 ])
	ThenV("WalkForwardNSteps", oN.WalkForwardNSteps(3), [ 1, 4, 7 ])
	ThenV("WalkNBackward", oN.WalkNBackward(3), [ 7, 4, 1 ])
	ThenV("WalkBackwardNSteps", oN.WalkBackwardNSteps(3), [ 7, 4, 1 ])
	ThenV("WalkBetween forward", oN.WalkBetween(1, 5, 2), [ 1, 3, 5 ])
	ThenV("WalkBetween backward", oN.WalkBetween(5, 1, 2), [ 5, 3, 1 ])
	ThenV("WalkForthAndBack", oN.WalkForthAndBack(3), [ 1, 4, 7, 7, 4, 1 ])
	ThenV("WalkW", oN.WalkW(cGt), [ 2, 4, 6 ])
	ThenV("WalkWhere", oN.WalkWhere(cGt), [ 2, 4, 6 ])
	ThenV("PositionsWhere", oN.PositionsWhere(cGt), [ 2, 4, 6 ])
	ThenV("PositionsW", oN.PositionsW(cGt), [ 2, 4, 6 ])
	ThenV("WalkUntil includes the first match", oN.WalkUntil(cGt), [ 1, 2 ])
	ThenV("WalkUntil with :Before stops before it", oN.WalkUntil([ :Before, cGt ]), [ 1 ])
	ThenV("WalkWhen starts at the first match", oN.WalkWhen(cGt), [ 2, 3, 4, 5, 6, 7 ])
	ThenV("WalkWhile stops before the first failure", oN.WalkWhile("@item < 10"), [ 1 ])
	ThenV("WalkWhenXT backward as items", oN.WalkWhenXT(cGt, :Backward, :WalkedItems), [ 12, 5 ])
	ThenV("WalkUntilXT backward as items", oN.WalkUntilXT(cGt, :Backward, :WalkedItems), [ 9, 18 ])
	ThenV("WalkUntilXT forward as positions", oN.WalkUntilXT(cGt, :Forward, :WalkedPositions), [ 1, 2 ])
	ThenV("WalkWhileXT forward as positions", oN.WalkWhileXT("@item < 10", :Forward, :WalkedPositions), [ 1 ])
	ThenV("WalkWhileXT backward as items", oN.WalkWhileXT("@item < 10", :Backward, :WalkedItems), [ 9 ])
	ThenV("WalkZigZag", oN.WalkZigZag(2), [ 1, 3, 5, 7, 7, 5, 3, 1 ])
	ThenV("WalkEveryNth", oN.WalkEveryNth(2), [ 2, 4, 6 ])
	ThenV("WalkEach", oN.WalkEach(2), [ 2, 4, 6 ])
	ThenV("WalkFromTo forward", oN.WalkFromTo(2, 4), [ 2, 3, 4 ])
	ThenV("WalkFromTo backward", oN.WalkFromTo(4, 2), [ 4, 3, 2 ])
	ThenV("WalkSkipping", oN.WalkSkipping(1), [ 1, 3, 5, 7 ])
	ThenV("WalkSkip", oN.WalkSkip(1), [ 1, 3, 5, 7 ])
	ThenV("WalkAccumulating is a plain map", oN.WalkAccumulating("@item * 2"), [ 10, 24, 14, 40, 6, 36, 18 ])
	ThenV("WalkAccumulate is the same call", oN.WalkAccumulate("@item"), aNums)
	# the list of texts: "a", accented, Hebrew, "xyz", "b"
	ThenV("texts: Content", oT.Content(), aTexts)
	ThenV("texts: NumberOfItems counts items, not bytes", oT.NumberOfItems(), 5)
	ThenV("texts: WalkNForward", oT.WalkNForward(3), [ 1, 4 ])
	ThenV("texts: WalkNBackward", oT.WalkNBackward(3), [ 5, 2 ])
	ThenV("texts: WalkBetween", oT.WalkBetween(1, 5, 2), [ 1, 3, 5 ])
	ThenV("texts: WalkForthAndBack", oT.WalkForthAndBack(3), [ 1, 4, 5, 2 ])
	ThenV("texts: WalkW finds the text", oT.WalkW(cEq), [ 4 ])
	ThenV("texts: WalkUntil", oT.WalkUntil(cEq), [ 1, 2, 3, 4 ])
	ThenV("texts: WalkUntil :Before", oT.WalkUntil([ :Before, cEq ]), [ 1, 2, 3 ])
	ThenV("texts: WalkWhen", oT.WalkWhen(cEq), [ 4, 5 ])
	ThenV("texts: WalkWhile the item is not the text", oT.WalkWhile("not (" + cEq + ")"), [ 1, 2, 3 ])
	aBack = oT.WalkWhenXT(cEq, :Backward, :WalkedItems)
	ThenV("texts: WalkWhenXT backward returns the items, Hebrew and accents intact", aBack, [ "xyz", cHeb, cAccLo, "a" ])
	ThenV("texts: WalkZigZag", oT.WalkZigZag(2), [ 1, 3, 5, 5, 3, 1 ])
	ThenV("texts: WalkEveryNth", oT.WalkEveryNth(2), [ 2, 4 ])
	ThenV("texts: WalkSkipping", oT.WalkSkipping(1), [ 1, 3, 5 ])
	ThenV("texts: WalkFromTo", oT.WalkFromTo(2, 4), [ 2, 3, 4 ])
	ThenV("texts: WalkAccumulating keeps the items", oT.WalkAccumulating("@item"), aTexts)
	ThenV("a stzList object is accepted in place of a list", (new stzListWalker(new stzList([ 1, 2, 3 ]))).WalkNBackward(1), [ 3, 2, 1 ])
	cErrI = ErrOf("new stzListWalker(5)")
	ThenV("anything else raises", substr(cErrI, "must be a list or stzList") > 0, 1)
	ThenV("the walks never changed the list", oN.Content(), aNums)
EndScenario()

Summary()

func ErrOf(cCode)
	try
		eval(cCode)
		return ""
	catch
		return cCatchError
	done

# Then() compares with '=', which does not compare lists: both sides go through @@ first.
# Ring passes a list BY REFERENCE, so the parameters are copied to locals: assigning to them would
# overwrite the caller's list (aNums became a text and the later assertions compared the wrong thing).
func ThenV(cText, xActual, xExpected)
	vThenA = xActual
	vThenE = xExpected
	if isList(xActual) or isList(xExpected)
		vThenA = @@(xActual)
		vThenE = @@(xExpected)
	ok
	Then(cText, vThenA, vThenE)
