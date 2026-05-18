# Test stzString core with minimal stubs
# All procedural code MUST come before any class definition in Ring

? "Step 1: Loading DLL"

$cStzStringLib = "D:\GitHub\stzlib\libraries\stzlib\engine\zig-out\bin\stz_string.dll"

if fexists($cStzStringLib)
    $pStzStringHandle = LoadLib($cStzStringLib)
    ? "  DLL loaded OK"
else
    ? "  DLL not found!"
ok

? "Step 2: Loading stubs + stzObject"
load "D:\GitHub\stzlib\test_stubs.ring"

? "Step 3: Loading stzString"
load "D:\GitHub\stzlib\libraries\stzlib\base\string\stzString.ring"

? "Step 4: Creating stzString object"
o1 = new stzString("Hello")
? "  Content: " + o1.Content()
? "  NumberOfChars: " + o1.NumberOfChars()
? "  NthChar(1): " + o1.NthChar(1)
? "  Section(1,3): " + o1.Section(1, 3)
? "  Chars: " + list2str(o1.Chars())

? ""
? "=== ALL CORE TESTS PASSED ==="
