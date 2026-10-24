load "../../stzBase.ring"
load "../_narrated.ring"
decimals(4)

# stzSetOfSections (base/list/stzSetOfSections.ring) -- the two register rows, plus the Update and Copy defects the
# class carried, run on invented sets whose answers were written by hand BEFORE the code was changed.
# Run from inside this folder:  ring stzSetOfSections_defects_narrated.ring
#
# The register said: (1) init raises "Can't create the stzSetOfSections object" for every argument, because the check
# calls @IsSetOfSections, a function with an empty body, and the working IsSetOfSections fails with R14 (stzList has no
# IsListOfSections method); (2) IntersectionWith only raises "Feature not implemented yet!". Also: Update tested a
# variable that does not exist (paSections) and Copy returned the object itself.
#
# THE RULES, decided before the code (a set of sections = a set of [ start, end ] pairs of numbers):
#     valid        a list of pairs of exactly two numbers, no pair twice; [ ] is the empty set. The order of the two
#                  numbers is NOT checked (stzSection and IsListOfSections accept [ 7, 5 ]); floats are numbers.
#     the same     two pairs are the same when their numbers are equal: [ 1, 3 ] repeats [ 1.0, 3.0 ];
#                  [ 1, 3 ] and [ 3, 1 ] are two pairs
#     intersection the pairs held by BOTH sets, in the order of the FIRST set, as a NEW set; plain set semantics,
#                  not the range two overlapping sections have in common ([ 1, 5 ] with [ 3, 8 ] shares nothing)
#
# THE SET USED THROUGHOUT
#     A = [ [1,3], [5,7], [2,9], [4,4] ]
#
# Every positive carries a negative sibling. ASCII only on the console.

$nSosBait = 0

# --- 1. Construction ---------------------------------------------------------------------------------
Scenario("a set of sections is built from the valid shapes and keeps the order given")
	When("a set is built from each valid shape")
	Then("the empty set", SosBuild([]), "[ ]")
	Then("one pair", SosBuild([ [ 1, 3 ] ]), "[ [ 1, 3 ] ]")
	Then("two pairs", SosBuild([ [ 1, 3 ], [ 5, 7 ] ]), "[ [ 1, 3 ], [ 5, 7 ] ]")
	Then("overlapping but distinct pairs", SosBuild([ [ 1, 5 ], [ 3, 8 ], [ 1, 6 ] ]), "[ [ 1, 5 ], [ 3, 8 ], [ 1, 6 ] ]")
	Then("a reversed pair is a section, as in stzSection", SosBuild([ [ 7, 5 ] ]), "[ [ 7, 5 ] ]")
	Then("a pair and its reverse are two pairs", SosBuild([ [ 1, 3 ], [ 3, 1 ] ]), "[ [ 1, 3 ], [ 3, 1 ] ]")
	oF = new stzSetOfSections([ [ 1.5, 2.5 ] ])
	aF = oF.Content()
	Then("floats are numbers, kept as given", "" + (aF[1][1] = 1.5) + (aF[1][2] = 2.5), "11")
	Then("the order given is kept, not sorted", SosBuild([ [ 5, 7 ], [ 1, 3 ] ]), "[ [ 5, 7 ], [ 1, 3 ] ]")
	Then("zero and negative numbers are numbers", SosBuild([ [ 0, -2 ] ]), "[ [ 0, -2 ] ]")
	Then("StzSetOfSectionsQ builds the same", @@(StzSetOfSectionsQ([ [ 1, 3 ] ]).Content()), "[ [ 1, 3 ] ]")
	o = new stzSetOfSections([ [ 1, 3 ] ])
	Then("the object is a stzSetOfSections", ring_classname(o), "stzsetofsections")
EndScenario()

