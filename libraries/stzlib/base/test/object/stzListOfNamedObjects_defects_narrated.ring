load "../../stzBase.ring"
load "../_narrated.ring"

# stzListOfNamedObjects -- the register's two rows (init, Copy), kept as a guard. Run from inside test/object:
#     rnxc stzListOfNamedObjects_defects_narrated.ring
# It needs no DLL beyond the engine's string, list and number modules, no network and no file.
#
# THE HISTORY: init checked its list with IsListOfNamedObjects called on a stzList, a method that does not exist, so
# every list raised R14 (an empty one, a one object one) and Copy, which builds through init, raised with it. Behind
# that, the class had never run, and three more things were wrong that no row said:
#   init then built each item with new stzNamedObject, a class that does not exist
#   a holder built without parentheses had for Content the text NULL, not an empty list, so NumberOfItems said 4
#   NamedObject looked a name up with Content()[name], a Ring index by text on a list of objects (it raised "Bad
#     parameter type!"), and its number branch read a variable n that is not there (R24)
#
# THE RULES the guard holds the class to:
#   a NAMED OBJECT is an object of a library class (a stzString, a stzNumber, a stzList...) that carries a variable name
#     given with SetName: what the global StzIsNamedObject answers for. An object with no name (its name is @noname), an
#     object of a class of your own, a number, a text and a list are not.
#   init(list): the list must be a list and every item a named object; the empty list is a valid holder. Anything else
#     raises "Incorrect param type! paNamedObjects must be a list of named objects."
#   the names must be DISTINCT and case does not count (as the variable names of Ring): two objects named oa, or oa and
#     OA, are refused with "Incorrect param value! The objects must have distinct names, case does not count."
#   the holder keeps its own copies: changing the caller's list or objects afterwards does not reach it
#   Content (and Value) answer the list of objects; a holder built without parentheses answers the empty list
#   Copy answers a new stzListOfNamedObjects with its own copies; it is built through init
#   NamedObject(name) answers the object of that name, found in ANY case; NamedObject(n) the nth, n a whole number from
#     1 to the count; an unknown name, an empty name, a position out of range or not whole raise "Named Object
#     Inexistant!"; a value that is neither a text nor a number raises "Incorrect param type! p must be a string or number."
#   what NamedObject answers is a copy: renaming it leaves the held object as it was
#   AddItem and the other inherited list methods are NOT checked (the guard pins that, so a change is a change of the guard)
#   stzNamedObjects is another name of the class; its Copy is a stzListOfNamedObjects
#   StzListOfNamedObject(list) builds the holder; StzIsListOfNamedObjects is untouched
#
# Texts are compared EXACTLY (NbSame, through str2hex): Ring's = on text ignores case, and case is part of the rules.
# Every positive carries a negative sibling. The console shows ASCII only.

$cNbType = "Incorrect param type! paNamedObjects must be a list of named objects."
$cNbDup = "Incorrect param value! The objects must have distinct names, case does not count."
$cNbInex = "Named Object Inexistant!"
$cNbBadP = "Incorrect param type! p must be a string or number."

$oNbA = ""
$oNbB = ""
$oNbC = ""
$oNbH = ""
$oNbH2 = ""
$oNbX = ""
$oNbPet = ""
$oNbU = ""
$aNbL = []
$aNbC = []
$xNbR = ""
$nNbI = 0
$nNbOk = 0

# ---------------------------------------------------------------------------------------------------------------
Scenario("1. the examples of the doc blocks")
try
	Given("an empty holder, and a holder of one named string")
	$oNbH = new stzListOfNamedObjects
	Then("a holder built without parentheses holds nothing: 0", len($oNbH.Content()), 0)
	$oNbA = new stzString("ab")
	$oNbA.SetName("oFirst")
	NbResetRegistry()
	$oNbH = new stzListOfNamedObjects([ $oNbA ])
	Then("NamedObject(OFIRST) finds oFirst in another case: ab", NbSame($oNbH.NamedObject("OFIRST").Content(), "ab"), 1)
	Then("NamedObject(1) finds it by position: ab", NbSame($oNbH.NamedObject(1).Content(), "ab"), 1)
	Then("Copy holds one object: 1", len($oNbH.Copy().Content()), 1)
	$oNbH2 = new stzNamedObjects([ $oNbA ])
	Then("the alias class holds one: 1", len($oNbH2.Content()), 1)
	Then("NEGATIVE: the lookup by another name does not answer", NbRaised('$oNbH.NamedObject("oSecond")'), $cNbInex)
	Then("the class raises nothing for a valid list", NbRefused([ $oNbA ]), "")
catch
	NbAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("2. init: a list of named objects of three classes is accepted (the register R14 row)")
