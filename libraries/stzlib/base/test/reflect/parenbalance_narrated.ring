# The paren balancer, and the multi-line sample it silently dropped.
#
# _StzParenBalance existed to answer "does this line have unclosed parens?"
# so that _StzParseThenSamples could join a Then(...) call spanning several
# lines. It was written as:
#
#     len(StzFindCS(pcStr, "(", 1)) - len(StzFindCS(pcStr, ")", 1))
#
# with needle and haystack REVERSED: it asked for the whole line inside the
# one-character string "(", which is never found. Both terms were 0, so the
# function returned 0 for EVERY input.
#
# WHY THAT WAS INVISIBLE. It still compiled. It still returned a number. And
# 0 is exactly the answer a balanced line should give, so every single-line
# sample kept working. Only the multi-line ones were lost, and they were lost
# SILENTLY -- the harvester returned a shorter list, not an error.
#
# This guard therefore does two things a "does it still work?" test would not:
# it asserts the balancer on inputs where a broken one and a correct one MUST
# differ (unbalanced strings, where the answer is not 0), and it asserts the
# multi-line PARSE, which is the behaviour anyone actually cares about. A test
# that only checked "Then(a, b, c)" would have passed against the bug.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: balanced lines: 0, as they always did --"
chk("a complete call balances", _StzParenBalance('Then(a, b, c)') = 0)
chk("nesting balances", _StzParenBalance("f(g(h(x)))") = 0)
chk("no parens at all balances", _StzParenBalance("no parens here") = 0)
# These three are the ones the BUG also passed. They are here to show the fix
# did not move the cases that were already right -- not as evidence it works.

? ""
? "-- Scene 2: the cases that separate a balancer from a stub --"
# Every assertion below returned 0 before the fix. This is the scene that
# could actually fail, which is the only kind that guards anything.
chk("one unclosed paren is +1", _StzParenBalance("Then(a, b,") = 1)
chk("two unclosed parens are +2", _StzParenBalance("f(g(") = 2)
chk("a surplus closer is -1", _StzParenBalance("a, b)") = -1)
chk("two surplus closers are -2", _StzParenBalance("))") = -2)
chk("it counts, it does not merely detect",
	_StzParenBalance("((((") = 4 and _StzParenBalance("(((()))") = 1)

? ""
? "-- Scene 3: and the multi-line sample is no longer dropped --"
# The behaviour the balancer exists to serve. Written to disk because
# _StzParseThenSamples reads a FILE -- testing the helper alone is what let
# this survive.
cTmp = "_pb_fixture.ring"
write(cTmp, 'Then("single line sample", 1 + 1, 2)' + nl +
            'Then("multi line sample",' + nl +
            '     2 + 3,' + nl +
            '     5)' + nl +
            'Then("another single", 4 * 2, 8)' + nl)

aS = _StzParseThenSamples(cTmp)
chk("all THREE samples are harvested, not two", len(aS) = 3)
# Before the fix this was 2: the continuation loop never ran, so the
# multi-line call was cut at its first line and thrown away downstream for
# not having 3 arguments.

bFound = FALSE
for i = 1 to len(aS)
	if aS[i][1] = "multi line sample"
		bFound = TRUE
		chk("...and the multi-line one is reassembled correctly",
			ring_trim(aS[i][2]) = "2 + 3" and ring_trim(aS[i][3]) = "5")
	ok
next
chk("the multi-line sample is present at all", bFound)

chk("the single-line ones are untouched",
	aS[1][1] = "single line sample" and ring_trim(aS[1][2]) = "1 + 1")

remove(cTmp)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