Scenario("every invalid shape is refused with the constructor's message")
	cMsg = "Can't create the stzSetOfSections object"
	Then("a pair given twice", SosRefuses([ [ 1, 3 ], [ 1, 3 ] ], cMsg), 1)
	Then("a pair given twice, not next to itself", SosRefuses([ [ 1, 3 ], [ 5, 7 ], [ 1, 3 ] ], cMsg), 1)
	Then("a pair equal to another by value, 1.0 and 3.0", SosRefuses([ [ 1, 3 ], [ 1.0, 3.0 ] ], cMsg), 1)
	Then("a pair of three numbers", SosRefuses([ [ 1, 3, 5 ] ], cMsg), 1)
	Then("a pair of one number", SosRefuses([ [ 1 ] ], cMsg), 1)
	Then("an empty pair", SosRefuses([ [ ] ], cMsg), 1)
	Then("a pair holding a text", SosRefuses([ [ "a", "b" ] ], cMsg), 1)
	Then("a pair holding a number as text", SosRefuses([ [ 1, "3" ] ], cMsg), 1)
	Then("a list of numbers", SosRefuses([ 1, 2 ], cMsg), 1)
	Then("a pair nested one level too deep", SosRefuses([ [ [ 1, 3 ] ] ], cMsg), 1)
	Then("a text", SosRefuses("text", cMsg), 1)
	Then("a number", SosRefuses(7, cMsg), 1)
	Then("a named-parameter list, which only Update takes", SosRefuses([ :With, [ [ 1, 3 ] ] ], cMsg), 1)
	Then("NEGATIVE: a valid set is not refused", SosRefuses([ [ 1, 3 ], [ 5, 7 ] ], cMsg), 0)
	Then("NEGATIVE: the empty set is not refused", SosRefuses([], cMsg), 0)
EndScenario()

Scenario("a refused creation leaves a usable empty set behind, and the class keeps working")
	oK = new stzSetOfSections([ [ 1, 3 ] ])
	cErr = ""
	try
		oK = new stzSetOfSections([ [ 1, 3 ], [ 1, 3 ] ])
	catch
		cErr = cCatchError
	done
	Then("the refused creation raised", cErr != "", 1)
	# Ring puts the new object in the variable BEFORE init runs, so the refused creation cannot leave the old value:
	# what the variable holds is the object with nothing set, which is the empty set and not a half-built one.
	Then("the variable holds an empty set, not a broken object", @@(oK.Content()), "[ ]")
	Then("that object is a stzSetOfSections", ring_classname(oK), "stzsetofsections")
	oK.Update([ [ 6, 6 ] ])
	Then("and it takes an Update", @@(oK.Content()), "[ [ 6, 6 ] ]")
	Then("NEGATIVE: it holds no leftover of the refused list", len(oK.Content()), 1)
	oK = new stzSetOfSections([ [ 8, 9 ] ])
	Then("the next valid creation works", @@(oK.Content()), "[ [ 8, 9 ] ]")
	oK.Update([ [ 2, 4 ] ])
	Then("and so does Update on it", @@(oK.Content()), "[ [ 2, 4 ] ]")
EndScenario()

# --- 2. IsSetOfSections: a table of inputs ---------------------------------------------------------
Scenario("IsSetOfSections answers 1 or 0 for twenty-two inputs and raises for none")
	oObj = new stzSetOfSections([ [ 1, 3 ] ])
	Then("01 empty list", SosIs([]), "1")
	Then("02 one pair", SosIs([ [ 1, 3 ] ]), "1")
	Then("03 two pairs", SosIs([ [ 1, 3 ], [ 5, 7 ] ]), "1")
	Then("04 same start, other end", SosIs([ [ 1, 3 ], [ 1, 4 ] ]), "1")
	Then("05 a pair and its reverse", SosIs([ [ 1, 3 ], [ 3, 1 ] ]), "1")
	Then("06 a reversed pair", SosIs([ [ 7, 5 ] ]), "1")
	Then("07 floats", SosIs([ [ 1.5, 2.5 ] ]), "1")
	Then("08 a repeated pair", SosIs([ [ 1, 3 ], [ 1, 3 ] ]), "0")
	Then("09 a repeated pair by value", SosIs([ [ 1, 3 ], [ 1.0, 3.0 ] ]), "0")
	Then("10 a pair of three", SosIs([ [ 1, 3, 5 ] ]), "0")
	Then("11 a pair of one", SosIs([ [ 1 ] ]), "0")
	Then("12 a pair of texts", SosIs([ [ "a", "b" ] ]), "0")
	Then("13 a number as text", SosIs([ [ 1, "3" ] ]), "0")
	Then("14 a list of numbers", SosIs([ 1, 2 ]), "0")
	Then("15 a text", SosIs("text"), "0")
	Then("16 a number", SosIs(7), "0")
	Then("17 a repeated pair far apart", SosIs([ [ 1, 3 ], [ 5, 7 ], [ 1, 3 ] ]), "0")
	Then("18 a named-parameter list", SosIs([ :With, [ [ 1, 3 ] ] ]), "0")
	Then("19 a pair too deep", SosIs([ [ [ 1, 3 ] ] ]), "0")
	Then("20 an empty pair", SosIs([ [ ] ]), "0")
	Then("21 a text that looks like a list, never evaluated", SosIs("[ [ 1, 3 ] ]"), "0")
	Then("22 an object", SosIs(oObj), "0")
	Then("a text that is code is not run", SosIs("$nSosBait = 7"), "0")
	Then("and the variable it names is untouched", $nSosBait, 0)
	Then("the alias answers a number, 1 for a set", @IsSetOfSections([ [ 1, 3 ] ]), 1)
	Then("the alias answers a number, 0 for a repeated pair", @IsSetOfSections([ [ 1, 3 ], [ 1, 3 ] ]), 0)
	Then("NEGATIVE: the alias no longer answers an empty text", isNumber(@IsSetOfSections([ [ 1, 3 ] ])), 1)
