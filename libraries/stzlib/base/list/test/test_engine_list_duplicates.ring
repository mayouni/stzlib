# Test engine-backed duplicate operations in stzListDuplicates + stzListChecker
# Run from base/list/test/: ring test_engine_list_duplicates.ring

load "../../stzBase.ring"

? "=== FindDuplicates ==="
oD = new stzListDuplicates([1, 2, 3, 2, 4, 1, 3])
? "  FindDuplicates [1,2,3,2,4,1,3]: " + @@(oD.FindDuplicates())
# Expected: positions of duplicate items

? ""
? "=== FindNonDuplicatedItems ==="
oD = new stzListDuplicates([1, 2, 3, 2, 4, 1])
? "  FindNonDuplicatedItems: " + @@(oD.FindNonDuplicatedItems())
# Expected: positions of items that appear only once

? ""
? "=== AllItemsAreUnique ==="
oCh = new stzListChecker([1, 2, 3, 4])
? "  AllItemsAreUnique [1,2,3,4]: " + oCh.AllItemsAreUnique()
# Expected: 1

oCh2 = new stzListChecker([1, 2, 3, 2])
? "  AllItemsAreUnique [1,2,3,2]: " + oCh2.AllItemsAreUnique()
# Expected: 0

? ""
? "=== RemoveDuplicates ==="
o = new stzList([1, 1, 2, 3, 3, 3, 4])
o.RemoveDuplicates()
? "  After RemoveDuplicates [1,1,2,3,3,3,4]: " + @@(o.Content())
# Expected: [1, 2, 3, 4]

? ""
? "=== IsEqualTo ==="
o = new stzList([1, 2, 3])
? "  IsEqualTo [1,2,3]: " + o.IsEqualTo([1, 2, 3])
# Expected: 1
? "  IsEqualTo [1,2,4]: " + o.IsEqualTo([1, 2, 4])
# Expected: 0

? ""
? "All duplicate/unique tests completed."
