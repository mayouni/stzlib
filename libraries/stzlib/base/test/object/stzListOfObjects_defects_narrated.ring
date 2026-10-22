load "../../stzBase.ring"
load "../_narrated.ring"

# stzListOfObjects -- the register's three rows (init, Content, Copy). Run from inside test/object.
#
#   init      checked the list with IsListOfObjects called on a stzList, a method that does not
#             exist, so every list raised R14 and the class could not be built from a list at all.
#   Content   named the list and did not return it, so it answered the empty text.
#   Copy      called Content, got nothing, and init refused it.
#
# The rule now: init accepts a list whose every item is an object, of any class, and the empty
# list; it refuses a list with one item that is not an object (a number, a text, a list, an empty
# list) and a value that is not a list, with one message. Content returns the list. Ring copies an
# object when it is assigned, so the holder keeps its own copies: a list taken from Content into a
# variable, and the caller own list, can change without the holder noticing. One form does reach
# the holder and is asserted as it is: an in-place call chained on an element of the answer, as in
# o.Content()[1].Rename(...), acts on the holder own object. Copy returns an independent holder.
#
# The expectations are written by hand, with two classes of objects: a library class (stzString)
# and a tiny class of the test (Pet, with a name and a getter). Every positive has a negative
# sibling. Then() compares texts case-insensitively, so every answer that is about case is turned
# into a number first.

Scenario("init: a list of objects of two classes is accepted (the register R14 row)")
	Given("a library object, a Pet and a second Pet")
	oSs = new stzString("hello")
	aOb = [ oSs, new Pet("rex"), new Pet("tom") ]
	r = LoRefused(aOb)
	Then("the list is built, no error is raised", r, "")
	oH = new stzListOfObjects(aOb)
	r = classname(oH)
	Then("the holder is a stzlistofobjects", r, "stzlistofobjects")
	r = len(oH.Content())
	Then("the holder has the three objects", r, 3)
	aC = oH.Content()
	r = classname(aC[1])
	Then("the first keeps its class stzstring", r, "stzstring")
	r = classname(aC[2])
	Then("the second keeps its class pet", r, "pet")
	r = aC[3].Name()
	Then("the third answers its own name", r, "tom")
	r = aC[1].Content()
	Then("the library object keeps its text", r, "hello")
	r = LoRefused([ new Pet("only") ])
	Then("a list of one object is accepted", r, "")
	r = LoRefused([ new stzList([ 1, 2 ]), new stzNumber(5) ])
	Then("a list of two other library objects is accepted", r, "")
EndScenario()

Scenario("init: the empty list is a list of no objects and is accepted")
	Given("the empty list")
	r = LoRefused([])
	Then("it is accepted", r, "")
	oE = new stzListOfObjects([])
	r = len(oE.Content())
	Then("the holder is empty", r, 0)
	r = isList(oE.Content())
	Then("and its content is still a list", r, 1)
EndScenario()

Scenario("init: one item that is not an object refuses the whole list")
	Given("a list of objects with one wrong item in turn")
	oP = new Pet("rex")
	cMsg = "Incorrect param type! paoObjects must be a list of objects."
	r = LoRefused([ oP, 5 ])
	Then("a number among objects is refused with the message", r, cMsg)
	r = LoRefused([ oP, "text" ])
	Then("a text among objects is refused", r, cMsg)
	r = LoRefused([ oP, [ 1, 2 ] ])
	Then("a nested list among objects is refused", r, cMsg)
	r = LoRefused([ oP, [] ])
	Then("an empty list among objects is refused", r, cMsg)
	r = LoRefused([ 5, oP ])
	Then("the wrong item first is refused too", r, cMsg)
	r = LoRefused([ oP, oP, "" ])
	Then("an empty text last is refused", r, cMsg)
	r = LoRefused([ 1, 2, 3 ])
	Then("a list of numbers is refused", r, cMsg)
	r = LoRefused([ "a", "b" ])
	Then("a list of texts is refused", r, cMsg)
	r = LoRefused([ [] ])
	Then("a list holding only an empty list is refused", r, cMsg)
	r = LoRefused(5)
	Then("a number, not a list, is refused", r, cMsg)
	r = LoRefused("abc")
	Then("a text, not a list, is refused", r, cMsg)
	r = LoRefused(oP)
	Then("a single object, not a list, is refused", r, cMsg)