EndScenario()

# --- 3. Content -----------------------------------------------------------------------------------------
Scenario("Content returns the sections and the caller cannot corrupt the set through the list")
	o = new stzSetOfSections([ [ 1, 3 ], [ 5, 7 ] ])
	aC = o.Content()
	aC[1][1] = 99
	aC + [ 100, 101 ]
	Then("the list changed", @@(aC), "[ [ 99, 3 ], [ 5, 7 ], [ 100, 101 ] ]")
	Then("the set did not", @@(o.Content()), "[ [ 1, 3 ], [ 5, 7 ] ]")
	aIn = [ [ 2, 4 ] ]
	o2 = new stzSetOfSections(aIn)
	aIn[1][1] = 77
	Then("NEGATIVE: the list the set was built from does not reach into it", @@(o2.Content()), "[ [ 2, 4 ] ]")
EndScenario()

# --- 4. Update, UpdateWith ---------------------------------------------------------------------------
Scenario("Update replaces the sections, validated exactly like the constructor")
	o = new stzSetOfSections([ [ 1, 3 ] ])
	When("Update takes a valid list")
	Then("it ran", SosUpd(o, [ [ 8, 8 ], [ 9, 10 ] ]), "ok")
	Then("the sections are replaced", @@(o.Content()), "[ [ 8, 8 ], [ 9, 10 ] ]")
	Then("the named form ran", SosUpd(o, [ :With, [ [ 4, 5 ] ] ]), "ok")
	Then("the named form [ :With, list ] is read", @@(o.Content()), "[ [ 4, 5 ] ]")
	Then("the lower-case name ran", SosUpd(o, [ :with, [ [ 6, 7 ] ] ]), "ok")
	Then("and its name is not case-sensitive", @@(o.Content()), "[ [ 6, 7 ] ]")
	Then("the empty update ran", SosUpd(o, []), "ok")
	Then("the empty set is a valid update", @@(o.Content()), "[ ]")
	o.UpdateWith([ [ 2, 6 ], [ 6, 2 ] ])
	Then("UpdateWith does the same", @@(o.Content()), "[ [ 2, 6 ], [ 6, 2 ] ]")
	o.UpdateWith([ :With, [ [ 3, 3 ] ] ])
	Then("and takes the named form", @@(o.Content()), "[ [ 3, 3 ] ]")
EndScenario()

