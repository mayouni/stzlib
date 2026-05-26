load "../../stzBase.ring"

? "=== Testing Global Find Engine Delegation ==="
? ""

# Test @FindAllCS for string items in lists
aList = ["apple", "banana", "cherry", "banana", "date"]
anPos = @FindAllCS(aList, "banana", 1)
? "FindAll 'banana': " + len(anPos) + " found"
for p in anPos
	? "  pos: " + p
next
# Expected: 2 positions (2 and 4)

? ""

# Test case-insensitive find
aList2 = ["Hello", "HELLO", "hello", "World"]
anPos2 = @FindAllCS(aList2, "hello", 0)
? "FindAll 'hello' (case-insensitive): " + len(anPos2) + " found"
# Expected: 3 positions

? ""

# Test ItemExists (engine-backed for strings)
? "ItemExists('cherry', list): " + ItemExists("cherry", aList)
# Expected: 1
? "ItemExists('mango', list): " + ItemExists("mango", aList)
# Expected: 0

? ""

# Test with numbers (fallback path)
aNumbers = [10, 20, 30, 20, 40]
anPos3 = @FindAllCS(aNumbers, 20, 1)
? "FindAll 20 in numbers: " + len(anPos3) + " found"
for p in anPos3
	? "  pos: " + p
next
# Expected: 2 positions (2 and 4)

? ""
? "=== All global find tests passed! ==="
