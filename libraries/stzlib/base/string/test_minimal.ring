# Minimal test: verify composition pattern
# Tests core stzString + Finder + Splitter + Replacer
# Run from the base/string/ directory: ring test_minimal.ring

? "Loading stubs + DLL"
load "test/test_stubs.ring"

? "Loading domain classes"
load "stzString.ring"
load "stzStringFinder.ring"
load "stzStringSplitter.ring"
load "stzStringReplacer.ring"

# --- Tests ---

? ""
? "=== Test 1: Core stzString ==="
o1 = new stzString("Ring is beautiful!")
? "Content: " + o1.Content()
? "NumberOfChars: " + o1.NumberOfChars()
? "Section(1,4): " + o1.Section(1, 4)
? "NthChar(1): " + o1.NthChar(1)
? "Chars count: " + len(o1.Chars())

? ""
? "=== Test 2: stzStringFinder (from string) ==="
oFinder = new stzStringFinder("Ring is beautiful!")
? "Contains 'is': " + oFinder.Contains("is")
? "FindFirst 'i': " + oFinder.FindFirst("i")
? "NumberOfOccurrence 'i': " + oFinder.NumberOfOccurrence("i")
? "StartsWith 'Ring': " + oFinder.StartsWith("Ring")
? "EndsWith '!': " + oFinder.EndsWith("!")

? ""
? "=== Test 3: stzStringFinder (from stzString object) ==="
oFinder2 = new stzStringFinder(o1)
? "Contains 'beautiful': " + oFinder2.Contains("beautiful")
? "Content: " + oFinder2.Content()

? ""
? "=== Test 4: stzStringSplitter ==="
oSplitter = new stzStringSplitter(o1)
aParts = oSplitter.SplitAtSubString(" ")
? "Split by space:"
for item in aParts
	? "  - [" + item + "]"
next

? ""
? "=== Test 5: stzStringReplacer ==="
oReplacer = new stzStringReplacer("Hello World!")
oReplacer.Replace("World", "Ring")
? "After replace: " + oReplacer.Content()

? ""
? "=== ALL COMPOSITION TESTS PASSED ==="