Scenario("an invalid Update raises and leaves the set as it was")
	o = new stzSetOfSections([ [ 1, 3 ], [ 5, 7 ] ])
	cMsg = "paNewSections must be a list of sections"
	Then("a repeated pair raises", SosUpdateRefuses(o, [ [ 1, 3 ], [ 1, 3 ] ], cMsg), 1)
	Then("and the set is unchanged", @@(o.Content()), "[ [ 1, 3 ], [ 5, 7 ] ]")
	Then("a text raises", SosUpdateRefuses(o, "x", cMsg), 1)
	Then("a number raises", SosUpdateRefuses(o, 5, cMsg), 1)
	Then("a pair of three raises", SosUpdateRefuses(o, [ [ 1, 2, 3 ] ], cMsg), 1)
	Then("a pair of texts raises", SosUpdateRefuses(o, [ [ "a", 1 ] ], cMsg), 1)
	Then("a named form holding a repeated pair raises", SosUpdateRefuses(o, [ :With, [ [ 1, 1 ], [ 1, 1 ] ] ], cMsg), 1)
	Then("a named form holding a text raises", SosUpdateRefuses(o, [ :With, "x" ], cMsg), 1)
	Then("and after all of them the set is unchanged", @@(o.Content()), "[ [ 1, 3 ], [ 5, 7 ] ]")
	Then("UpdateWith refuses a repeated pair too", SosUpdateWithRefuses(o, [ [ 2, 2 ], [ 2, 2 ] ], cMsg), 1)
	Then("and leaves the set unchanged", @@(o.Content()), "[ [ 1, 3 ], [ 5, 7 ] ]")
	Then("NEGATIVE: a valid update is not refused", SosUpdateRefuses(o, [ [ 9, 9 ] ], cMsg), 0)
EndScenario()

# --- 5. Copy -------------------------------------------------------------------------------------------
Scenario("Copy gives an independent set with the same sections")
	o = new stzSetOfSections([ [ 1, 3 ], [ 5, 7 ] ])
	oC = o.Copy()
	Then("the copy holds the same sections", @@(oC.Content()), "[ [ 1, 3 ], [ 5, 7 ] ]")
	Then("it is a stzSetOfSections", ring_classname(oC), "stzsetofsections")
	oC.Update([ [ 8, 8 ] ])
	Then("updating the copy changes the copy", @@(oC.Content()), "[ [ 8, 8 ] ]")
	Then("NEGATIVE: and not the original", @@(o.Content()), "[ [ 1, 3 ], [ 5, 7 ] ]")
	o.Update([ [ 2, 2 ] ])
	Then("updating the original changes the original", @@(o.Content()), "[ [ 2, 2 ] ]")
	Then("NEGATIVE: and not the copy", @@(oC.Content()), "[ [ 8, 8 ] ]")
	oE = new stzSetOfSections([])
	oEC = oE.Copy()
	oEC.Update([ [ 1, 1 ] ])
	Then("a copy of the empty set is independent too", @@(oE.Content()) + " " + @@(oEC.Content()), "[ ] [ [ 1, 1 ] ]")
	oCC = oC.Copy().Copy()
	oCC.Update([ [ 4, 4 ] ])
	Then("a copy of a copy of a copy leaves its source alone", @@(oC.Content()), "[ [ 8, 8 ] ]")
EndScenario()

# --- 6. IntersectionWith -----------------------------------------------------------------------------
Scenario("IntersectionWith keeps the pairs both sets hold, in the order of this set")
	oA = new stzSetOfSections(SosA())
	Then("a disjoint set shares nothing", SosInter(oA, [ [ 10, 11 ], [ 3, 1 ] ]), "[ ]")
	Then("an identical set shares everything, in order", SosInter(oA, SosA()), "[ [ 1, 3 ], [ 5, 7 ], [ 2, 9 ], [ 4, 4 ] ]")
	Then("a partial overlap, in the order of this set and not of the other", SosInter(oA, [ [ 2, 9 ], [ 8, 8 ], [ 1, 3 ] ]), "[ [ 1, 3 ], [ 2, 9 ] ]")
	Then("the other set reversed gives this order, not the reverse", SosInter(oA, [ [ 4, 4 ], [ 2, 9 ], [ 5, 7 ], [ 1, 3 ] ]), "[ [ 1, 3 ], [ 5, 7 ], [ 2, 9 ], [ 4, 4 ] ]")
	Then("NEGATIVE: a pair and its reverse are not shared", SosInter(oA, [ [ 3, 1 ], [ 7, 5 ] ]), "[ ]")
	Then("NEGATIVE: ranges that overlap share nothing, it is not a range intersection", SosInter(new stzSetOfSections([ [ 1, 5 ] ]), [ [ 3, 8 ] ]), "[ ]")
	Then("a pair equal by value is shared, 7.0 for 7", SosInter(oA, [ [ 5, 7.0 ] ]), "[ [ 5, 7 ] ]")
	Then("a single shared pair", SosInter(oA, [ [ 4, 4 ] ]), "[ [ 4, 4 ] ]")
EndScenario()

