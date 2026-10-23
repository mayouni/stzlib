load "../../stzBase.ring"
load "../_narrated.ring"

# stzEntity -- the register's three rows (IsOfType, HasName, IsEmpty). Run from inside test/natural.
#
#   IsOfType, HasName   lower-cased only the ARGUMENT before comparing it with the stored text, so a
#                       stored type such as Person or a stored name such as Ana never matched (and
#                       neither did the same text typed back in the same case).
#   IsEmpty             tested that the size equals 2, but the creation stamp is always a third
#                       property, so it was never TRUE.
#
# The rule now: the entity stores a name and a type AS GIVEN, and the two predicates compare both
# sides in one normal form (the engine's lower-casing, which folds accents too), so they are
# case-insensitive. Equal means the whole text: a prefix does not match. A value that is not a text
# answers 0. IsEmpty is TRUE when nothing is held beyond name, type and created.
#
# The expectations are written by hand. Texts beyond ASCII are built from char codes and never
# printed. Every positive has a negative sibling. Then() compares texts case-insensitively, so every
# question that is about case is turned into a number first.

eSmall = char(195) + char(169)                  # e acute, small
eCap   = char(195) + char(137)                  # E acute, capital
alef   = char(215) + char(144)
bet    = char(215) + char(145)
gimel  = char(215) + char(146)

Scenario("HasName: the stored name Ana is found, in any case, and only whole")
	Given("an entity named Ana of type Person with an age")
	oA = Ana()
	r = oA.HasName("Ana")
	Then("the name typed as stored matches", r, 1)
	r = oA.HasName("ana")
	Then("the name in small letters matches", r, 1)
	r = oA.HasName("ANA")
	Then("the name in capitals matches", r, 1)
	r = oA.HasName("Bob")
	Then("a different name does not match", r, 0)
	r = oA.HasName("An")
	Then("a prefix of the stored name does not match", r, 0)
	r = oA.HasName("Anan")
	Then("a name that extends the stored one does not match", r, 0)
	r = oA.HasName("")
	Then("the empty name does not match a stored name", r, 0)
	r = oA.HasName(5)
	Then("a number answers 0", r, 0)
	r = oA.HasName([ "Ana" ])
	Then("a list answers 0", r, 0)
	r = isNumber(oA.HasName("Ana"))
	Then("the answer is a plain number", r, 1)
	r = strcmp(oA.Name(), "Ana")
	Then("the name is still stored as given", r, 0)
	r = strcmp(oA.Name(), "ana") != 0
	Then("and not lower-cased", r, 1)
EndScenario()

Scenario("HasName: the lower-case entity, the renamed one, the empty name")
	Given("an entity stored in small letters, as the older tests build it")
	oL = new stzEntity([ :name = "ana", :type = "person" ])
	r = oL.HasName("ana")
	Then("small letters match small letters", r, 1)
	r = oL.HasName("ANA")
	Then("capitals match small letters", r, 1)
	r = oL.HasName("anb")
	Then("a different name does not match", r, 0)
	Given("the same entity renamed to Bob")
	oL.SetName("Bob")
	r = oL.HasName("bob")
	Then("the new name matches in small letters", r, 1)
	r = oL.HasName("ana")
	Then("the old name does not match any more", r, 0)
	Given("an entity whose stored name is the empty text")
	oE = new stzEntity([ :name = "", :type = "person" ])
	r = oE.HasName("")
	Then("the empty name matches the empty stored name", r, 1)
	r = oE.HasName("a")
	Then("a letter does not match the empty stored name", r, 0)
	Given("an entity given no name")
	oN = new stzEntity([ :type = "person" ])
	r = oN.HasName("@noname")
	Then("the default name matches", r, 1)
	r = oN.HasName("noname")
	Then("the default name without its at sign does not", r, 0)
EndScenario()

Scenario("HasName: accented and Hebrew names fold in the engine, not by bytes")
	Given("an entity named Zo plus E acute in capital")
	oZ = new stzEntity([ :name = "Zo" + eCap, :type = "person" ])
	r = oZ.HasName("Zo" + eCap)
	Then("the same capital matches", r, 1)
	r = oZ.HasName("Zo" + eSmall)
	Then("the small accented form matches the capital", r, 1)
	r = oZ.HasName("ZO" + eCap)
	Then("ASCII capitals around the accent match", r, 1)
	r = oZ.HasName("Zoe")
	Then("the unaccented letter does not match", r, 0)
	r = oZ.HasName("Zo")
	Then("a prefix does not match", r, 0)
	Given("an entity named with two Hebrew letters")
	oH = new stzEntity([ :name = alef + bet, :type = "person" ])
	r = oH.HasName(alef + bet)
	Then("the same letters match", r, 1)
	r = oH.HasName(bet + alef)
	Then("the letters in the other order do not", r, 0)
	r = oH.HasName(alef)
	Then("a prefix of the Hebrew name does not", r, 0)
	r = oH.HasName(alef + bet + gimel)
	Then("an extension of the Hebrew name does not", r, 0)
