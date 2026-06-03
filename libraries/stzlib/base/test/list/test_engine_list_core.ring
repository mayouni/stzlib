# Test engine-backed core operations: marshaling, type detection, item access
# Run from base/list/test/: ring test_engine_list_core.ring

load "../../stzBase.ring"

? "=== Core: Init and Content ==="
o = new stzList([1, 2, 3])
? "  Content: " + @@(o.Content())
# Expected: [1, 2, 3]

? "  NumberOfItems: " + o.NumberOfItems()
# Expected: 3

? ""
? "=== Core: Engine marshaling round-trip ==="
o = new stzList([10, "hello", 3.14, "world"])
pList = o._EngineListFromContent()
aBack = StzEngineContentFromList(pList)
StzEngineListFree(pList)
? "  Round-trip [10, hello, 3.14, world]: " + @@(aBack)
# Expected: [10, "hello", 3.14, "world"]

? ""
? "=== Core: Nested list marshaling ==="
o = new stzList([1, [2, 3], [4, [5, 6]]])
pList = o._EngineListFromContent()
aBack = StzEngineContentFromList(pList)
StzEngineListFree(pList)
? "  Round-trip nested: " + @@(aBack)
# Expected: [1, [2, 3], [4, [5, 6]]]

? ""
? "=== Core: Empty list ==="
o = new stzList([])
? "  Empty content: " + @@(o.Content())
# Expected: []
? "  NumberOfItems: " + o.NumberOfItems()
# Expected: 0

? ""
? "=== @SortList global function ==="
? "  @SortList([5,3,1,4,2]): " + @@(@SortList([5, 3, 1, 4, 2]))
# Expected: [1, 2, 3, 4, 5]

? ""
? "=== @SortList: strings ==="
? "  @SortList(['c','a','b']): " + @@(@SortList(["c", "a", "b"]))
# Expected: ["a", "b", "c"]

? ""
? "=== SortListsOn global function ==="
aData = [ ["banana", 3], ["apple", 1], ["cherry", 2] ]
? "  SortListsOn col 2: " + @@(SortListsOn(aData, 2))
# Expected: [ ["apple", 1], ["cherry", 2], ["banana", 3] ]

? ""
? "=== SortListsOn: reversed params ==="
? "  SortListsOn(1, data): " + @@(SortListsOn(1, [ [2, "b"], [1, "a"], [3, "c"] ]))
# Expected: sorted by column 1

? ""
? "All core/marshaling tests completed."