EndScenario()

Scenario("init: the holder keeps its own copy of what the caller gave")
	Given("a caller list of two Pets, held")
	aCaller = [ new Pet("rex"), new Pet("tom") ]
	oH = new stzListOfObjects(aCaller)
	When("the caller renames his first Pet and appends a third")
	aCaller[1].Rename("CHANGED")
	aCaller + new Pet("late")
	r = aCaller[1].Name()
	Then("the caller own Pet did change", r, "CHANGED")
	r = len(aCaller)
	Then("the caller own list did grow", r, 3)
	aH = oH.Content()
	r = aH[1].Name()
	Then("the holder still has the old name", r, "rex")
	r = len(aH)
	Then("the holder still has two objects", r, 2)
EndScenario()

Scenario("Content: it hands back the list (the register empty-text row)")
	Given("a holder of a stzString and two Pets")
	oH = new stzListOfObjects([ new stzString("ab"), new Pet("rex"), new Pet("tom") ])
	aC = oH.Content()
	r = isList(aC)
	Then("the answer is a list", r, 1)
	r = isString(aC)
	Then("and not the empty text", r, 0)
	r = len(aC)
	Then("with the three objects in order", r, 3)
	r = classname(aC[2]) + "/" + aC[2].Name()
	Then("the second is the Pet rex", r, "pet/rex")
	r = IsListOfObjects(aC)
	Then("every item of the answer is an object", r, 1)
	Given("a holder built without init, as StzListOfObjectsQ() does")
	oQ = StzListOfObjectsQ()
	r = isList(oQ.Content())
	Then("its content is a list too", r, 1)
	r = len(oQ.Content())
	Then("and an empty one", r, 0)
	r = classname(oQ)
	Then("and it is a stzlistofobjects", r, "stzlistofobjects")
EndScenario()

Scenario("Content: the list in a variable holds copies, one chained form reaches the holder")
	Given("a holder of two Pets")
	oH = new stzListOfObjects([ new Pet("rex"), new Pet("tom") ])
	When("a Pet is renamed in a list taken into a variable")
	aTaken = oH.Content()
	aTaken[1].Rename("VARIABLE")
	r = aTaken[1].Name()
	Then("the taken Pet did change", r, "VARIABLE")
	aAgain = oH.Content()
	r = aAgain[1].Name()
	Then("the holder Pet did not", r, "rex")
	When("the taken list grows")
	aTaken + new Pet("extra")
	r = len(oH.Content())
	Then("the holder does not grow", r, 2)
	r = len(aTaken)
	Then("the taken list did grow", r, 3)
	When("an object is taken out of the answer into a variable and renamed")
	aGot = oH.Content()
	oGot = aGot[2]
	oGot.Rename("OBJECT")
	aAgain = oH.Content()
	r = aAgain[2].Name()
	Then("the holder Pet is still tom", r, "tom")
	When("the rename is chained on the answer, o.Content()[1].Rename(...)")
	oH.Content()[1].Rename("CHAINED")
	aAgain = oH.Content()
	r = aAgain[1].Name()
	Then("it reaches the holder own object (the one form that does)", r, "CHAINED")
	r = aAgain[2].Name()
	Then("the other object is untouched", r, "tom")
EndScenario()