try
	Given("a named string, a named number and a named list")
	$oNbA = NbMakeS("hello", "oHello")
	$oNbB = new stzNumber(5)
	$oNbB.SetName("oFive")
	NbResetRegistry()
	$oNbC = new stzList([ 1, 2 ])
	$oNbC.SetName("oPair")
	NbResetRegistry()
	$aNbL = [ $oNbA, $oNbB, $oNbC ]
	Then("the list is built, no error is raised", NbRefused($aNbL), "")
	$oNbH = new stzListOfNamedObjects($aNbL)
	Then("the holder is a stzlistofnamedobjects", classname($oNbH), "stzlistofnamedobjects")
	Then("the holder has the three objects", len($oNbH.Content()), 3)
	$aNbC = $oNbH.Content()
	Then("the first keeps its class stzstring", classname($aNbC[1]), "stzstring")
	Then("the second keeps its class stznumber", classname($aNbC[2]), "stznumber")
	Then("the third keeps its class stzlist", classname($aNbC[3]), "stzlist")
	Then("the first keeps its text", NbSame($aNbC[1].Content(), "hello"), 1)
	Then("the first keeps its name, in its case: oHello", NbSame($aNbC[1].Name(), "oHello"), 1)
	Then("the second keeps its name: oFive", NbSame($aNbC[2].Name(), "oFive"), 1)
	Then("the third keeps its two items", len($aNbC[3].Content()), 2)
	Then("a list of one is accepted", NbRefused([ $oNbA ]), "")
	Then("a list of two is accepted", NbRefused([ $oNbA, $oNbB ]), "")
	Then("every item of the answer is a named object", IsListOfNamedObjects($aNbC), 1)
	Then("a holder of a stzString and a stzString, two names", NbRefused([ NbMakeS("a", "o1"), NbMakeS("b", "o2") ]), "")
	Then("NEGATIVE: the holder is not the empty one", len($oNbH.Content()) > 0, 1)
catch
	NbAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("3. init: the empty list is a list of no object and is accepted")
try
	Given("the empty list")
	Then("it is accepted", NbRefused([]), "")
	$oNbH = new stzListOfNamedObjects([])
	Then("the holder is empty", len($oNbH.Content()), 0)
	Then("and its content is a list", isList($oNbH.Content()), 1)
	Then("IsEmpty says so", $oNbH.IsEmpty(), 1)
	Then("NumberOfItems says 0", $oNbH.NumberOfItems(), 0)
	Then("it copies", NbCopyRefused($oNbH), "")
	Then("NEGATIVE: NamedObject(1) finds nothing in it", NbRaised('$oNbH.NamedObject(1)'), $cNbInex)
catch
	NbAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("4. init: one item that is not a named object refuses the whole list")
try
	Given("a named string, and one wrong item in turn")
	$oNbA = NbMakeS("ok", "oOk")
	$oNbU = new stzString("nameless")
	$oNbPet = new NbPet("rex")
	Then("an object with no name is not named: @noname", NbSame($oNbU.Name(), "@noname"), 1)
	Then("a list of it alone is refused", NbSame(NbRefused([ $oNbU ]), $cNbType), 1)
	Then("a named one and an unnamed one are refused", NbSame(NbRefused([ $oNbA, $oNbU ]), $cNbType), 1)
	Then("the unnamed one first is refused too", NbSame(NbRefused([ $oNbU, $oNbA ]), $cNbType), 1)
	Then("an object of a class of your own, with a Name method, is refused", NbSame(NbRefused([ $oNbPet ]), $cNbType), 1)
	Then("...among named ones", NbSame(NbRefused([ $oNbA, $oNbPet ]), $cNbType), 1)
	Then("a number among named objects is refused", NbSame(NbRefused([ $oNbA, 5 ]), $cNbType), 1)
	Then("a text among them is refused", NbSame(NbRefused([ $oNbA, "oOk" ]), $cNbType), 1)
	Then("a nested list among them is refused", NbSame(NbRefused([ $oNbA, [ 1, 2 ] ]), $cNbType), 1)
	Then("an empty list among them is refused", NbSame(NbRefused([ $oNbA, [] ]), $cNbType), 1)
	Then("the wrong item first is refused", NbSame(NbRefused([ 5, $oNbA ]), $cNbType), 1)
	Then("a pair of a name and an object is refused (the object must carry the name)", NbSame(NbRefused([ [ "oOk", $oNbA ] ]), $cNbType), 1)
	Then("a list of numbers is refused", NbSame(NbRefused([ 1, 2, 3 ]), $cNbType), 1)
	Then("a list of texts is refused", NbSame(NbRefused([ "a", "b" ]), $cNbType), 1)
	Then("a list holding only an empty list is refused", NbSame(NbRefused([ [] ]), $cNbType), 1)
	Then("a number, not a list, is refused", NbSame(NbRefused(5), $cNbType), 1)
	Then("a text, not a list, is refused", NbSame(NbRefused("oOk"), $cNbType), 1)
	Then("a single named object, not a list, is refused", NbSame(NbRefused($oNbA), $cNbType), 1)

	When("an object is named")
	$oNbX = new stzString("x")
	Then("before, it is refused", NbSame(NbRefused([ $oNbX ]), $cNbType), 1)
	$oNbX.SetName("oTemp")
	NbResetRegistry()
	Then("named, it is accepted", NbRefused([ $oNbX ]), "")
	Then("NEGATIVE: the error is not the R14 of the old check", NbSameQ(NbRefused([ $oNbU ]), "Error (R14) : Calling Method without definition: islistofnamedobjects"), 0)
	Then("NEGATIVE: the unnamed object was not turned away by the distinct-names rule", NbSameQ(NbRefused([ $oNbU ]), $cNbDup), 0)
