# Test: Remover, LeadTrail, Trimmer with resolved TODOs
# Run from the test/ directory: ring test_domains3.ring

? "Loading stubs + DLL"
load "test_stubs.ring"

load "../stzString.ring"
load "../stzStringFinder.ring"
load "../stzStringReplacer.ring"
load "../stzStringRemover.ring"
load "../stzStringLeadTrail.ring"
load "../stzStringTrimmer.ring"

pr()

? ""
? "=== Test: stzString Trim ==="
oT = new stzString("  hello  ")
? "Before trim: [" + oT.Content() + "]"
oT.Trim()
? "After Trim: [" + oT.Content() + "]"

oT2 = new stzString("  hello  ")
oT2.TrimLeft()
? "After TrimLeft: [" + oT2.Content() + "]"

oT3 = new stzString("  hello  ")
oT3.TrimRight()
? "After TrimRight: [" + oT3.Content() + "]"

? ""
? "=== Test: stzStringRemover ==="
oRem = new stzStringRemover("Hello World")
oRem.RemoveAll("l")
? "RemoveAll 'l': [" + oRem.Content() + "]"

oRem2 = new stzStringRemover("aabbbcccc")
oRem2.RemoveSection(3, 5)
? "RemoveSection(3,5) from 'aabbbcccc': [" + oRem2.Content() + "]"

oRem3 = new stzStringRemover("Hello World!")
oRem3.RemoveFirst("l")
? "RemoveFirst 'l': [" + oRem3.Content() + "]"

oRem4 = new stzStringRemover("  spaced  ")
oRem4.RemoveLeadingSpaces()
? "RemoveLeadingSpaces: [" + oRem4.Content() + "]"

oRem5 = new stzStringRemover("  spaced  ")
oRem5.RemoveTrailingSpaces()
? "RemoveTrailingSpaces: [" + oRem5.Content() + "]"

? ""
? "=== Test: stzStringLeadTrail ==="
oLT = new stzStringLeadTrail("xxxHello")
? "StartsWithCS 'xxx': " + oLT.StartsWithCS("xxx", 1)
? "EndsWithCS 'llo': " + oLT.EndsWithCS("llo", 1)

oLT2 = new stzStringLeadTrail("xxxHello")
oLT2.RemoveFromStart("xxx")
? "RemoveFromStart 'xxx': [" + oLT2.Content() + "]"

oLT3 = new stzStringLeadTrail("HelloYYY")
oLT3.RemoveFromEnd("YYY")
? "RemoveFromEnd 'YYY': [" + oLT3.Content() + "]"

? ""
? "=== Test: stzStringTrimmer ==="
oTrim = new stzStringTrimmer("  hello world  ")
oTrim.TrimLeft()
? "TrimLeft: [" + oTrim.Content() + "]"

oTrim2 = new stzStringTrimmer("  hello world  ")
oTrim2.TrimRight()
? "TrimRight: [" + oTrim2.Content() + "]"

? ""
? "=== ALL EXTENDED TESTS PASSED ==="

pf()
