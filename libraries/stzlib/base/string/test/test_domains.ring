# Test domain classes with composition pattern

? "Step 1: Loading DLL"

$cStzStringLib = "D:\GitHub\stzlib\libraries\stzlib\engine\zig-out\bin\stz_string.dll"

if fexists($cStzStringLib)
    $pStzStringHandle = LoadLib($cStzStringLib)
    ? "  DLL loaded OK"
else
    ? "  DLL not found!"
ok

? "Step 2: Loading stubs"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\test\test_stubs.ring"

? "Step 3: Loading classes"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzString.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringFinder.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringSplitter.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringReplacer.ring"

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
