# Test engine-backed structural operations: flatten, chunk, rotate, section
# Run from base/list/test/: ring test_engine_list_structure.ring

load "../../stzBase.ring"

pr()

? "=== Flatten ==="
o = new stzList([1, [2, 3], 4, [5, 6]])
? "  Flattened: " + @@(o.Flattened())
# Expected: [1, 2, 3, 4, 5, 6]

? ""
? "=== DeepFlatten via stzListFlattener ==="
oF = new stzListFlattener([1, [2, [3, [4, 5]]], 6])
? "  DeepFlattened: " + @@(oF.DeepFlattened())
# Expected: [1, 2, 3, 4, 5, 6]

? ""
? "=== Chunked via stzListFlattener ==="
oF = new stzListFlattener([1, 2, 3, 4, 5, 6, 7])
? "  Chunked(3): " + @@(oF.Chunked(3))
# Expected: [ [1, 2, 3], [4, 5, 6], [7] ]

? ""
? "=== Paired via stzListFlattener ==="
oF = new stzListFlattener([1, 2, 3, 4, 5, 6])
? "  Paired: " + @@(oF.Paired())
# Expected: [ [1, 2], [3, 4], [5, 6] ]

? ""
? "=== RotateLeft via stzListMover ==="
oM = new stzListMover([1, 2, 3, 4, 5])
oM.RotateLeft(2)
? "  RotateLeft(2) on [1,2,3,4,5]: " + @@(oM.Content())
# Expected: [3, 4, 5, 1, 2]

? ""
? "=== RotateRight via stzListMover ==="
oM = new stzListMover([1, 2, 3, 4, 5])
oM.RotateRight(2)
? "  RotateRight(2) on [1,2,3,4,5]: " + @@(oM.Content())
# Expected: [4, 5, 1, 2, 3]

? ""
? "=== Section ==="
o = new stzList([10, 20, 30, 40, 50])
? "  Section(2, 4): " + @@(o.Section(2, 4))
# Expected: [20, 30, 40]

? ""
? "=== Section: full range ==="
o = new stzList([1, 2, 3])
? "  Section(1, 3): " + @@(o.Section(1, 3))
# Expected: [1, 2, 3]

? ""
? "All structural operation tests completed."

pf()