Scenario("IntersectionWith with an empty set, whatever the other holds")
	oA = new stzSetOfSections(SosA())
	oE = new stzSetOfSections([])
	Then("this set with the empty list", SosInter(oA, []), "[ ]")
	Then("the empty set with a set", @@(oE.IntersectionWith(oA).Content()), "[ ]")
	Then("the empty set with a plain list", SosInter(oE, SosA()), "[ ]")
	Then("the empty set with the empty set", @@(oE.IntersectionWith(new stzSetOfSections([])).Content()), "[ ]")
	Then("the answer is still a set", ring_classname(oE.IntersectionWith(oA)), "stzsetofsections")
EndScenario()

Scenario("IntersectionWith takes a set object or a plain list, and refuses the rest")
	oA = new stzSetOfSections(SosA())
	oB = new stzSetOfSections([ [ 5, 7 ], [ 9, 9 ] ])
	oRes = oA.IntersectionWith(oB)
	Then("a stzSetOfSections argument", @@(oRes.Content()), "[ [ 5, 7 ] ]")
	Then("the answer is a new stzSetOfSections", ring_classname(oRes), "stzsetofsections")
	Then("a plain list argument gives the same", SosInter(oA, [ [ 5, 7 ], [ 9, 9 ] ]), "[ [ 5, 7 ] ]")
	cMsg = "Can't intersect with the other sections"
	Then("a plain list with a repeated pair raises", SosInterRefuses(oA, [ [ 5, 7 ], [ 5, 7 ] ], cMsg), 1)
	Then("a list of texts raises", SosInterRefuses(oA, [ [ "a", "b" ] ], cMsg), 1)
	Then("a text raises", SosInterRefuses(oA, "x", cMsg), 1)
	Then("a number raises", SosInterRefuses(oA, 5, cMsg), 1)
	Then("a pair of three raises", SosInterRefuses(oA, [ [ 1, 2, 3 ] ], cMsg), 1)
	Then("an object of another class raises", SosInterRefuses(oA, new stzSet([ [ 1, 3 ] ]), cMsg), 1)
	Then("NEGATIVE: a valid plain list does not raise", SosInterRefuses(oA, [ [ 5, 7 ] ], cMsg), 0)
	Then("the intersection raised before changing anything", @@(oA.Content()), "[ [ 1, 3 ], [ 5, 7 ], [ 2, 9 ], [ 4, 4 ] ]")
EndScenario()

Scenario("IntersectionWith leaves both operands untouched and hands back a set of its own")
	oA = new stzSetOfSections(SosA())
	oB = new stzSetOfSections([ [ 5, 7 ], [ 1, 3 ], [ 6, 6 ] ])
	oRes = oA.IntersectionWith(oB)
	Then("this set is as it was", @@(oA.Content()), "[ [ 1, 3 ], [ 5, 7 ], [ 2, 9 ], [ 4, 4 ] ]")
	Then("the other set is as it was", @@(oB.Content()), "[ [ 5, 7 ], [ 1, 3 ], [ 6, 6 ] ]")
	Then("the answer", @@(oRes.Content()), "[ [ 1, 3 ], [ 5, 7 ] ]")
	oRes.Update([ [ 0, 0 ] ])
	Then("updating the answer does not reach this set", @@(oA.Content()), "[ [ 1, 3 ], [ 5, 7 ], [ 2, 9 ], [ 4, 4 ] ]")
	Then("nor the other set", @@(oB.Content()), "[ [ 5, 7 ], [ 1, 3 ], [ 6, 6 ] ]")
	oS = oA.IntersectionWith(oA)
	oS.Update([ [ 0, 0 ] ])
	Then("a set with itself is a set of its own", @@(oA.Content()), "[ [ 1, 3 ], [ 5, 7 ], [ 2, 9 ], [ 4, 4 ] ]")
	Then("Intersection is the same call", @@(oA.Intersection(oB).Content()), "[ [ 1, 3 ], [ 5, 7 ] ]")
	Then("and takes a plain list", @@(oA.Intersection([ [ 4, 4 ] ]).Content()), "[ [ 4, 4 ] ]")
	cErr = ""
	try
		oA.Intersection([ [ 4, 4 ], [ 4, 4 ] ])
	catch
		cErr = cCatchError
	done
	Then("and refuses what IntersectionWith refuses", cErr != "", 1)
