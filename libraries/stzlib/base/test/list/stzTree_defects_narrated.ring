load "../../stzBase.ring"
load "../_narrated.ring"

# Guard for the stzTree removal family (DEFECTS.md, stzTree, fixed on fix/tr): RemoveItem,
# RemoveTheseItems, RemoveItems and RemoveAllItems raised "Not yet implemented!", and
# RemoveThisItemCS had an empty body.
#
# THE SEMANTICS, taken from the sibling stzList (Remove / RemoveMany / RemoveAllItems / DeepRemoveMany):
# an item is a LEAF of the tree; every occurrence goes, at any depth; an absent item changes nothing
# and raises nothing; the nodes and the root are never removed (removing the text of a node name
# removes a LEAF with that text, never the node); RemoveAllItems empties the leaves and keeps the
# skeleton of nodes. Removing a NODE is another feature and is not written.
#
# Every claim is checked against an expectation computed by the guard itself, independent of the
# class: ExpItems() filters the item list by a comparison of the written forms. Accented and Hebrew
# texts are built from char codes and never printed.

aSample = [ "root", [ :node1 = [ "X", :node11 = [ "A", "B", "X" ] ], :node2 = [ 1, 2, 3 ], :node3 = [ "X", 5, [ 1, 2 ], [ ] ] ] ]

Scenario("The sample tree, before anything is removed")
	o = StzTreeQ(aSample)
	Then("eleven items in all", len(o.Items()), 11)
	Then("five nodes, the root first", len(o.Branches()), 5)
	Then("X lies in three places", len(o.FindItem("X")), 3)
EndScenario()

Scenario("RemoveItem takes a leaf out, at any depth, and nothing else")
	o = StzTreeQ(:root = [ :node1 = [ "X", :node11 = [ "A", "B", "X" ] ], :node2 = [ 1, 2, 3 ], :node3 = [ "X", 5 ] ])
	aBefore = o.Items()
	aBranches = o.Branches()
	o.RemoveItem("B")
	Then("B is gone from node11", @@(o.NodeAt("[:root][:node1][:node11]")), '[ "A", "X" ]')
	Then("the other items are exactly the expected ones", @@(o.Items()), @@(ExpItems(aBefore, [ "B" ])))
	Then("the nodes are the same", @@(o.Branches()), @@(aBranches))
	Then("FindItem no longer finds it", len(o.FindItem("B")), 0)
	Then("A, next to it, is still found", len(o.FindItem("A")), 1)
	Then("a sibling node is untouched", @@(o.NodeAt("[:root][:node2]")), '[ 1, 2, 3 ]')
EndScenario()

Scenario("A repeated item goes from every place, not only the first")
	o = StzTreeQ(:root = [ :node1 = [ "X", :node11 = [ "A", "B", "X" ] ], :node2 = [ 1, 2, 3 ], :node3 = [ "X", 5 ] ])
	aBefore = o.Items()
	o.RemoveItem("X")
	Then("the three places are empty of X", len(o.FindItem("X")), 0)
	Then("the items are the expected ones", @@(o.Items()), @@(ExpItems(aBefore, [ "X" ])))
	Then("node1 keeps its nested node", @@(o.NodeAt("[:root][:node1]")), '[ [ "node11", [ "A", "B" ] ] ]')
	Then("node3 keeps the 5", @@(o.NodeAt("[:root][:node3]")), '[ 5 ]')
EndScenario()

Scenario("An absent item changes nothing and raises nothing")
	o = StzTreeQ(:root = [ :node1 = [ "X", :node11 = [ "A" ] ], :node2 = [ 1, 2 ] ])
	cBefore = @@(o.Content())
	cMsg = Raises(o, 'o.RemoveItem("nothing here")')
	Then("no error", cMsg, "")
	Then("the tree is the same", @@(o.Content()), cBefore)
	cMsg = Raises(o, "o.RemoveItem(99)")
	Then("an absent number raises nothing either", cMsg, "")
	Then("and changes nothing", @@(o.Content()), cBefore)
	o.RemoveItem("X")
	bChanged = (@@(o.Content()) != cBefore)
	Then("while a present item does change the tree", bChanged, 1)
EndScenario()

