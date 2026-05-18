# Test additional domain classes

? "Loading DLL"
$cStzStringLib = "D:\GitHub\stzlib\libraries\stzlib\engine\zig-out\bin\stz_string.dll"
if fexists($cStzStringLib)
    $pStzStringHandle = LoadLib($cStzStringLib)
ok

? "Loading stubs"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\test\test_stubs.ring"

? "Loading classes"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzString.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringFinder.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringBounder.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringFormatter.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringGetter.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringCounter.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringChecker.ring"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzStringConcat.ring"

? ""
? "=== Test: stzStringBounder ==="
oBounder = new stzStringBounder("<<hello>> and <<world>>")
? "  Content: " + oBounder.Content()
? "  Section(1,7): " + oBounder.Section(1, 7)

? ""
? "=== Test: stzStringFormatter ==="
oFmt = new stzStringFormatter("hello world")
? "  Content: " + oFmt.Content()
? "  Uppercased: " + oFmt.Uppercased()

? ""
? "=== Test: stzStringGetter ==="
oGet = new stzStringGetter("Hello Ring")
? "  NthChar(1): " + oGet.NthChar(1)
? "  FirstChar: " + oGet.FirstChar()
? "  LastChar: " + oGet.LastChar()
? "  Section(1,5): " + oGet.Section(1, 5)

? ""
? "=== Test: stzStringCounter ==="
oCnt = new stzStringCounter("abracadabra")
? "  NumberOfChars: " + oCnt.NumberOfChars()

? ""
? "=== Test: stzStringChecker ==="
oChk = new stzStringChecker("abcba")
? "  Content: " + oChk.Content()

? ""
? "=== Test: stzStringConcat ==="
oConcat = new stzStringConcat("Hello")
? "  Content: " + oConcat.Content()

? ""
? "=== ALL ADDITIONAL DOMAIN TESTS PASSED ==="
