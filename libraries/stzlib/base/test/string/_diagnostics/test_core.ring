# Test stzString core with minimal stubs
# All procedural code MUST come before any class definition in Ring
# Run from the test/ directory: ring test_core.ring

? "Step 1: Loading stubs + DLL"
#ERR Error (R3) : Calling Function without definition: stzenginestring

load "test_stubs.ring"

? "Step 2: Loading stzString"
load "../../../string/stzString.ring"
? "Step 4: Creating stzString object"
o1 = new stzString("Hello")
? "  Content: " + o1.Content()
? "  NumberOfChars: " + o1.NumberOfChars()
? "  NthChar(1): " + o1.NthChar(1)
? "  Section(1,3): " + o1.Section(1, 3)
? "  Chars: " + list2str(o1.Chars())

? ""
? "=== ALL CORE TESTS PASSED ==="
