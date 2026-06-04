

load "test_stubs.ring"
load "../../string/stzString.ring"
load "../../string/stzStringFinder.ring"
load "../../string/stzStringInserter.ring"
? "Step 1: Testing InsertBefore position"
o = new stzStringInserter("Hello World")
o.InsertBefore(6, "Beautiful ")
if o.Content() = "Hello Beautiful World"
	? "  InsertBefore position: OK"
else
	? "  FAIL: got '" + o.Content() + "'"
ok

? "Step 2: Testing InsertBeforeSubString (case-sensitive)"
o2 = new stzStringInserter("abc def abc")
o2.InsertBeforeSubStringCS("abc", "[", 1)
if o2.Content() = "[abc def [abc"
	? "  InsertBeforeSubStringCS (CS): OK"
else
	? "  FAIL: got '" + o2.Content() + "'"
ok

? "Step 3: Testing InsertAfterSubString (case-sensitive)"
o3 = new stzStringInserter("abc def abc")
o3.InsertAfterSubStringCS("abc", "]", 1)
if o3.Content() = "abc] def abc]"
	? "  InsertAfterSubStringCS (CS): OK"
else
	? "  FAIL: got '" + o3.Content() + "'"
ok

? "Step 4: Testing InsertBeforeSubString (case-insensitive)"
o4 = new stzStringInserter("Abc def ABC")
o4.InsertBeforeSubStringCS("abc", "[", 0)
if o4.Content() = "[Abc def [ABC"
	? "  InsertBeforeSubStringCS (CI): OK"
else
	? "  FAIL: got '" + o4.Content() + "'"
ok

? "Step 5: Testing InsertAfterSubString (case-insensitive)"
o5 = new stzStringInserter("Abc def ABC")
o5.InsertAfterSubStringCS("abc", "]", 0)
if o5.Content() = "Abc] def ABC]"
	? "  InsertAfterSubStringCS (CI): OK"
else
	? "  FAIL: got '" + o5.Content() + "'"
ok

? "Step 6: Testing FindNthCS via engine"
oFinder = new stzStringFinder(new stzString("hello world hello"))
nPos = oFinder.FindNthCS(2, "hello", 1)
if nPos = 13
	? "  FindNthCS 2nd occurrence: OK (pos=" + nPos + ")"
else
	? "  FAIL: FindNthCS expected 13, got " + nPos
ok

nPos = oFinder.FindNthCS(1, "hello", 1)
if nPos = 1
	? "  FindNthCS 1st occurrence: OK (pos=" + nPos + ")"
else
	? "  FAIL: FindNthCS expected 1, got " + nPos
ok

? ""
? "=== ALL INSERTER TESTS PASSED ==="
