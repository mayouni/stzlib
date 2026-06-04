# Test domain classes with composition pattern
# Run from the test/ directory: ring test_domains.ring

? "Loading stubs + DLL"

load "test_stubs.ring"

? "Loading classes"
load "../../string/stzString.ring"
load "../../string/stzStringFinder.ring"
load "../../string/stzStringSplitter.ring"
load "../../string/stzStringReplacer.ring"
? "Step 4: Testing stzString core"
o1 = new stzString("Ring is beautiful!")
? "  Content: " + o1.Content()
? "  NumberOfChars: " + o1.NumberOfChars()

? ""
? "=== Test 5: stzStringFinder (from string) ==="
oFinder = new stzStringFinder("Ring is beautiful!")
? "  Contains 'is': " + oFinder.Contains("is")
? "  FindFirst 'i': " + oFinder.FindFirst("i")
? "  NumberOfOccurrence 'i': " + oFinder.NumberOfOccurrence("i")
? "  StartsWith 'Ring': " + oFinder.StartsWith("Ring")
? "  EndsWith '!': " + oFinder.EndsWith("!")

? ""
? "=== Test 6: stzStringFinder (from stzString object) ==="
oFinder2 = new stzStringFinder(o1)
? "  Contains 'beautiful': " + oFinder2.Contains("beautiful")
? "  Content: " + oFinder2.Content()

? ""
? "=== Test 7: stzStringSplitter ==="
oSplitter = new stzStringSplitter(o1)
aParts = oSplitter.SplitAtSubString(" ")
? "  Split by space: " + len(aParts) + " parts"
for item in aParts
	? "    - [" + item + "]"
next

? ""
? "=== Test 8: stzStringReplacer ==="
oReplacer = new stzStringReplacer("Hello World!")
oReplacer.Replace("World", "Ring")
? "  After replace: " + oReplacer.Content()

? ""
? "=== ALL DOMAIN TESTS PASSED ==="
