# Test engine-backed random/shuffle operations in stzListRandom
# Run from base/list/test/: ring test_engine_list_random.ring

load "../../stzBase.ring"

pr()

? "=== Shuffle ==="
oRand = new stzListRandom([1, 2, 3, 4, 5])
oRand.Shuffle()
? "  Shuffled [1,2,3,4,5]: " + @@(oRand.Content())
? "  Length preserved: " + len(oRand.Content())
# Expected: 5 items in some permuted order

? ""
? "=== Randomized ==="
oRand = new stzListRandom(["a", "b", "c", "d", "e"])
aRandom = oRand.Randomized()
? "  Randomized [a,b,c,d,e]: " + @@(aRandom)
? "  Length preserved: " + len(aRandom)
# Expected: 5 items in random order, original unchanged

? "  Original unchanged: " + @@(oRand.Content())
# Expected: ["a", "b", "c", "d", "e"]

? ""
? "=== NRandomItems ==="
oRand = new stzListRandom([10, 20, 30, 40, 50, 60, 70])
aPicked = oRand.NRandomItems(3)
? "  NRandomItems(3) from 7 items: " + @@(aPicked)
? "  Picked count: " + len(aPicked)
# Expected: 3 items from the list

? ""
? "=== NRandomItems: pick more than available ==="
oRand = new stzListRandom([1, 2, 3])
aPicked = oRand.NRandomItems(10)
? "  NRandomItems(10) from 3 items: " + @@(aPicked)
? "  Capped at list size: " + len(aPicked)
# Expected: 3 (capped)

? ""
? "All random/shuffle tests completed."

pf()
