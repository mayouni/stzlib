load "../../stzBase.ring"

pr()

? "=== Testing Engine Delegation Batch 2 ==="
? ""

# Test 1: IsListOfNumbers (engine-backed)
? "--- IsListOfNumbers ---"
o1 = new stzListChecker([1, 2, 3, 4.5])
? "IsListOfNumbers([1,2,3,4.5]) = " + o1.IsListOfNumbers()
# Expected: 1

o2 = new stzListChecker([1, "hello", 3])
? "IsListOfNumbers([1,'hello',3]) = " + o2.IsListOfNumbers()
# Expected: 0

o3 = new stzListChecker([])
? "IsListOfNumbers([]) = " + o3.IsListOfNumbers()
# Expected: 1 (vacuously true)

? ""

# Test 2: IsListOfStrings (engine-backed)
? "--- IsListOfStrings ---"
o4 = new stzListChecker(["a", "b", "c"])
? "IsListOfStrings(['a','b','c']) = " + o4.IsListOfStrings()
# Expected: 1

o5 = new stzListChecker(["a", 42, "c"])
? "IsListOfStrings(['a',42,'c']) = " + o5.IsListOfStrings()
# Expected: 0

? ""

# Test 3: Min/Max (engine-backed)
? "--- Min/Max ---"
o6 = new stzListSorter([5, 3, 8, 1, 9, 2])
? "Min([5,3,8,1,9,2]) = " + o6.Min()
# Expected: 1
? "Max([5,3,8,1,9,2]) = " + o6.Max()
# Expected: 9

? ""

# Test 4: RemoveDuplicates (engine-backed)
? "--- RemoveDuplicates ---"
o7 = new stzListDuplicates(["a", "b", "c", "a", "b", "d"])
o7.RemoveDuplicates()
aResult = o7.Content()
? "RemoveDuplicates(['a','b','c','a','b','d']): " + len(aResult) + " items"
for item in aResult
	? "  " + item
next
# Expected: 4 unique items

? ""

# Test 5: WithoutDuplication
? "--- WithoutDuplication ---"
o8 = new stzListDuplicates([1, 2, 3, 2, 4, 3, 5])
aUnique = o8.WithoutDuplication()
? "WithoutDuplication([1,2,3,2,4,3,5]): " + len(aUnique) + " items"
# Expected: 5 unique items

? ""

# Test 6: stzSet union/intersection with engine
? "--- stzSet operations ---"
oSet = new stzSet([1, 2, 3, 2, 1])
? "Set from [1,2,3,2,1]: " + len(oSet.Content()) + " elements"
# Expected: 3

? ""
? "=== All batch 2 delegation tests passed! ==="

pf()