catch
	NbAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("5. init: the names must be distinct (the case of the letters is tried in the last scenario)")
try
	Given("objects whose names collide in turn")
	Then("two objects named alike are refused", NbSame(NbRefused([ NbMakeS("a", "oDup"), NbMakeS("b", "oDup") ]), $cNbDup), 1)
	Then("a duplicate among three is refused, at the end", NbSame(NbRefused([ NbMakeS("a", "o1"), NbMakeS("b", "o2"), NbMakeS("c", "o1") ]), $cNbDup), 1)
	Then("...in the middle", NbSame(NbRefused([ NbMakeS("a", "o1"), NbMakeS("b", "o2"), NbMakeS("c", "o2") ]), $cNbDup), 1)
	Then("the same object twice is refused", NbSame(NbRefused([ $oNbA, $oNbA ]), $cNbDup), 1)
	Then("two classes with one name are refused", NbSame(NbRefused([ NbMakeS("a", "oSame"), NbMakeN(5, "oSame") ]), $cNbDup), 1)
	Then("NEGATIVE: names that differ by a letter are fine: oDup1 and oDup2", NbRefused([ NbMakeS("a", "oDup1"), NbMakeS("b", "oDup2") ]), "")
	Then("NEGATIVE: a name that holds another as its start is fine: o and oo", NbRefused([ NbMakeS("a", "o"), NbMakeS("b", "oo") ]), "")
	Then("NEGATIVE: a name and the same with a space after are fine: oX and oX-space", NbRefused([ NbMakeS("a", "oX"), NbMakeS("b", "oX ") ]), "")
	Then("NEGATIVE: a Greek capital and a Latin letter differ: sigma and s", NbRefused([ NbMakeS("a", "Σ"), NbMakeS("b", "s") ]), "")
	Then("NEGATIVE: the duplicate message is not the type message", NbSameQ(NbRefused([ NbMakeS("a", "oDup"), NbMakeS("b", "oDup") ]), $cNbType), 0)
	Then("the caller's objects are not renamed by the refusal", NbSame($oNbA.Name(), "oOk"), 1)
catch
	NbAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("6. init: the holder keeps its own copy of what the caller gave")
try
	Given("a caller list of two named strings, held")
	$aNbL = [ NbMakeS("ab", "oFirst"), NbMakeS("cd", "oSecond") ]
	$oNbH = new stzListOfNamedObjects($aNbL)
	When("the caller renames his first object and appends a third")
	$aNbL[1].SetName("oChanged")
	NbResetRegistry()
	$aNbL + NbMakeS("ef", "oThird")
	Then("the caller own object did change: oChanged", NbSame($aNbL[1].Name(), "oChanged"), 1)
	Then("the caller own list did grow", len($aNbL), 3)
	$aNbC = $oNbH.Content()
	Then("the holder still has the old name: oFirst", NbSame($aNbC[1].Name(), "oFirst"), 1)
	Then("the holder still has two objects", len($aNbC), 2)
	Then("the holder still finds oFirst", NbSame($oNbH.NamedObject("oFirst").Content(), "ab"), 1)
	Then("NEGATIVE: the holder does not find the caller's new name", NbRaised('$oNbH.NamedObject("oChanged")'), $cNbInex)
	Then("NEGATIVE: the holder does not find the object appended later", NbRaised('$oNbH.NamedObject("oThird")'), $cNbInex)
catch
	NbAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("7. Content and Value: the list of objects, empty for a holder built without parentheses")
