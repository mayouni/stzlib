load "../../stzBase.ring"
load "../_narrated.ring"

# THE HANDLE-TABLE CLIFF.
#
# `StringToNumber("1")` -- the same literal string every time -- worked 1365 times and
# then failed for the rest of the process. So did anything built on it, which is most
# of stzNumber's arithmetic, because pvtCalculate routes through it.
#
# The error did not say "out of handles". It said:
#
#     Can not create char object!
#
# raised from a validation branch in stzStringChar that had simply run out of room to
# build the objects it validates WITH. Every path that needed a new engine-backed
# object failed the same way from then on, so the first symptom a caller saw was
# usually nowhere near the cause.
#
# WHAT WAS ACTUALLY HAPPENING. ring_api.zig held a fixed 8192-slot handle table.
# `storeHandle` filled a null slot and returned its 1-based id; when none was left it
# returned 0, which Ring read as a null pointer. `releaseSlot` exists and the explicit
# Free paths call it -- but RING HAS NO DESTRUCTORS, so an object that merely goes out
# of scope never reaches a Free. Any wrapper built to ask a question and then dropped
# consumed a slot permanently.
#
# The rates fall straight out of that:
#
#     new stzChar("1")      failed at 4097    (two stzStrings each: 8192/2)
#     new stzNumber("1")    failed at 1639
#     StringToNumber("1")   failed at 1366
#
# TWO FIXES, AND THEY ARE DIFFERENT IN KIND.
#
# First, three wrapper objects came out of stzNumber's constructor -- the
# wrap-to-validate anti-pattern this library already has on record. The worst was
#
#     if StzStringQ(pNumber).IsAChar() and StzCharQ(pNumber).IsCircledNumber()
#
# two objects built on EVERY string construction to ask about circled Unicode
# numerals, and because Ring's `and` evaluates both sides, the stzChar was built even
# for strings that were plainly not one character. It is a codepoint-and-byte-count
# test now, which allocates nothing and is exact: a circled numeral is U+2460 or
# above, so it is one codepoint and more than one byte. That alone moved the cliff
# from 1366 to 8191.
#
# Second, and this is the one that matters, THE TABLE NOW GROWS. Removing wrappers
# raises the ceiling; it cannot remove it, because the ceiling is reached by any
# long-running program that creates engine-backed objects. Growing rather than
# evicting is deliberate: a fixed table can only make room by evicting a live entry,
# and nothing knows whether an id is still held on the Ring side, so a reused slot
# would hand one object's pointer to another. That is far worse than an honest
# failure. Growth cannot do it -- an id stays valid for the life of the process -- and
# costs 8 bytes per leaked handle, which is visible in RSS and survivable where the
# cliff was neither.

Scenario("the exact loop that used to die at 1366")
	nFail = 0
	for i = 1 to 25000
		try
			v = StringToNumber("1")
		catch
			nFail = i
			exit
		done
	next
	Then("25000 calls, no failure", nFail, 0)
	Then("...and the answer is still right", StringToNumber("1"), 1)
	Then("...for a decimal too", StringToNumber("12.375"), 12.375)
	Then("...and a negative", StringToNumber("-4.5"), -4.5)
EndScenario()

Scenario("...and the arithmetic path built on it")
	# pvtCalculate is stzNumber's arithmetic chokepoint and goes through
	# StringToNumber, so every numeric method inherited the cliff.
	nFail = 0
	for i = 1 to 25000
		try
			v = StzNumberQ((i % 70) - 35).Sigmoid()
		catch
			nFail = i
			exit
		done
	next
	Then("25000 sigmoids, no failure", nFail, 0)
	Then("...and sigmoid(0) is still a half", Rnd6(StzNumberQ(0).Sigmoid()), 0.5)
	Then("...still saturating at the top", Rnd6(StzNumberQ(800).Sigmoid()), 1)
	Then("...and at the bottom", Rnd6(StzNumberQ(-800).Sigmoid()), 0)
EndScenario()

