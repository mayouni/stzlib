# Test engine-backed sorting operations in stzListSorter
# Run from base/list/test/: ring test_engine_list_sort.ring

load "../../stzBase.ring"

pr()

? "=== Sort: Ascending ==="
o = new stzList([3, 1, 4, 1, 5, 9, 2])
o.Sort()
? "  Sorted [3,1,4,1,5,9,2]: " + @@(o.Content())
# Expected: [1, 1, 2, 3, 4, 5, 9]

? ""
? "=== Sort: Descending ==="
o = new stzList([3, 1, 4, 1, 5])
o.SortInDescending()
? "  SortedDown [3,1,4,1,5]: " + @@(o.Content())
# Expected: [5, 4, 3, 1, 1]

? ""
? "=== Sort: Strings ==="
o = new stzList(["banana", "apple", "cherry"])
? "  Sorted strings: " + @@(o.Sorted())
# Expected: ["apple", "banana", "cherry"]

? ""
? "=== Sort: Mixed types ==="
o = new stzList([3, "hello", 1, "abc"])
? "  Sorted mixed: " + @@(o.Sorted())
# Expected: numbers first, then strings

? ""
? "=== Sort: SortedInDescending ==="
o = new stzList([10, 30, 20])
? "  SortedInDescending: " + @@(o.SortedInDescending())
# Expected: [30, 20, 10]

? ""
? "=== IsSorted: Ascending ==="
o1 = new stzList([1, 2, 3, 4])
? "  IsSortedInAscending [1,2,3,4]: " + o1.IsSortedInAscending()
# Expected: 1

o2 = new stzList([4, 2, 3, 1])
? "  IsSortedInAscending [4,2,3,1]: " + o2.IsSortedInAscending()
# Expected: 0

? ""
? "=== IsSorted: Descending ==="
o3 = new stzList([5, 4, 3, 2, 1])
? "  IsSortedInDescending [5,4,3,2,1]: " + o3.IsSortedInDescending()
# Expected: 1

o4 = new stzList([1, 2, 3])
? "  IsSortedInDescending [1,2,3]: " + o4.IsSortedInDescending()
# Expected: 0

? ""
? "=== Reverse ==="
o = new stzList([1, 2, 3, 4, 5])
? "  Reversed [1,2,3,4,5]: " + @@(o.Reversed())
# Expected: [5, 4, 3, 2, 1]

o.Reverse()
? "  After Reverse(): " + @@(o.Content())
# Expected: [5, 4, 3, 2, 1]

? ""
? "=== SortOn column ==="
aData = [ [3, "c"], [1, "a"], [2, "b"] ]
? "  SortListsOn col 1: " + @@(SortListsOn(aData, 1))
# Expected: [ [1, "a"], [2, "b"], [3, "c"] ]

? ""
? "All sort/reverse tests completed."

pf()
# Executed in almost 0 second(s) in Ring 1.27
