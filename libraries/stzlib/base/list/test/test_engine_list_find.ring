# Test engine-backed find/search operations in stzList + stzListFinder
# Run from base/list/test/: ring test_engine_list_find.ring

load "../../stzBase.ring"

? "=== FindCS: case sensitive ==="
o = new stzList(["hello", "Hello", "HELLO", "hello"])
? "  FindFirstCS('hello', :CS=1): " + o.FindFirstCS("hello", :CS = TRUE)
# Expected: 1
? "  FindFirstCS('Hello', :CS=1): " + o.FindFirstCS("Hello", :CS = TRUE)
# Expected: 2

? ""
? "=== FindAllCS ==="
o = new stzList([1, 2, 3, 2, 4, 2])
? "  FindAll(2): " + @@(o.FindAll(2))
# Expected: [2, 4, 6]

? ""
? "=== Contains ==="
o = new stzList(["apple", "banana", "cherry"])
? "  Contains('banana'): " + o.Contains("banana")
# Expected: 1
? "  Contains('mango'): " + o.Contains("mango")
# Expected: 0

? ""
? "=== Count ==="
o = new stzList([1, 2, 1, 3, 1, 4, 1])
? "  Count(1): " + o.Count(1)
# Expected: 4

? ""
? "=== UniqueItems via stzListGetter ==="
oG = new stzListGetter([1, 2, 3, 2, 1, 4, 3])
? "  UniqueItems [1,2,3,2,1,4,3]: " + @@(oG.UniqueItems())
# Expected: [1, 2, 3, 4]

? ""
? "All find/search tests completed."