EndScenario()

Scenario("IsOfType: the stored type Person is found, in any case, and only whole")
	Given("an entity named Ana of type Person")
	oA = Ana()
	r = oA.IsOfType("Person")
	Then("the type typed as stored matches", r, 1)
	r = oA.IsOfType("person")
	Then("the type in small letters matches", r, 1)
	r = oA.IsOfType("PERSON")
	Then("the type in capitals matches", r, 1)
	r = oA.IsOfType("Robot")
	Then("a different type does not match", r, 0)
	r = oA.IsOfType("Pers")
	Then("a prefix of the stored type does not match", r, 0)
	r = oA.IsOfType("Persons")
	Then("a type that extends the stored one does not match", r, 0)
	r = oA.IsOfType("")
	Then("the empty type does not match a stored type", r, 0)
	r = oA.IsOfType(5)
	Then("a number answers 0", r, 0)
	r = oA.IsOfType([ "Person" ])
	Then("a list answers 0", r, 0)
	r = strcmp(oA.Type(), "Person")
	Then("the type is still stored as given", r, 0)
	Given("an entity of type Organisation, after SetType")
	oO = Org()
	r = oO.IsOfType("organisation")
	Then("the organisation matches in small letters", r, 1)
	r = oO.IsOfType("person")
	Then("the organisation is not a person", r, 0)
	oO.SetType("Company")
	r = oO.IsOfType("COMPANY")
	Then("the new type matches", r, 1)
	r = oO.IsOfType("organisation")
	Then("the old type does not match any more", r, 0)
	Given("an entity given no type")
	oN = new stzEntity([ :name = "x" ])
	r = oN.IsOfType("undefined")
	Then("the default type matches", r, 1)
	r = oN.IsOfType("defined")
	Then("a part of the default type does not", r, 0)
EndScenario()

Scenario("IsOfType: accented and Hebrew types")
	Given("a type of Pers plus E acute in capital")
	oP = new stzEntity([ :name = "x", :type = "Pers" + eCap ])
	r = oP.IsOfType("pers" + eSmall)
	Then("the small accented form matches", r, 1)
	r = oP.IsOfType("pers")
	Then("the unaccented prefix does not", r, 0)
	r = oP.IsOfType("perse")
	Then("the unaccented letter does not", r, 0)
	Given("a type of two Hebrew letters")
	oH = new stzEntity([ :name = "x", :type = alef + bet ])
	r = oH.IsOfType(alef + bet)
	Then("the same letters match", r, 1)
	r = oH.IsOfType(bet + alef)
	Then("the other order does not", r, 0)
	r = oH.IsOfType("person")
	Then("a Latin type does not", r, 0)
	r = oH.IsOfType(alef)
	Then("a prefix does not", r, 0)
EndScenario()

Scenario("IsEmpty: only the name, the type and the creation stamp do not count")
	Given("an entity built with a name and a type only")
	oB = new stzEntity([ :name = "Ana", :type = "Person" ])
	r = oB.IsEmpty()
	Then("it is empty", r, 1)
	r = oB.Size()
	Then("it holds the three bookkeeping properties", r, 3)
	Given("an entity built with an age")
	oA = Ana()
	r = oA.IsEmpty()
	Then("it is not empty", r, 0)
	Given("an entity given its own created stamp")
	oC = new stzEntity([ :name = "Ana", :type = "Person", :created = "01/01/2000 00:00:00" ])
	r = oC.IsEmpty()
	Then("it is empty, the stamp being bookkeeping", r, 1)
	Given("an entity given neither name nor type but a property")
	oD = new stzEntity([ :x = 1 ])
	r = oD.IsEmpty()
	Then("the entity with a property of its own is not empty", r, 0)
	Given("an entity with a property that holds the empty text")
	oF = new stzEntity([ :name = "Ana", :type = "Person", :note = "" ])
	r = oF.IsEmpty()
	Then("a property holding nothing is still a property", r, 0)
	r = isNumber(oB.IsEmpty())
	Then("the answer is a plain number", r, 1)
EndScenario()

