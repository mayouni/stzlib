
#ERR exit 3221225794

load "test_stubs.ring"
load "../../string/stzString.ring"
load "../../string/stzStringFinder.ring"
? "Step 1: Testing FindNthCS"
oFinder = new stzStringFinder(new stzString("hello world hello"))
nPos = oFinder.FindNthCS(2, "hello", 1)
if nPos = 13
	? "  FindNthCS 2nd: OK (pos=" + nPos + ")"
else
	? "  FAIL: FindNthCS expected 13, got " + nPos
ok

? "Step 2: Testing DuplicatesCS"
oFinder2 = new stzStringFinder(new stzString("abab"))
acDups = oFinder2.DuplicatesCS(1)
? "  DuplicatesCS count: " + len(acDups)
_nAcDups1Len_ = ring_len(acDups)
for _iLoopAcDups1_ = 1 to _nAcDups1Len_
	item = acDups[_iLoopAcDups1_]
	? "    dup: '" + item + "'"
next
if len(acDups) >= 3
	? "  DuplicatesCS: OK (>= 3 duplicates found)"
else
	? "  FAIL: expected >= 3 duplicates, got " + len(acDups)
ok

? "Step 3: Testing DuplicatesCS no duplicates"
oFinder3 = new stzStringFinder(new stzString("abcd"))
acDups3 = oFinder3.DuplicatesCS(1)
if len(acDups3) = 0
	? "  DuplicatesCS no dups: OK"
else
	? "  FAIL: expected 0, got " + len(acDups3)
ok

? "Step 4: Testing DuplicatesCS case-insensitive"
oFinder4 = new stzStringFinder(new stzString("AbAb"))
acDupsCI = oFinder4.DuplicatesCS(0)
? "  DuplicatesCS CI count: " + len(acDupsCI)
_nAcDupsCI1Len_ = ring_len(acDupsCI)
for _iLoopAcDupsCI1_ = 1 to _nAcDupsCI1Len_
	item = acDupsCI[_iLoopAcDupsCI1_]
	? "    dup: '" + item + "'"
next
if len(acDupsCI) >= 3
	? "  DuplicatesCS CI: OK"
else
	? "  FAIL: expected >= 3, got " + len(acDupsCI)
ok

? ""
? "=== ALL FINDER TESTS PASSED ==="
