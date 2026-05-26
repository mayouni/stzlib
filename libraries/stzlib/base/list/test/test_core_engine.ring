load "../../stzBase.ring"

? "=== stzList Core Engine Delegation ==="

o = new stzList([1, 2, 3, "hello", 5])

? "IsListOfNumbers: " + o.IsListOfNumbers()
# Expected: 0

? "IsListOfStrings: " + o.IsListOfStrings()
# Expected: 0

o2 = new stzList([10, 20, 30, 5, 15])
? "Min: " + o2.Min()
# Expected: 5
? "Max: " + o2.Max()
# Expected: 30

o3 = new stzList(["a", "b", "c"])
? "IsListOfStrings: " + o3.IsListOfStrings()
# Expected: 1

o4 = new stzList([])
? "Min of empty: " + o4.Min()
# Expected: 0
? "Max of empty: " + o4.Max()
# Expected: 0

? ""
? "=== Core engine delegation OK ==="