EndScenario()

# --- 7. History ----------------------------------------------------------------------------------------
Scenario("the history hook raises nothing, with history on or off")
	KeepHistoryOFF()
	o = new stzSetOfSections([ [ 1, 3 ] ])
	o.CleanHistory()
	o = new stzSetOfSections([ [ 1, 3 ] ])
	o.Update([ [ 2, 4 ] ])
	Then("history off: nothing is kept", len(o.HistoricValues()), 0)
	KeepHistoryON()
	cErr = ""
	try
		o = new stzSetOfSections([ [ 1, 3 ], [ 5, 7 ] ])
		o.Update([ [ 2, 4 ] ])
		oC = o.Copy()
		oRes = o.IntersectionWith([ [ 2, 4 ] ])
		o.Update([ [ 1, 1 ], [ 1, 1 ] ])
	catch
		cErr = cCatchError
	done
	aHist = o.HistoricValues()
	KeepHistoryOFF()
	Then("history on: the last update was refused and nothing else raised first", SosHas(cErr, "paNewSections"), 1)
	Then("the history holds the build, the update, the copy and the answer, and not the refused update", len(aHist), 4)
	Then("the first value is the set as built", @@(aHist[1]), "[ [ 1, 3 ], [ 5, 7 ] ]")
	Then("the second is the set after the update", @@(aHist[2]), "[ [ 2, 4 ] ]")
	Then("history is off again", KeepingHistory(), 0)
EndScenario()

# --- 8. What the class inherits ------------------------------------------------------------------------
Scenario("the inherited readers answer on a set and the inherited verbs keep it a set")
	oI = new stzSetOfSections([ [ 1, 3 ], [ 5, 7 ], [ 2, 9 ] ])
	Then("NumberOfItems", oI.NumberOfItems(), 3)
	Then("Item(2)", @@(oI.Item(2)), "[ 5, 7 ]")
	Then("FirstItem", @@(oI.FirstItem()), "[ 1, 3 ]")
	Then("LastItem", @@(oI.LastItem()), "[ 2, 9 ]")
	Then("Find of a pair", @@(oI.Find([ 5, 7 ])), "[ 2 ]")
	Then("Sorted leaves the set in its order", @@(oI.Sorted()) + " " + @@(oI.Content()), "[ [ 1, 3 ], [ 2, 9 ], [ 5, 7 ] ] [ [ 1, 3 ], [ 5, 7 ], [ 2, 9 ] ]")
	Then("Merged joins the overlapping sections and leaves the set", @@(oI.Merged()) + " " + @@(oI.Content()), "[ [ 1, 9 ] ] [ [ 1, 3 ], [ 5, 7 ], [ 2, 9 ] ]")
	Then("IsSet", oI.IsSet(), 1)
	oI.AddItem([ 8, 9 ])
	Then("AddItem of a new pair goes through", @@(oI.Content()), "[ [ 1, 3 ], [ 5, 7 ], [ 2, 9 ], [ 8, 9 ] ]")
	cErr = ""
	try
		oI.AddItem([ 5, 7 ])
	catch
		cErr = cCatchError
	done
	Then("NEGATIVE: AddItem of a pair already held raises", SosHas(cErr, "paNewSections must be a list of sections"), 1)
	Then("and the set is unchanged", @@(oI.Content()), "[ [ 1, 3 ], [ 5, 7 ], [ 2, 9 ], [ 8, 9 ] ]")
	oI.Reverse()
	Then("Reverse changes the set and it stays a set", @@(oI.Content()) + " " + IsSetOfSections(oI.Content()), "[ [ 8, 9 ], [ 2, 9 ], [ 5, 7 ], [ 1, 3 ] ] 1")
	oI.Merge()
	Then("Merge changes the set and it stays a set", @@(oI.Content()) + " " + IsSetOfSections(oI.Content()), "[ [ 1, 9 ] ] 1")
EndScenario()

