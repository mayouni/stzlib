load "../../stzBase.ring"

# THE SCOPE / COUNTER CONTRACT of a plastic rule: each answers a LIST of
# subject keys. A rule whose counter answered a number (a count, a 0/1 flag)
# once crashed the whole governor with "len() Bad parameter type" -- no rule
# name, no file -- and eight rules in three math files did exactly that
# without anyone seeing it, because the only caller that asks every rule
# every question is the adversarial gate. The accessor now says it, naming
# the rule. Standalone: seconds, no picture rendered.

nOk = 0  nBad = 0

# a well-formed rule: both answer lists
oGood = StzPlasticRule("well_formed")
oGood.SetScope(func(oDg) { return [ "a", "b" ] })
oGood.SetCounter(func(oDg) { return [ "c" ] })
chk("A WELL-FORMED RULE ANSWERS ITS LISTS UNTOUCHED",
	len(oGood.SubjectsIn(0)) = 2 and len(oGood.CounterSubjectsIn(0)) = 1)

# an empty list is a valid answer -- "governs nothing here" is not an error
oEmpty = StzPlasticRule("answers_nothing")
oEmpty.SetScope(func(oDg) { return [] })
oEmpty.SetCounter(func(oDg) { return [] })
chk("...AND AN EMPTY LIST IS A VALID ANSWER, not mistaken for a malformed one",
	len(oEmpty.SubjectsIn(0)) = 0 and len(oEmpty.CounterSubjectsIn(0)) = 0)

# no scope, no counter set: the documented [ ]
oNone = StzPlasticRule("unset")
chk("...AND A RULE WITH NO SCOPE OR COUNTER SET STILL ANSWERS [ ]",
	len(oNone.SubjectsIn(0)) = 0 and len(oNone.CounterSubjectsIn(0)) = 0)

# the defect: a counter that returns a number
oNum = StzPlasticRule("counts_instead")
oNum.SetScope(func(oDg) { return [] })
oNum.SetCounter(func(oDg) { return 3 })
cMsg = ""
try
	oNum.CounterSubjectsIn(0)
catch
	cMsg = cCatchError
done
chk("A COUNTER THAT ANSWERS A NUMBER IS REFUSED, not passed on to be len()'d later",
	cMsg != "")
chk("...AND THE REFUSAL NAMES THE RULE, so the author knows which of fifty-six to open",
	StzFindFirst("counts_instead", cMsg) > 0)
chk("...AND SAYS WHICH OF THE TWO, and what it answered",
	StzFindFirst("counter", cMsg) > 0 and StzFindFirst("number", cMsg) > 0)

# the same contract on the scope side, with a string this time
oStr = StzPlasticRule("scope_is_a_word")
oStr.SetScope(func(oDg) { return "figure:fr" })
cMsg2 = ""
try
	oStr.SubjectsIn(0)
catch
	cMsg2 = cCatchError
done
chk("THE SCOPE SIDE HOLDS THE SAME CONTRACT -- a bare string is refused and named",
	StzFindFirst("scope_is_a_word", cMsg2) > 0 and StzFindFirst("scope", cMsg2) > 0)

? ""
? " " + nOk + " ok, " + nBad + " failed"

func chk cWhat, bCond
	if bCond
		nOk++
		? "  ok   " + cWhat
	else
		nBad++
		? "  FAIL " + cWhat
	ok