try
	Given("a holder of three objects")
	$oNbH = new stzListOfNamedObjects([ NbMakeS("ab", "oS"), NbMakeN(7, "oN"), NbMakeS("cd", "oT") ])
	$aNbC = $oNbH.Content()
	Then("the answer is a list", isList($aNbC), 1)
	Then("and not a text", isString($aNbC), 0)
	Then("with the three objects in order", classname($aNbC[1]) + "/" + classname($aNbC[2]) + "/" + classname($aNbC[3]), "stzstring/stznumber/stzstring")
	Then("Value is the same list: three objects", len($oNbH.Value()), 3)
	Then("...and in the same order: the second is oN", NbSame($oNbH.Value()[2].Name(), "oN"), 1)
	Then("inherited NumberOfItems counts three", $oNbH.NumberOfItems(), 3)
	Then("inherited IsEmpty is false", $oNbH.IsEmpty(), 0)

	Given("a holder built without parentheses")
	$oNbH2 = new stzListOfNamedObjects
	Then("its content is a list", isList($oNbH2.Content()), 1)
	Then("...and not the text NULL", isString($oNbH2.Content()), 0)
	Then("...an empty one", len($oNbH2.Content()), 0)
	Then("Value too", len($oNbH2.Value()), 0)
	Then("NumberOfItems says 0, not the 4 of the text NULL", $oNbH2.NumberOfItems(), 0)
	Then("IsEmpty says so", $oNbH2.IsEmpty(), 1)
	Then("it is a stzlistofnamedobjects", classname($oNbH2), "stzlistofnamedobjects")
	$oNbX = new stzNamedObjects
	Then("the alias without parentheses is empty too", len($oNbX.Content()), 0)

	When("a list taken into a variable is changed")
	$aNbC = $oNbH.Content()
	$aNbC[1].SetName("oVariable")
	NbResetRegistry()
	$aNbC + NbMakeS("zz", "oExtra")
	Then("the taken object did change: oVariable", NbSame($aNbC[1].Name(), "oVariable"), 1)
	Then("the holder still has oS first", NbSame($oNbH.Content()[1].Name(), "oS"), 1)
	Then("...and three objects", len($oNbH.Content()), 3)
catch
	NbAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("8. NamedObject by name: found in any case, copies, unknown names raise")
try
	Given("a holder of a string, a number and a list, named oAlpha, oBeta and Gamma")
	$oNbH = new stzListOfNamedObjects([ NbMakeS("alpha text", "oAlpha"), NbMakeN(42, "oBeta"), NbMakeL([ 7, 8, 9 ], "Gamma") ])
	Then("oAlpha, as written, answers the string", NbSame($oNbH.NamedObject("oAlpha").Content(), "alpha text"), 1)
	Then("...in lower case", NbSame($oNbH.NamedObject("oalpha").Content(), "alpha text"), 1)
	Then("...in upper case", NbSame($oNbH.NamedObject("OALPHA").Content(), "alpha text"), 1)
	Then("...in mixed case", NbSame($oNbH.NamedObject("OaLpHa").Content(), "alpha text"), 1)
	Then("oBeta answers the number: 42", $oNbH.NamedObject("oBeta").NumericValue(), 42)
	Then("...its class is stznumber", classname($oNbH.NamedObject("OBETA")), "stznumber")
	Then("Gamma answers the list: three items", len($oNbH.NamedObject("gamma").Content()), 3)
	Then("...its class is stzlist", classname($oNbH.NamedObject("GAMMA")), "stzlist")
	Then("...the answer keeps the name in its own case: Gamma", NbSame($oNbH.NamedObject("gamma").Name(), "Gamma"), 1)
	Then("an unknown name raises", NbSame(NbRaised('$oNbH.NamedObject("oDelta")'), $cNbInex), 1)
	Then("a name that starts like a held one raises: oAlph", NbSame(NbRaised('$oNbH.NamedObject("oAlph")'), $cNbInex), 1)
	Then("...and one that ends later: oAlphaX", NbSame(NbRaised('$oNbH.NamedObject("oAlphaX")'), $cNbInex), 1)
	Then("the empty name raises", NbSame(NbRaised('$oNbH.NamedObject("")'), $cNbInex), 1)
	Then("a name with a space raises", NbSame(NbRaised('$oNbH.NamedObject("oAlpha ")'), $cNbInex), 1)
	Then("a number written as a text raises", NbSame(NbRaised('$oNbH.NamedObject("1")'), $cNbInex), 1)
	Then("a name registered elsewhere but not in this holder raises: oFive, a global name of scenario 2", NbSame(NbRaised('$oNbH.NamedObject("oFive")'), $cNbInex), 1)
	$oNbH2 = new stzListOfNamedObjects([])
	Then("the empty holder raises for any name", NbSame(NbRaised('$oNbH2.NamedObject("oAlpha")'), $cNbInex), 1)
	$oNbH2 = new stzListOfNamedObjects
	Then("the holder built without parentheses raises too", NbSame(NbRaised('$oNbH2.NamedObject("oAlpha")'), $cNbInex), 1)
	Then("NEGATIVE: the right name raises nothing", NbRaised('$oNbH.NamedObject("oalpha")'), "")

	When("the answer is renamed in a variable")
	$oNbX = $oNbH.NamedObject("oAlpha")
	$oNbX.SetName("oRenamed")
	NbResetRegistry()
	Then("the taken object did change: oRenamed", NbSame($oNbX.Name(), "oRenamed"), 1)
	Then("the holder still finds oAlpha", NbSame($oNbH.NamedObject("oAlpha").Name(), "oAlpha"), 1)
	Then("NEGATIVE: the holder does not find oRenamed", NbSame(NbRaised('$oNbH.NamedObject("oRenamed")'), $cNbInex), 1)