Scenario("The case rule: exact by default, ignored on demand")
	cE = char(195) + char(169)
	cEU = char(195) + char(137)
	o = StzTreeQ(:root = [ :a = [ "x", "X", cE, cEU ], :b = [ "Y" ] ])
	o.RemoveItem("x")
	Then("RemoveItem is exact: x goes, X stays", len(o.Items()), 4)
	Then("X is still found", len(o.FindItem("X")), 1)
	o.RemoveItemCS("y", 1)
	Then("RemoveItemCS with 1 is exact too: y does not remove Y", len(o.FindItem("Y")), 1)
	o.RemoveItemCS("y", 0)
	Then("RemoveItemCS with 0 ignores the case: Y goes", len(o.FindItem("Y")), 0)
	o.RemoveItemCS(cEU, 1)
	nExact = len(o.Items())
	Then("an accented capital is exact with 1: only it goes", nExact, 2)
	o = StzTreeQ(:root = [ :a = [ cE, cEU, "q" ] ])
	o.RemoveItemCS(cEU, 0)
	Then("with 0 the accented pair goes by one call, the engine folds the case", len(o.Items()), 1)
	Then("only q is left", @@(o.Items()), '[ "q" ]')
	o = StzTreeQ(:root = [ :a = [ "x", "X", "k" ] ])
	o.RemoveTheseItemsCS([ "x", "K" ], 0)
	Then("RemoveTheseItemsCS with 0 ignores the case for every item", @@(o.Items()), '[ ]')
	o = StzTreeQ(:root = [ :a = [ "x", "X", "k" ] ])
	o.RemoveTheseItemsCS([ "x", "K" ], 1)
	Then("and with 1 it is exact", @@(o.Items()), '[ "X", "k" ]')
EndScenario()

Scenario("Hebrew texts are removed whole")
	cHe = char(215) + char(169) + char(215) + char(156) + char(215) + char(149) + char(215) + char(157)
	cHe2 = char(215) + char(169) + char(215) + char(156)
	o = StzTreeQ(:root = [ :a = [ cHe, cHe2, "A" ], :b = [ cHe ] ])
	o.RemoveItem(cHe)
	Then("the Hebrew text goes from both nodes", len(o.FindItem(cHe)), 0)
	Then("its prefix, a different text, stays", len(o.FindItem(cHe2)), 1)
	Then("two items are left", len(o.Items()), 2)
EndScenario()

Scenario("Numbers, texts of digits and nested lists stay distinct")
	o = StzTreeQ(:root = [ :a = [ 2, "2", 2.50, [ 1, 2 ], [ 1, 3 ], [ ] ] ])
	o.RemoveItem(2)
	Then("the number 2 goes, the text 2 and 2.5 stay", @@(o.Items()), '[ "2", 2.50, [ 1, 2 ], [ 1, 3 ], [ ] ]')
	o.RemoveItem("2")
	Then("the text 2 goes after it", @@(o.Items()), '[ 2.50, [ 1, 2 ], [ 1, 3 ], [ ] ]')
	o.RemoveItem([ 1, 2 ])
	Then("a list item goes whole, its neighbour [1,3] stays", @@(o.Items()), '[ 2.50, [ 1, 3 ], [ ] ]')
	o.RemoveItem([ ])
	Then("an empty list is an item and goes", @@(o.Items()), '[ 2.50, [ 1, 3 ] ]')
	o.RemoveItem(1)
	Then("the 1 inside a list item is not an item: nothing changes", @@(o.Items()), '[ 2.50, [ 1, 3 ] ]')
EndScenario()

Scenario("A text equal to a node name removes the leaf and never the node")
	o = StzTreeQ(:root = [ :node1 = [ "node2", "k" ], :node2 = [ 1 ] ])
	aNodes = o.Nodes()
	aBranches = o.Branches()
	o.RemoveItem("node2")
	Then("the leaf text is gone", @@(o.NodeAt("[:root][:node1]")), '[ "k" ]')
	Then("the node of that name is still there, with its item", @@(o.NodeAt("[:root][:node2]")), '[ 1 ]')
	Then("the names are the same", @@(o.Nodes()), @@(aNodes))
	Then("so are the paths", @@(o.Branches()), @@(aBranches))
	o.RemoveItem("root")
	Then("the root name as a text removes no root", o.Root()[1], "root")
	Then("and the root still holds both nodes", len(o.Branches()), 3)
EndScenario()