Scenario("Copy: an independent holder (the register raise row)")
	Given("a holder of a stzString and two Pets")
	oH = new stzListOfObjects([ new stzString("ab"), new Pet("rex"), new Pet("tom") ])
	r = LoCopyRefused(oH)
	Then("Copy raises nothing", r, "")
	oC = oH.Copy()
	r = classname(oC)
	Then("the copy is a stzlistofobjects", r, "stzlistofobjects")
	aC = oC.Content()
	r = len(aC)
	Then("it has the three objects", r, 3)
	r = classname(aC[1]) + "/" + classname(aC[2]) + "/" + aC[3].Name()
	Then("with their classes and names", r, "stzstring/pet/tom")
	When("the copy gets another object and a Pet of it is renamed")
	oC.AddItem(new Pet("late"))
	aC = oC.Content()
	aC[2].Rename("COPY")
	r = len(oC.Content())
	Then("the copy grew to four", r, 4)
	r = len(oH.Content())
	Then("the original is still three", r, 3)
	When("a Pet of the copy is renamed with the chained form")
	oC.Content()[2].Rename("CHAINCOPY")
	aC = oC.Content()
	r = aC[2].Name()
	Then("the copy own Pet changed", r, "CHAINCOPY")
	aH = oH.Content()
	r = aH[2].Name()
	Then("the original Pet is still rex", r, "rex")
	When("the original is renamed with the chained form")
	oH.Content()[3].Rename("ORIG")
	aH = oH.Content()
	r = aH[3].Name()
	Then("the original Pet changed", r, "ORIG")
	aC = oC.Content()
	r = aC[3].Name()
	Then("the copy Pet is still tom", r, "tom")
EndScenario()

Scenario("Copy: the empty holder, the copy of a copy, the alias class")
	oE = new stzListOfObjects([])
	r = LoCopyRefused(oE)
	Then("the empty holder copies without error", r, "")
	oEc = oE.Copy()
	r = len(oEc.Content())
	Then("and the copy is empty", r, 0)
	oH = new stzListOfObjects([ new Pet("rex"), new Pet("tom") ])
	oCc = oH.Copy().Copy()
	aCc = oCc.Content()
	r = len(aCc)
	Then("a copy of a copy has the same two objects", r, 2)
	r = aCc[2].Name()
	Then("and their names", r, "tom")
	oB = StzListOfObjectsQ()
	r = LoCopyRefused(oB)
	Then("a holder built without init copies too", r, "")
	oA = new stzObjects([ new Pet("rex"), new stzString("x") ])
	r = classname(oA)
	Then("the alias class builds from a list", r, "stzobjects")
	r = len(oA.Content())
	Then("and holds its two objects", r, 2)
	r = classname(oA.Copy())
	Then("its copy is a stzlistofobjects", r, "stzlistofobjects")
	r = LoRefusedAlias([ new Pet("rex"), 5 ])
	Then("the alias class refuses a list with a number", r, "Incorrect param type! paoObjects must be a list of objects.")
EndScenario()

Scenario("the inherited list methods that read the content now see the objects")
	Given("a holder of three objects of two classes")
	oH = new stzListOfObjects([ new Pet("rex"), new stzString("ab"), new Pet("tom") ])
	r = oH.NumberOfItems()
	Then("it counts three items", r, 3)
	r = oH.IsEmpty()
	Then("it is not empty", r, 0)
	oE = new stzListOfObjects([])
	r = oE.IsEmpty()
	Then("the empty holder is empty", r, 1)
	r = oE.NumberOfItems()
	Then("and counts none", r, 0)
	oH.AddItem(new Pet("late"))
	r = len(oH.Content())
	Then("an object added with AddItem is held", r, 4)
	r = LoCopyRefused(oH)
	Then("and the holder still copies afterwards", r, "")
EndScenario()

Summary()

# --- helpers: at the end, because code after a func belongs to the func ---

func LoRefused(pvArg)
	$lo_cMsg = ""
	try
		$lo_o = new stzListOfObjects(pvArg)
	catch
		$lo_cMsg = cCatchError
	done
	return trim($lo_cMsg)

func LoRefusedAlias(pvArg)
	$lo_cMsg = ""
	try
		$lo_o = new stzObjects(pvArg)
	catch
		$lo_cMsg = cCatchError
	done
	return trim($lo_cMsg)

func LoCopyRefused(poHolder)
	$lo_cMsg = ""
	try
		$lo_o = poHolder.Copy()
	catch
		$lo_cMsg = cCatchError
	done
	return trim($lo_cMsg)

class Pet
	cName = ""
	def init(pcName)
		cName = pcName
	def Name()
		return cName
	def Rename(pcName)
		cName = pcName