catch
	NbAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("9. NamedObject by position, and the arguments it refuses")
try
	Given("the same holder of three")
	$oNbH = new stzListOfNamedObjects([ NbMakeS("alpha text", "oAlpha"), NbMakeN(42, "oBeta"), NbMakeL([ 7, 8, 9 ], "Gamma") ])
	Then("1 answers oAlpha", NbSame($oNbH.NamedObject(1).Name(), "oAlpha"), 1)
	Then("2 answers oBeta", NbSame($oNbH.NamedObject(2).Name(), "oBeta"), 1)
	Then("3 answers Gamma", NbSame($oNbH.NamedObject(3).Name(), "Gamma"), 1)
	Then("2 is the number 42", $oNbH.NamedObject(2).NumericValue(), 42)
	Then("2.0 is the position 2", NbSame($oNbH.NamedObject(2.0).Name(), "oBeta"), 1)
	Then("0 raises", NbSame(NbRaised('$oNbH.NamedObject(0)'), $cNbInex), 1)
	Then("4, past the last, raises", NbSame(NbRaised('$oNbH.NamedObject(4)'), $cNbInex), 1)
	Then("-1 raises", NbSame(NbRaised('$oNbH.NamedObject(-1)'), $cNbInex), 1)
	Then("1.5 raises, though a Ring index would read it as 1", NbSame(NbRaised('$oNbH.NamedObject(1.5)'), $cNbInex), 1)
	Then("100 raises", NbSame(NbRaised('$oNbH.NamedObject(100)'), $cNbInex), 1)
	Then("a list raises the type message", NbSame(NbRaised('$oNbH.NamedObject([ 1 ])'), $cNbBadP), 1)
	Then("the empty list raises the type message", NbSame(NbRaised('$oNbH.NamedObject([])'), $cNbBadP), 1)
	Then("an object raises the type message", NbSame(NbRaised('$oNbH.NamedObject($oNbH)'), $cNbBadP), 1)
	Then("NEGATIVE: the old R24 on the variable n is gone", NbSameQ(NbRaised('$oNbH.NamedObject(1)'), "Error (R24) : Using uninitialized variable: n"), 0)
	Then("NEGATIVE: position 3 is not position 2", NbSameQ($oNbH.NamedObject(3).Name(), "oBeta"), 0)
	Then("by name and by position agree for the three", NbSame($oNbH.NamedObject("oBeta").Name(), $oNbH.NamedObject(2).Name()), 1)
catch
	NbAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("10. Copy: an independent holder (the register raise row)")