Scenario("IsEmpty: a property set later makes the entity not empty, and removed makes it empty")
	Given("an empty entity")
	oE = new stzEntity([ :name = "Ana", :type = "Person" ])
	r = oE.IsEmpty()
	Then("it is empty first", r, 1)
	oE.SetProperty("email", "ana@example.org")
	r = oE.IsEmpty()
	Then("with an email set it is not empty", r, 0)
	r = oE.Size()
	Then("and its size is 4", r, 4)
	oE.RemoveProperty("email")
	r = oE.IsEmpty()
	Then("with the email removed it is empty again", r, 1)
	r = oE.Size()
	Then("and its size is 3 again", r, 3)
	oE.SetProp("AGE", 30)
	r = oE.IsEmpty()
	Then("a capital-letter property name counts", r, 0)
	oE.RemoveProp("age")
	r = oE.IsEmpty()
	Then("and is removed in any case", r, 1)
	oE.Set@("a", 1)
	oE.@Set("b", 2)
	r = oE.IsEmpty()
	Then("two properties set through the aliases: not empty", r, 0)
	oE.Remove@("a")
	r = oE.IsEmpty()
	Then("one of two removed: still not empty", r, 0)
	oE.@Remove("b")
	r = oE.IsEmpty()
	Then("both removed: empty", r, 1)
	oE.@([ "k", 5 ])
	r = oE.IsEmpty()
	Then("a pair set through the one door: not empty", r, 0)
	oE.RemoveProperty("k")
	oE.@([ [ "k1", 1 ], [ "k2", 2 ] ])
	r = oE.IsEmpty()
	Then("a list of pairs set through the one door: not empty", r, 0)
	Given("the copy of an empty entity and the copy of one with a property")
	oE.RemoveProperty("k1")
	oE.RemoveProperty("k2")
	oCopy = oE.Copy()
	r = oCopy.IsEmpty()
	Then("the copy of an empty entity is empty", r, 1)
	oE.SetProperty("z", 1)
	oCopy = oE.Copy()
	r = oCopy.IsEmpty()
	Then("the copy of a non-empty entity is not empty", r, 0)
EndScenario()

Scenario("Every public method, once, on a person, an organisation, an accented and a Hebrew entity")
	Given("the methods of the class, each called on a fresh entity")
	acKinds = [ "ana", "org", "acc", "heb" ]
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
	r = nCalls > 50
	Then("the sweep covered more than fifty calls", r, 1)
	Given("the calls that must raise, as the blocks say")
	acBad = BadCalls()
	nBad = len(acBad)
	for k = 1 to 4
		nRaised = 0
		for j = 1 to nBad
			cOne = RunOne(acKinds[k], acBad[j])
			if cOne != ""
				nRaised++
			ok
		next
		Then("on " + acKinds[k] + ": all " + nBad + " bad calls raise", nRaised, nBad)
	next
EndScenario()

Scenario("The sibling predicates agree with the two that were repaired")
	Given("an entity built with capital-letter keys")
	oS = new stzEntity([ :Name = "Ana", :Type = "Person", :Age = 30 ])
	r = oS.HasName("ana")
	Then("the name key in capitals still gives the name", r, 1)
	r = oS.IsOfType("PERSON")
	Then("the type key in capitals still gives the type", r, 1)
	r = oS.ContainsProperty("age")
	Then("ContainsProperty ignores the case of the property", r, 1)
	r = oS.ContainsProperty("agee")
	Then("and a different property is absent", r, 0)
	r = oS.IsEmpty()
	Then("the entity with an Age is not empty", r, 0)
	oT = new stzEntity([ :Name = "Ana", :Type = "Person" ])
	r = oT.IsEmpty()
	Then("the entity with only capital-letter bookkeeping keys is empty", r, 1)
	r = oS.ContainsValue("ana")
	Then("ContainsValue keeps the exact case, as its block says", r, 0)
	r = oS.ContainsValue("Ana")
	Then("and finds the exact one", r, 1)
EndScenario()

