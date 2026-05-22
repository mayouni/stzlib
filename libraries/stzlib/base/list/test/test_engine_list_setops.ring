# Test engine-backed set operations in stzListComparator + stzListMerger
# Run from base/list/test/: ring test_engine_list_setops.ring

chdir("../../data")
load "../../stzBase.ring"

? "=== CommonItems (intersection) ==="
oC = new stzListComparator([1, 2, 3, 4, 5])
? "  CommonItems [3,4,5,6,7]: " + @@(oC.CommonItems([3, 4, 5, 6, 7]))
# Expected: [3, 4, 5]

? ""
? "=== CommonItems: strings ==="
oC = new stzListComparator(["a", "b", "c", "d"])
? "  CommonItems [c,d,e]: " + @@(oC.CommonItems(["c", "d", "e"]))
# Expected: ["c", "d"]

? ""
? "=== Union ==="
oC = new stzListComparator([1, 2, 3])
? "  Union [3,4,5]: " + @@(oC.Union([3, 4, 5]))
# Expected: [1, 2, 3, 4, 5]

? ""
? "=== Difference ==="
oC = new stzListComparator([1, 2, 3, 4, 5])
? "  Difference [2,4]: " + @@(oC.Difference([2, 4]))
# Expected: [1, 3, 5]

? ""
? "=== IsSubsetOf ==="
oC = new stzListComparator([2, 3])
? "  IsSubsetOf [1,2,3,4]: " + oC.IsSubsetOf([1, 2, 3, 4])
# Expected: 1

oC2 = new stzListComparator([2, 5])
? "  IsSubsetOf [1,2,3,4]: " + oC2.IsSubsetOf([1, 2, 3, 4])
# Expected: 0

? ""
? "=== Zip ==="
oM = new stzListMerger([1, 2, 3])
? "  ZippedWith [a,b,c]: " + @@(oM.ZippedWith(["a", "b", "c"]))
# Expected: [ [1, "a"], [2, "b"], [3, "c"] ]

? ""
? "=== SymmetricDifference ==="
oC = new stzListComparator([1, 2, 3, 4])
? "  SymmetricDifference [3,4,5,6]: " + @@(oC.SymmetricDifference([3, 4, 5, 6]))
# Expected: [1, 2, 5, 6]

? ""
? "All set operation tests completed."