try
	Given("a holder of a string, a number and a list")
	$oNbH = new stzListOfNamedObjects([ NbMakeS("ab", "oS"), NbMakeN(7, "oN"), NbMakeL([ 1, 2 ], "oL") ])
	Then("Copy raises nothing", NbCopyRefused($oNbH), "")
	$oNbH2 = $oNbH.Copy()
	Then("the copy is a stzlistofnamedobjects", classname($oNbH2), "stzlistofnamedobjects")
	$aNbC = $oNbH2.Content()
	Then("it has the three objects", len($aNbC), 3)
	Then("with their classes and names", classname($aNbC[1]) + "/" + classname($aNbC[2]) + "/" + $aNbC[3].Name(), "stzstring/stznumber/oL")
	Then("a lookup by name works on the copy", NbSame($oNbH2.NamedObject("OS").Content(), "ab"), 1)
	Then("NamedObject(2) works on the copy: 7", $oNbH2.NamedObject(2).NumericValue(), 7)

	When("a call is chained on a fresh copy, with no variable to hold it")
	$oNbH.Copy().AddItem(NbMakeS("tmp", "oTmp"))
	NbResetRegistry()
	Then("the original is still three", len($oNbH.Content()), 3)
	$oNbH.Copy().Content()[1].SetName("oViaChain")
	NbResetRegistry()
	Then("the original object is still named oS", NbSame($oNbH.Content()[1].Name(), "oS"), 1)
	Then("NEGATIVE: the original does not know oViaChain", NbSame(NbRaised('$oNbH.NamedObject("oViaChain")'), $cNbInex), 1)

	When("the copy gets another object")
	$oNbH2.AddItem(NbMakeS("zz", "oLate"))
	Then("the copy grew to four", len($oNbH2.Content()), 4)
	Then("the original is still three", len($oNbH.Content()), 3)
	Then("the copy finds oLate", NbSame($oNbH2.NamedObject("oLate").Content(), "zz"), 1)
	Then("NEGATIVE: the original does not", NbSame(NbRaised('$oNbH.NamedObject("oLate")'), $cNbInex), 1)

	When("an object of the copy is renamed with the chained form")
	$oNbH2.Content()[1].SetName("oCopied")
	NbResetRegistry()
	Then("the copy finds oCopied", NbSame($oNbH2.NamedObject("oCopied").Content(), "ab"), 1)
	Then("the original still finds oS", NbSame($oNbH.NamedObject("oS").Content(), "ab"), 1)
	Then("NEGATIVE: the original does not know oCopied", NbSame(NbRaised('$oNbH.NamedObject("oCopied")'), $cNbInex), 1)

	When("the original is renamed with the chained form")
	$oNbH.Content()[3].SetName("oOrig")
	NbResetRegistry()
	Then("the original finds oOrig", NbSame($oNbH.NamedObject("oOrig").Name(), "oOrig"), 1)
	Then("the copy still has oL", NbSame($oNbH2.NamedObject("oL").Name(), "oL"), 1)
	Then("NEGATIVE: the copy does not know oOrig", NbSame(NbRaised('$oNbH2.NamedObject("oOrig")'), $cNbInex), 1)

	When("a copy is made of a copy")
	$oNbH2 = $oNbH.Copy().Copy()
	Then("it has the same three objects", len($oNbH2.Content()), 3)
	Then("and their names: the third is oOrig", NbSame($oNbH2.NamedObject(3).Name(), "oOrig"), 1)
catch
	NbAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("11. Copy: the empty holder, the holder built without parentheses, the alias class")
try
	$oNbH = new stzListOfNamedObjects([])
	Then("the empty holder copies without error", NbCopyRefused($oNbH), "")
	Then("and the copy is empty", len($oNbH.Copy().Content()), 0)
	$oNbH2 = new stzListOfNamedObjects
	Then("a holder built without parentheses copies too", NbCopyRefused($oNbH2), "")
	Then("and its copy is empty", len($oNbH2.Copy().Content()), 0)
	Then("and its copy is a stzlistofnamedobjects", classname($oNbH2.Copy()), "stzlistofnamedobjects")
	$oNbH = new stzNamedObjects([ NbMakeS("ab", "oA"), NbMakeS("cd", "oB") ])
	Then("the alias class builds from a list", classname($oNbH), "stznamedobjects")
	Then("and holds its two objects", len($oNbH.Content()), 2)
	Then("its Copy is a stzlistofnamedobjects", classname($oNbH.Copy()), "stzlistofnamedobjects")
	Then("...of two objects", len($oNbH.Copy().Content()), 2)
	Then("the alias finds by name: cd", NbSame($oNbH.NamedObject("ob").Content(), "cd"), 1)
	Then("the alias refuses a list with a number", NbSame(NbRefusedAlias([ NbMakeS("a", "oA"), 5 ]), $cNbType), 1)
	Then("...and two names alike", NbSame(NbRefusedAlias([ NbMakeS("a", "oA"), NbMakeS("b", "oA") ]), $cNbDup), 1)
	Then("the alias accepts the empty list", NbRefusedAlias([]), "")
catch
	NbAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("12. what is not checked: objects added with the inherited methods")