Scenario("ContainsPropertyOrValue: a non-text argument skips the property test and falls through to the value test")
	Given("an entity named Ana with an age of 30, and one named Acme with no age")
	oA = Ana()
	oO = Org()
	r = oA.ContainsPropertyOrValue(30)
	Then("the number 30, present as a value, is found and nothing raises", r, 1)
	r = oO.ContainsPropertyOrValue(30)
	Then("the number 30, absent from the other entity, answers 0", r, 0)
	r = oA.ContainsPropertyOrValue(31)
	Then("another number, absent, answers 0", r, 0)
	r = oA.ContainsPropertyOrValue([ 1, 2 ])
	Then("a list that is no value answers 0 and does not raise", r, 0)
	cErr = RunOne("ana", "ContainsPropertyOrValue(30)")
	Then("the call raises nothing", cErr, "")
	cErr = RunOne("ana", "Contains@(30)")
	Then("the first alias raises nothing either", cErr, "")
	r = oA.Contains@(30)
	Then("and the alias answers like the method", r, 1)
	r = oO.@Contains(30)
	Then("the other alias answers 0 where the value is absent", r, 0)
	Given("a text argument, which behaves as before")
	r = oA.ContainsPropertyOrValue("age")
	Then("a text that is a property name is found", r, 1)
	r = oA.ContainsPropertyOrValue("AGE")
	Then("a property name in capitals is found, the case being ignored", r, 1)
	r = oA.ContainsPropertyOrValue("Ana")
	Then("a text that is a value is found", r, 1)
	r = oA.ContainsPropertyOrValue("Person")
	Then("the type, which is a value, is found", r, 1)
	r = oA.ContainsPropertyOrValue("zzz")
	Then("a text that is neither a property nor a value answers 0", r, 0)
	r = oA.ContainsPropertyOrValue("ana")
	Then("a value in another case is not found, the value test keeping the case", r, 0)
	r = oO.ContainsPropertyOrValue("age")
	Then("a property name the other entity lacks answers 0", r, 0)
	r = oO.ContainsPropertyOrValue("NE")
	Then("a value of the other entity is found there", r, 1)
	r = oA.ContainsPropertyOrValue("NE")
	Then("and absent from the first", r, 0)
EndScenario()

Summary()

func Ana()
	return new stzEntity([ :name = "Ana", :type = "Person", :age = 30 ])

func Org()
	return new stzEntity([ :name = "Acme", :type = "Organisation", :country = "NE" ])

func Mk(pcKind)
	if pcKind = "ana"
		return new stzEntity([ :name = "Ana", :type = "Person", :age = 30 ])
	but pcKind = "org"
		return new stzEntity([ :name = "Acme", :type = "Organisation", :age = 30 ])
	but pcKind = "acc"
		return new stzEntity([ :name = "Zo" + eCap, :type = "Pers" + eCap, :age = 30 ])
	ok
	return new stzEntity([ :name = alef + bet, :type = bet + alef, :age = 30 ])

func Calls()
	return [
		"Content()", "Value()", "Entity()", "Name()", "SetName('Bob')", "Type()", "SetType('Robot')", "Created()",
		"ContainsPropertyOrValue('age')", "ContainsPropertyOrValue('AGE')", "ContainsPropertyOrValue('Ana')",
		"Contains@('age')", "@Contains('age')", "ContainsValueOrProperty('age')", "ContainsPropOrVal('age')",
		"ContainsValOrPrep('age')",
		"ContainsProperty('age')", "ContainsProperty('AGE')", "ContainsProperty('zzz')",
		"ContainsPropertyOrValue(30)", "Contains@(30)", "ContainsValue(30)", "ContainsValue('Ana')", "ContainsValue('ana')", "ContainsValue('zzz')",
		"Property('age')", "Property('AGE')", "Prop('age')",
		"@('age')", "@([ 'k1', 5 ])", "@([ [ 'k2', 6 ], [ 'k3', 7 ] ])",
		"SetProperty('city', 'Niamey')", "SetProperty('CITY', 'Niamey')", "SetProp('c4', 1)", "Set@('c5', 2)", "@Set('c6', 3)",
		"FindProperty('age')", "FindProperty('AGE')", "FindProperty('zzz')", "FindProp('age')", "Find@('age')", "@Find('age')",
		"RemoveProperty('age')", "RemoveProp('age')", "Remove@('age')", "@Remove('age')",
		"Properties()", "Props()", "Values()",
		"IsOfType('Person')", "IsOfType('person')", "IsOfType(5)", "HasName('Ana')", "HasName('ana')", "HasName(5)",
		"Copy().Content()", "Size()", "NumberOfProperties()", "IsEmpty()"
	]

func BadCalls()
	return [
		"ContainsProperty(5)", "Property('zzz')", "@(5)", "RemoveProperty('zzz')",
		"SetName('two words')", "SetType(5)", "SetProperty(5, 1)"
	]

func RunOne(pcKind, pcCall)
	oRun = Mk(pcKind)
	cErr = ""
	try
		eval("xRun = oRun." + pcCall)
	catch
		cErr = cCatchError
		if cErr = ""
			cErr = "raised"
		ok
	done
	return cErr
