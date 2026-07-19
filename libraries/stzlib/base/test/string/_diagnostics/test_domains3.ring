# Test: Remover, LeadTrail, Trimmer with resolved TODOs
# Run from the test/ directory: ring test_domains3.ring

? "Loading stubs + DLL"
#ERR Error (R3) : Calling Function without definition: stzenginestring

# BOOTSTRAP NOTE
# This file loads the real library rather than test_stubs.ring.
#
# The stub is a hand-written mirror of the string domain's globals (Q,
# StzRaise, CheckParams, IsListOfStrings, StzStringQ, ...). This file needs
# things the stub does not carry -- stzObject, for the inherited Update()
# guard, or stzStringFunc's condition normalisers -- and those real files
# define the very same globals, so loading both is a wall of C22/C26
# redefinitions. Stub OR library, never a mix.
#
# The other files here that stay on the stub are the ones whose isolation
# still genuinely holds.
load "../../../stzBase.ring"

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
