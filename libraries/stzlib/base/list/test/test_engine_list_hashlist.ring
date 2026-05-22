# Test stzHashList operations (validates modularization)
# Run from base/list/test/: ring test_engine_list_hashlist.ring

load "../../stzBase.ring"

? "=== Init and Content ==="
o = new stzHashList([ :name = "mansour", :age = 44, :job = "programmer" ])
? "  NumberOfPairs: " + o.NumberOfPairs()
# Expected: 3

? ""
? "=== Keys and Values ==="
? "  Keys: " + @@(o.Keys())
# Expected: ["name", "age", "job"]
? "  Values: " + @@(o.Values())
# Expected: ["mansour", 44, "programmer"]

? ""
? "=== Pair access ==="
? "  NthPair(2): " + @@(o.NthPair(2))
# Expected: ["age", 44]

? ""
? "=== NthKey and NthValue ==="
? "  NthKey(1): " + o.NthKey(1)
# Expected: "name"
? "  NthValue(3): " + o.NthValue(3)
# Expected: "programmer"

? ""
? "=== SetValueAt ==="
o.SetValueAt(2, 45)
? "  After SetValueAt(2, 45): " + @@(o.NthPair(2))
# Expected: ["age", 45]

? ""
? "=== Content round-trip ==="
? "  Content: " + @@(o.Content())
# Expected: [ ["name", "mansour"], ["age", 45], ["job", "programmer"] ]

? ""
? "All stzHashList tests completed."