Scenario("RemoveTheseItems takes several items, whatever their order")
	aT = [ "root", [ :n1 = [ "A", "B", :n11 = [ "C", "A", 7 ] ], :n2 = [ 7, "D", [ 1 ] ] ] ]
	o1 = StzTreeQ(aT)
	aBefore = o1.Items()
	o1.RemoveTheseItems([ "A", 7, [ 1 ] ])
	Then("the items are the expected ones", @@(o1.Items()), @@(ExpItems(aBefore, [ "A", 7, [ 1 ] ])))
	o2 = StzTreeQ(aT)
	o2.RemoveTheseItems([ [ 1 ], 7, "A" ])
	Then("the reverse order gives the same tree", @@(o2.Content()), @@(o1.Content()))
	o3 = StzTreeQ(aT)
	o3.RemoveTheseItems([ "A", "A", 7, "nothing" ])
	o3b = StzTreeQ(aT)
	o3b.RemoveTheseItems([ "A", 7 ])
	Then("a repeated and an absent item in the list change nothing more", @@(o3.Content()), @@(o3b.Content()))
	o4 = StzTreeQ(aT)
	cBefore = @@(o4.Content())
	o4.RemoveTheseItems([ ])
	Then("an empty list changes nothing", @@(o4.Content()), cBefore)
	o5 = StzTreeQ(aT)
	o5.RemoveTheseItemsCS([ "a", "c" ], 0)
	Then("the CS form with 0 ignores the case", len(o5.FindItem("C")) + len(o5.FindItem("A")), 0)
	Then("and leaves the others", len(o5.Items()), 5)
	o6 = StzTreeQ(aT)
	o6.RemoveThisItemCS("B", 1)
	Then("RemoveThisItemCS does the work now", len(o6.FindItem("B")), 0)
EndScenario()

Scenario("Bad parameters are refused")
	o = StzTreeQ(:root = [ :n = [ "A" ] ])
	cMsg = Raises(o, 'o.RemoveTheseItems("A")')
	nHit = len(StzFind("paItems must be a list", cMsg))
	Then("a text is not a list of items", nHit > 0, 1)
	cMsg = Raises(o, 'o.RemoveTheseItemsCS("A", 1)')
	nHit = len(StzFind("paItems must be a list", cMsg))
	Then("the CS form refuses it too", nHit > 0, 1)
	cMsg = Raises(o, 'o.RemoveItemCS("A", 2)')
	nHit = len(StzFind("pCaseSensitive must be 1 or 0", cMsg))
	Then("a case flag other than 1 or 0 is refused", nHit > 0, 1)
	cMsg = Raises(o, 'o.RemoveItemCS("A", "yes")')
	nHit = len(StzFind("pCaseSensitive must be 1 or 0", cMsg))
	Then("a text flag is refused", nHit > 0, 1)
	Then("the tree was not touched by the refusals", @@(o.Items()), '[ "A" ]')
EndScenario()

Scenario("RemoveAllItems and RemoveItems empty the leaves and keep the skeleton")
	aT = [ "root", [ :n1 = [ "A", :n11 = [ "B", 1 ] ], :n2 = [ 2 ], :n3 = [ ] ] ]
	o = StzTreeQ(aT)
	aNodes = o.Nodes()
	aBranches = o.Branches()
	aZ = o.NodesZ()
	o.RemoveAllItems()
	Then("no item is left", len(o.Items()), 0)
	Then("the nodes are the same", @@(o.Nodes()), @@(aNodes))
	Then("the paths are the same", @@(o.Branches()), @@(aBranches))
	Then("the nodes with their paths are the same", @@(o.NodesZ()), @@(aZ))
	Then("an emptied nested node is an empty list", @@(o.NodeAt("[:root][:n1][:n11]")), '[ ]')
	Then("the root is still the root", o.Root()[1], "root")
	Then("FindItems finds nothing", len(o.FindItems()), 0)
	o2 = StzTreeQ(aT)
	o2.RemoveItems()
	Then("RemoveItems gives exactly the same tree", @@(o2.Content()), @@(o.Content()))
	cBefore = @@(o.Content())
	o.RemoveAllItems()
	Then("emptying an empty tree changes nothing", @@(o.Content()), cBefore)
	o7 = StzTreeQ(aT)
	Then("the other tree, built from the same list, was never touched", len(o7.Items()), 4)
EndScenario()

Scenario("A tree emptied of its items is usable again")
	o = StzTreeQ(:root = [ :n1 = [ "A", :n11 = [ "B" ] ], :n2 = [ 2 ] ])
	o.RemoveAllItems()
	o.AddItemAt("new", "[:root][:n1][:n11]")
	Then("an item is added into an emptied node", @@(o.Items()), '[ "new" ]')
	Then("and found at its path", @@(o.FindItem("new")), '[ "[:root][:n1][:n11][1]" ]')
	Then("ItemAt reads it back", o.ItemAt("[:root][:n1][:n11][1]"), "new")
	o.AddNodeAt([ "n3", [ 9 ] ], "[:root]")
	Then("a node is added too", len(o.Branches()), 5)
	Then("its item is counted", len(o.Items()), 2)
	o.RemoveItem("new")
	Then("and the new item can be removed again", @@(o.Items()), '[ 9 ]')
	o.AddItemAt("A", "[:root][:n2]")
	Then("an item removed earlier can be added back", @@(o.FindItem("A")), '[ "[:root][:n2][1]" ]')