try
	Given("a holder of one object")
	$oNbH = new stzListOfNamedObjects([ NbMakeS("ab", "oA") ])
	When("an unnamed object is added with AddItem")
	$oNbH.AddItem(new stzString("nameless"))
	Then("AddItem takes it: two objects", len($oNbH.Content()), 2)
	Then("NumberOfItems counts two", $oNbH.NumberOfItems(), 2)
	Then("the lookup by name of the first still works", NbSame($oNbH.NamedObject("oA").Content(), "ab"), 1)
	Then("the lookup by position 2 answers the added object", NbSame($oNbH.NamedObject(2).Content(), "nameless"), 1)
	Then("Copy raises, since the content stopped being a list of named objects", NbSame(NbCopyRefused($oNbH), $cNbType), 1)

	When("a second object of an already used name is added (the case of the letters is tried in the last scenario)")
	$oNbH = new stzListOfNamedObjects([ NbMakeS("first", "oSame") ])
	$oNbH.AddItem(NbMakeS("second", "oSame"))
	Then("AddItem takes it: two objects", len($oNbH.Content()), 2)
	Then("the lookup answers the first one added", NbSame($oNbH.NamedObject("osame").Content(), "first"), 1)
	Then("position 2 answers the second", NbSame($oNbH.NamedObject(2).Content(), "second"), 1)
	Then("Copy raises, since the names are no longer distinct", NbSame(NbCopyRefused($oNbH), $cNbDup), 1)

	When("a named object is added to a valid holder")
	$oNbH = new stzListOfNamedObjects([ NbMakeS("ab", "oA") ])
	$oNbH.AddItem(NbMakeS("cd", "oB"))
	Then("two objects", len($oNbH.Content()), 2)
	Then("Copy works", NbCopyRefused($oNbH), "")
	Then("and finds the added one: cd", NbSame($oNbH.Copy().NamedObject("oB").Content(), "cd"), 1)
catch
	NbAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
Scenario("13. the global functions: StzIsListOfNamedObjects is untouched, StzListOfNamedObject builds the holder")
try
	Given("a named string, an unnamed one, a number")
	$oNbA = NbMakeS("ab", "oA")
	$oNbU = new stzString("nameless")
	Then("a list of named objects: 1", StzIsListOfNamedObjects([ $oNbA, NbMakeS("cd", "oB") ]), 1)
	Then("the alternative form IsListOfNamedObjects: 1", IsListOfNamedObjects([ $oNbA ]), 1)
	Then("@IsListOfNamedObjects: 1", @IsListOfNamedObjects([ $oNbA ]), 1)
	Then("IsAListOfNamedObjects: 1", IsAListOfNamedObjects([ $oNbA ]), 1)
	Then("the empty list: 1", StzIsListOfNamedObjects([]), 1)
	Then("a named and an unnamed: 0", StzIsListOfNamedObjects([ $oNbA, $oNbU ]), 0)
	Then("a number among them: 0", StzIsListOfNamedObjects([ $oNbA, 5 ]), 0)
	Then("a nested list: 0", StzIsListOfNamedObjects([ [ 1 ] ]), 0)
	Then("two names alike are still a list of named objects here (distinctness is the holder's rule): 1", StzIsListOfNamedObjects([ $oNbA, NbMakeS("x", "oA") ]), 1)
	Then("a non-list raises", NbSame(NbRaised('StzIsListOfNamedObjects(5)'), "Incorrect param type!"), 1)
	$oNbH = StzListOfNamedObject([ $oNbA, NbMakeS("cd", "oB") ])
	Then("StzListOfNamedObject answers a holder", classname($oNbH), "stzlistofnamedobjects")
	Then("...of two objects", len($oNbH.Content()), 2)
	Then("...which finds by name: cd", NbSame($oNbH.NamedObject("OB").Content(), "cd"), 1)
	Then("StzListOfNamedObject refuses a list with an unnamed object", NbSame(NbRaised('StzListOfNamedObject([ $oNbU ])'), $cNbType), 1)
	Then("...and the empty list builds an empty holder", len(StzListOfNamedObject([]).Content()), 0)
catch
	NbAbort()
done
EndScenario()

