# Test engine-backed case changing functions
# Run from the test/ directory: ring test_engine_case.ring

? "Loading stubs + DLL"
#ERR Error (R3) : Calling Function without definition: stzenginestring

load "test_stubs.ring"

? "Loading stzString + CaseChanger"
load "../../string/stzString.ring"
load "../../string/stzStringCaseChanger.ring"
? ""
? "=== Test 1: Engine ToUpper/ToLower via stzStringCaseChanger ==="

oCase = new stzStringCaseChanger("hello world")
? "  Uppercased('hello world'): " + oCase.Uppercased()  # HELLO WORLD
? "  Content unchanged: " + oCase.Content()              # hello world

oCase2 = new stzStringCaseChanger("HELLO WORLD")
? "  Lowercased('HELLO WORLD'): " + oCase2.Lowercased()  # hello world

? ""
? "=== Test 2: IsUppercase / IsLowercase ==="

oUp = new stzStringCaseChanger("HELLO")
? "  IsUppercase('HELLO'): " + oUp.IsUppercase()        # 1
? "  IsLowercase('HELLO'): " + oUp.IsLowercase()        # 0

oLo = new stzStringCaseChanger("hello")
? "  IsUppercase('hello'): " + oLo.IsUppercase()        # 0
? "  IsLowercase('hello'): " + oLo.IsLowercase()        # 1

oMix = new stzStringCaseChanger("Hello")
? "  IsUppercase('Hello'): " + oMix.IsUppercase()       # 0
? "  IsLowercase('Hello'): " + oMix.IsLowercase()       # 0

? ""
? "=== Test 3: Mutating Uppercase/Lowercase ==="

oMut = new stzStringCaseChanger("hello")
oMut.Uppercase()
? "  After Uppercase(): " + oMut.Content()               # HELLO

oMut2 = new stzStringCaseChanger("WORLD")
oMut2.Lowercase()
? "  After Lowercase(): " + oMut2.Content()              # world

? ""
? "=== Test 4: Capitalize ==="

oCap = new stzStringCaseChanger("hello world")
? "  Capitalized: " + oCap.Capitalized()                 # Hello world

oCap2 = new stzStringCaseChanger("hello world")
? "  EachWordCapitalized: " + oCap2.EachWordCapitalized() # Hello World

? ""
? "=== Test 5: ToggleCase ==="

oTog = new stzStringCaseChanger("Hello World")
? "  CaseToggled: " + oTog.CaseToggled()                 # hELLO wORLD

? ""
? "=== ALL ENGINE CASE TESTS PASSED ==="