EndScenario()

Scenario("Every query agrees with an independent expectation after a removal")
	aT = [ "root", [ :n1 = [ "a", "b", :n11 = [ "c", "a", 4 ], "d" ], :n2 = [ 4, "e", :n21 = [ "f", 9 ] ], :n3 = [ ] ] ]
	o = StzTreeQ(aT)
	aBefore = o.Items()
	aGone = [ "a", 4 ]
	o.RemoveTheseItems(aGone)
	aExp = ExpItems(aBefore, aGone)
	Then("Items", @@(o.Items()), @@(aExp))
	Then("AllItems", @@(o.AllItems()), @@(aExp))
	Then("Branches, six nodes in the depth-first order", @@(o.Branches()),
	     '[ "[:root]", "[:root][:n1]", "[:root][:n1][:n11]", "[:root][:n2]", "[:root][:n2][:n21]", "[:root][:n3]" ]')
	Then("Nodes", @@(o.Nodes()), '[ "root", "n1", "n11", "n2", "n21", "n3" ]')
	Then("Node n1 holds what is left of it, nested node included", @@(o.Node("n1")),
	     '[ "b", [ "n11", [ "c" ] ], "d" ]')
	Then("Node n11", @@(o.Node("n11")), '[ "c" ]')
	Then("Node n2", @@(o.Node("n2")), '[ "e", [ "n21", [ "f", 9 ] ] ]')
	Then("Node n3, empty before and after", @@(o.Node("n3")), '[ ]')
	Then("FindNode still answers the path of a node", o.FindNode("n21"), "[:root][:n2][:n21]")
	aPaths = o.FindItems()
	Then("FindItems has one path per remaining item", len(aPaths), len(aExp))
	acKeys = ExpKeys(aExp)
	bAll = 1
	nPaths = len(aPaths)
	for i = 1 to nPaths
		xAt = o.ItemAt(aPaths[i])
		cAt = @@(xAt)
		if StzFindFirst(cAt, acKeys) = 0
			bAll = 0
		ok
	next
	Then("ItemAt of each path is one of the remaining items", bAll, 1)
	nLeft = len(o.FindItem("a")) + len(o.FindItem(4))
	Then("no path of a removed item is left", nLeft, 0)
	aEPath = o.FindItem("e")
	Then("a kept item keeps a path that reads back", o.ItemAt(aEPath[1]), "e")
	Then("ItemsZ lists the remaining items", len(o.ItemsZ()), len(aExp))
	Then("Root keeps its name", o.Root()[1], "root")
EndScenario()

Scenario("Entries that Items does not count are not touched")
	o = StzTreeQ(:root = [ :n = [ 7, [ "odd", 7 ], 8 ] ])
	Then("Items counts the 7 and the 8 only", @@(o.Items()), '[ 7, 8 ]')
	o.RemoveAllItems()
	Then("the entry that is a name and a non-list stays where it was", @@(o.NodeAt("[:root][:n]")), '[ [ "odd", 7 ] ]')
	Then("and Items agrees: nothing left to count", len(o.Items()), 0)
EndScenario()

Scenario("The removal goes through the list's single update point")
	o = StzTreeQ(:root = [ :n = [ "A", "B" ] ])
	cBefore = @@(o.Content())
	o.RemoveItem("A")
	Then("Content shows the change", @@(o.Content()), '[ [ "root", [ [ "n", [ "B" ] ] ] ] ]')
	Then("it is still a one-item list holding the tree", len(o.Content()), 1)
	Then("a copy taken before is not changed", cBefore, '[ [ "root", [ [ "n", [ "A", "B" ] ] ] ] ]')
EndScenario()

Summary()

func ExpItems(aItems, aGone)
	aOut = []
	acGone = []
	nGone = len(aGone)
	for i = 1 to nGone
		acGone + @@(aGone[i])
	next
	nItems = len(aItems)
	for i = 1 to nItems
		cK = @@(aItems[i])
		bHit = 0
		for j = 1 to nGone
			if strcmp(cK, acGone[j]) = 0
				bHit = 1
				exit
			ok
		next
		if bHit = 0
			aOut + aItems[i]
		ok
	next
	return aOut

func ExpKeys(aItems)
	acOut = []
	nItems = len(aItems)
	for i = 1 to nItems
		acOut + @@(aItems[i])
	next
	return acOut

func Raises(o, cCode)
	try
		eval(cCode)
		return ""
	catch
		return cCatchError
	done