# ---------------------------------------------------------------------------------------------------------------
# The case of the letters is tried last, only to keep the earlier scenarios free of names alike but for the case.
Scenario("14. names that differ only by case count as one name")
try
	Given("a third object, then two named oCaseA and OCASEA")
	$oNbC = NbMakeS("c", "oThird")
	$oNbA = NbMakeS("a", "oCaseA")
	$oNbB = NbMakeS("b", "OCASEA")
	NbResetRegistry()
	Then("the pair is refused", NbSame(NbRefused([ $oNbA, $oNbB ]), $cNbDup), 1)
	Then("...in the other order", NbSame(NbRefused([ $oNbB, $oNbA ]), $cNbDup), 1)
	Then("...with a third object before", NbSame(NbRefused([ $oNbC, $oNbA, $oNbB ]), $cNbDup), 1)
	Then("...in the middle", NbSame(NbRefused([ $oNbA, $oNbC, $oNbB ]), $cNbDup), 1)
	Then("...at the end", NbSame(NbRefused([ $oNbA, $oNbB, $oNbC ]), $cNbDup), 1)
	Then("the alias class refuses it too", NbSame(NbRefusedAlias([ $oNbA, $oNbB ]), $cNbDup), 1)
	Then("StzListOfNamedObject refuses it too", NbSame(NbRaised('StzListOfNamedObject([ $oNbA, $oNbB ])'), $cNbDup), 1)
	Then("NEGATIVE: either object alone is accepted", NbRefused([ $oNbA ]) + NbRefused([ $oNbB ]), "")
	Then("NEGATIVE: with the third object, one of the pair is accepted", NbRefused([ $oNbC, $oNbB ]), "")
	Then("the caller's objects keep their names: oCaseA", NbSame($oNbA.Name(), "oCaseA"), 1)
	Then("...and OCASEA", NbSame($oNbB.Name(), "OCASEA"), 1)

	When("the second of the pair is added afterwards with AddItem")
	$oNbH = new stzListOfNamedObjects([ $oNbA ])
	$oNbH.AddItem($oNbB)
	Then("AddItem takes it: two objects", len($oNbH.Content()), 2)
	Then("the lookup in lower case answers the first added", NbSame($oNbH.NamedObject("ocasea").Content(), "a"), 1)
	Then("the lookup by position 2 answers the second", NbSame($oNbH.NamedObject(2).Content(), "b"), 1)
	Then("Copy raises, since the names are no longer distinct", NbSame(NbCopyRefused($oNbH), $cNbDup), 1)

	When("the case of an accented letter differs: Eab and eab")
	$oNbA = NbMakeS("a", "Éab")
	$oNbB = NbMakeS("b", "éab")
	NbResetRegistry()
	Then("the pair is refused: the case is Unicode case", NbSame(NbRefused([ $oNbA, $oNbB ]), $cNbDup), 1)
	Then("NEGATIVE: one of the accented pair and an unrelated name are two names", NbRefused([ $oNbA, $oNbC ]), "")
catch
	NbAbort()
done
EndScenario()

Summary()

# ---------------------------------------------------------------------------------------------------------------
# helpers: every name a function reads is a $global (Rule A)

# an EXACT, case-sensitive comparison of two texts through their hex: Ring's = on text ignores case
func NbSame(a, b)
	if NbSameQ(a, b) = 1  return 1  ok
	if isString(a) and isString(b)
		? "      (exact compare failed)  got [" + a + "]  wanted [" + b + "]"
	else
		? "      (exact compare failed)  got a value that is not a text"
	ok
	return 0

# the same, quietly: for the negative siblings, which are expected to differ
func NbSameQ(a, b)
	if isString(a) and isString(b)
		if str2hex(a) = str2hex(b)  return 1  ok
	ok
	return 0

# the message of the error a build raises, "" when it raises nothing
func NbRefused(pvArg)
	$cNbMsg = ""
	try
		$oNbT = new stzListOfNamedObjects(pvArg)
	catch
		$cNbMsg = cCatchError
	done
	return trim($cNbMsg)

func NbRefusedAlias(pvArg)
	$cNbMsg = ""
	try
		$oNbT = new stzNamedObjects(pvArg)
	catch
		$cNbMsg = cCatchError
	done
	return trim($cNbMsg)

func NbCopyRefused(poHolder)
	$cNbMsg = ""
	try
		$oNbT = poHolder.Copy()
	catch
		$cNbMsg = cCatchError
	done
	return trim($cNbMsg)

# the text of the error a statement raises, "" when it raises nothing
func NbRaised(cCode)
	$cNbMsg = ""
	try
		eval("$xNbR = " + cCode)
	catch
		$cNbMsg = cCatchError
	done
	return trim($cNbMsg)

# clears the registry of names (common/stzNamedVars.ring). Naming a second object with a name already taken adds a
# second key to it, and it then no longer reads as a well formed hashlist: EVERY later SetName raises "Can't create the
# stzHashList object!". That is not this class's rule and is not mended here; the guard clears the registry after each
# SetName, which it needs because the rules under test are about objects that share a name.
func NbResetRegistry()
	$vVars = [ [ "say", "" ] ]

func NbMakeS(cText, cName)
	oMade = new stzString(cText)
	oMade.SetName(cName)
	NbResetRegistry()
	return oMade

func NbMakeN(nValue, cName)
	oMade = new stzNumber(nValue)
	oMade.SetName(cName)
	NbResetRegistry()
	return oMade

func NbMakeL(aItems, cName)
	oMade = new stzList(aItems)
	oMade.SetName(cName)
	NbResetRegistry()
	return oMade

func NbAbort()
	? "  ABORTED by an uncaught error: " + cCatchError
	$_zst_fail++
	$_zst_total++

# a class of the test, not a library class: it has a Name method and no variable name
class NbPet
	cName = ""
	def init(pcName)
		cName = pcName
	def Name()
		return cName