Scenario("the two constructors that measured the leak")
	nFail = 0
	for i = 1 to 25000
		try
			v = new stzChar("1")
		catch
			nFail = i
			exit
		done
	next
	Then("25000 stzChars, where 4097 used to be the wall", nFail, 0)

	nFail = 0
	for i = 1 to 25000
		try
			v = new stzNumber("12.375")
		catch
			nFail = i
			exit
		done
	next
	Then("25000 stzNumbers from strings, where 1639 was the wall", nFail, 0)
EndScenario()

Scenario("the constructor still reads every form it used to")
	# The wrapper objects came out; the SEMANTICS must not have. These are the branches
	# the removed probes were guarding.
	Then("a plain integer", (new stzNumber("42")).NumericValue(), 42)
	Then("a decimal", (new stzNumber("12.375")).NumericValue(), 12.375)
	Then("...and its round is the decimal count", (new stzNumber("12.375")).Round(), 3)
	# PRE-EXISTING, found while checking this change did not regress anything:
	# "1_000" RAISES, and did so before this change too. The underscore-stripping
	# code below is unreachable, because StringRepresentsNumberInDecimalForm rejects
	# the underscore first. Asserted as it behaves, not as the dead code intends.
	Then("an underscore separator actually RAISES -- the stripping code is dead",
	     RaisesNum("1_000"), TRUE)
	Then("a trailing dot gains a zero", (new stzNumber("12.")).NumericValue(), 12)
	Then("an empty string is zero", (new stzNumber("")).NumericValue(), 0)
	Then("a rational is reduced", (new stzNumber("2/4")).Content(), "1/2")
	Then("a number argument still works", (new stzNumber(7)).NumericValue(), 7)

	# THE CIRCLED-NUMERAL BRANCH -- what the two removed objects existed to probe.
	#
	# This assertion used to pin the DEFECT: "answers 0 -- unchanged, and wrong,
	# and pre-existing". The branch really was dead -- stzChar.Number() switched
	# the circled glyph against "0".."9" and matched nothing, so the constructor
	# stored "" -- and rather than fix it, an earlier pass wrote the wrong answer
	# down and moved on. A guard that asserts a bug keeps the bug: it turns the
	# next person's correct fix into a failing test.
	#
	# Fixed now, in the engine, from Unicode's own data. The branch calls
	# stz_unicode_numeric_value directly and builds no objects at all, so the
	# handle-leak point this suite exists for is stronger than before, not
	# weaker.
	Then("a circled numeral answers its VALUE", (new stzNumber("②")).NumericValue(), 2)
	Then("...and the ten of them read 0 through 9", CircledRun(), TRUE)

	# The negative sibling: the branch must not swallow things that are not
	# numerals. A letter still reaches the ordinary string paths and is refused.
	Then("a non-numeral char is still refused", RaisesNum("Z"), TRUE)

	# and the check that is NOT redundant with the decimal-form test above: ".5" is
	# decimal-form yet not calculable, so it must still be refused
	Then("a bare leading dot is still refused", RaisesNum(".5"), TRUE)
EndScenario()

Summary()

func RaisesNum(c)
	bR = FALSE
	try
		o = new stzNumber(c)
	catch
		bR = TRUE
	done
	return bR

# All ten circled digits, read back through the constructor. U+24EA is
# CIRCLED DIGIT ZERO; U+2460..U+2468 are ONE..NINE. Asserting only ② would
# pass against a branch that answered 2 for everything.
func CircledRun()
	acCircled = [ StzChar(0x24EA), StzChar(0x2460), StzChar(0x2461), StzChar(0x2462),
	              StzChar(0x2463), StzChar(0x2464), StzChar(0x2465), StzChar(0x2466),
	              StzChar(0x2467), StzChar(0x2468) ]
	for i = 1 to 10
		oN = new stzNumber(acCircled[i])
		if oN.NumericValue() != i - 1
			return FALSE
		ok
	next
	return TRUE

func Rnd6(n)
	return ceil(n * 1000000 - 0.5) / 1000000