# --- 9. Scale ------------------------------------------------------------------------------------------
Scenario("two sets of 2,000 pairs are checked and intersected without a quadratic scan")
	# The measure, 2026-10-24: 2,000 pairs built in about 27 ms and intersected with another in about 21 ms; 8,000 in
	# 109 and 82 ms, that is four times the work for four times the time. A scan comparing every pair with every pair
	# would take 16 times as long for four times the pairs. The bands leave a factor of ten above the measure.
	nBuild2 = SosBest(2000, 0)
	nBuild8 = SosBest(8000, 0)
	nInter2 = SosBest(2000, 1)
	nInter8 = SosBest(8000, 1)
	Then("2,000 pairs are built under 300 ms", nBuild2 < 300, 1)
	Then("2,000 pairs are intersected under 300 ms", nInter2 < 300, 1)
	Then("the build of 8,000 takes less than ten times the build of 2,000", nBuild8 < 10 * (nBuild2 + 10), 1)
	Then("the intersection of 8,000 takes less than ten times that of 2,000", nInter8 < 10 * (nInter2 + 10), 1)
	oBig = new stzSetOfSections(SosRamp(1, 2000))
	oHalf = new stzSetOfSections(SosRamp(1001, 3000))
	oBRes = oBig.IntersectionWith(oHalf)
	Then("the 2,000-pair intersection holds 1,000 pairs", len(oBRes.Content()), 1000)
	aBR = oBRes.Content()
	Then("the first of them is the pair 1001", @@(aBR[1]), "[ 1001, 2002 ]")
	Then("the last is the pair 2000", @@(aBR[1000]), "[ 2000, 4000 ]")
	Then("NEGATIVE: a repeated pair hidden in 2,000 is found", SosIs(SosWithTwin()), "0")
EndScenario()

Summary()

#------------------------------ helpers ------------------------------------------------------------------

func SosA()
	return [ [ 1, 3 ], [ 5, 7 ], [ 2, 9 ], [ 4, 4 ] ]

func SosBuild(aList)
	try
		oB = new stzSetOfSections(aList)
		return @@(oB.Content())
	catch
		return "RAISED " + cCatchError
	done

func SosHas(cMsg, cNeedle)
	return len(StzFind(cNeedle, cMsg)) > 0

func SosRefuses(x, cNeedle)
	try
		oRes = new stzSetOfSections(x)
		return 0
	catch
		return SosHas(cCatchError, cNeedle)
	done

func SosIs(x)
	cRes = ""
	try
		cRes = "" + IsSetOfSections(x)
	catch
		cRes = "RAISED " + cCatchError
	done
	return cRes

func SosUpdateRefuses(o, x, cNeedle)
	try
		o.Update(x)
		return 0
	catch
		return SosHas(cCatchError, cNeedle)
	done

func SosUpdateWithRefuses(o, x, cNeedle)
	try
		o.UpdateWith(x)
		return 0
	catch
		return SosHas(cCatchError, cNeedle)
	done

func SosInterRefuses(o, x, cNeedle)
	try
		o.IntersectionWith(x)
		return 0
	catch
		return SosHas(cCatchError, cNeedle)
	done

func SosInter(o, x)
	try
		return @@(o.IntersectionWith(x).Content())
	catch
		return "RAISED " + cCatchError
	done

# Update that reports instead of aborting the run, so a broken Update fails assertions and does not stop the guard.
func SosUpd(o, x)
	try
		o.Update(x)
		return "ok"
	catch
		return "RAISED " + cCatchError
	done

func SosRamp(nFrom, nTo)
	aRamp = []
	for i = nFrom to nTo
		aRamp + [ i, i * 2 ]
	next
	return aRamp

func SosWithTwin()
	aTwin = SosRamp(1, 2000)
	aTwin + [ 1000, 2000 ]
	return aTwin

# Best of three runs, in ms, of the build (nWhat = 0) or of the intersection (nWhat = 1) of n pairs against n pairs
# half of which are shared.
func SosBest(n, nWhat)
	nBest = 1000000
	for k = 1 to 3
		aA = SosRamp(1, n)
		aB = SosRamp((n / 2) + 1, (n / 2) + n)
		if nWhat = 0
			t0 = clock()
			oA = new stzSetOfSections(aA)
			t1 = clock()
		else
			oA = new stzSetOfSections(aA)
			oB = new stzSetOfSections(aB)
			t0 = clock()
			oRes = oA.IntersectionWith(oB)
			t1 = clock()
		ok
		nMs = (t1 - t0) * 1000 / clockspersecond()
		if nMs < nBest
			nBest = nMs
		ok
	next
	return nBest
