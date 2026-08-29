load "../../stzBase.ring"
load "../_narrated.ring"

# "CALCULABLE" WAS A GOOD IDEA WHOSE PREMISE EXPIRED.
#
# Before the Zig engine, every number in Softanza was a Ring double. A double holds
# integers exactly only up to 2^53; past that, n and n+1 can be the same value. So a
# 16-digit integer arriving as text was a real hazard -- it would be accepted, then
# silently lose its low digits -- and a check that refused it up front was genuinely
# protective. That check was RepresentsCalculableNumber(), and the bound behind it was
#
#     _cMaxCalculableInteger = "999_999_999_999_999"
#
# fifteen nines: a deliberately safe under-estimate of 2^53, picked so that EVERY
# 15-digit integer clears it.
#
# THE ENGINE CHANGED WHAT IS TRUE. stzNumber stores a STRING and dispatches to big
# integers, exact scaled decimals, rationals, or f64 only where the operation is
# inherently approximate. A twenty-digit integer is now held and added exactly. So the
# premise -- "beyond this magnitude we lose digits" -- is simply false today, and the
# first scenario below measures that rather than asserting it.
#
# THE CONCEPT WAS ALSO ALREADY HOLLOW, which is the part that took reading to find.
# All three predicates that carried the name had been reduced to their plain twins:
#
#     RepresentsCalculableNumber()     ->  RepresentsNumber()
#     RepresentsCalculableInteger()    ->  RepresentsInteger()
#     RepresentsCalculableRealNumber() ->  RepresentsRealNumber()
#
# and NOTHING anywhere enforced the bound. It survived in exactly two places, both of
# them error messages telling the user to respect a limit no code checked. One of those
# was worse than useless: :CanNotCreateDecimalNumber2 said "the number you provided is
# not calculable -- provide a number between MinCalculableNumber() and
# MaxCalculableNumber()", but it fires for a MALFORMED LITERAL like ".5". A user with a
# typo was told to make their number smaller. That is a wrong diagnosis, not a vague
# one, and it is corrected now.
#
# WHAT REPLACED IT. Phases 1-2 built the vocabulary this question actually wanted:
# IsExact(), WhyNotExact(), Representation(). "Is it calculable?" was the pre-engine
# ancestor of "is it exact, and if not, why?" -- a better question, because exactness is
# a property of the OPERATION, not of the magnitude. 0.1 is small and inexact under
# f64; a 40-digit integer is enormous and exact. Magnitude never was the right axis.
#
# WHAT REMAINS TRUE is the fact about RING ITSELF, and it is worth keeping because a
# caller handing a value to bare Ring arithmetic still needs it. That fact now has an
# honest name -- RingMaxExactInteger() -- and, for the first time, its true value.
# MaxCalculableNumber() used to answer 999999999999999, which was wrong under BOTH
# readings of its name: Softanza is not bounded at all, and Ring's own limit is 2^53,
# nine times larger. It answers 2^53 now.

Scenario("the premise: Ring's double really does stop being exact at 2^53")
	# Not a transcribed constant -- ask Ring to demonstrate its own limit.
	n = pow(2, 53)
	Then("2^53 and 2^53+1 are the SAME value to Ring", n = n + 1, TRUE)
	Then("...while 2^53-1 is still distinct", n - 1 = n, FALSE)
	Then("...so 2^53 is exactly where it breaks", RingMaxExactInteger(), n)
	Then("...and the minimum is its negation", RingMinExactInteger(), -n)

	# fifteen digits is what the old bound guaranteed, and that part was sound:
	# 10^15 < 2^53, so every 15-digit integer is exact; 16 digits is not guaranteed.
	Then("every 15-digit integer clears it", pow(10,15) < n, TRUE)
	Then("...but 16 digits is not guaranteed", pow(10,16) < n, FALSE)
	Then("...which is what MaxNumberOfDigitsInUnsignedInteger still reports",
	     MaxNumberOfDigitsInUnsignedInteger(), 15)
EndScenario()

Scenario("the name now tells the truth")
	# It used to answer 999999999999999 -- smaller than Ring's real limit by 9x.
	Then("MaxCalculableNumber is Ring's actual exact limit",
	     MaxCalculableNumber(), RingMaxExactInteger())
	Then("...and it is NOT the old fifteen-nines bound",
	     MaxCalculableNumber() = 999999999999999, FALSE)
	Then("...nine times larger, in fact", MaxCalculableNumber() > 999999999999999 * 9, TRUE)
	Then("RingMaxNumber, the alias that always implied this, agrees",
	     RingMaxNumber(), RingMaxExactInteger())
	Then("...as do the other seven aliases", LargestNumberInRing(), RingMaxExactInteger())
	Then("the minimum is the negation", MinCalculableNumber(), -RingMaxExactInteger())
	Then("...and RingMinNumber agrees", RingMinNumber(), MinCalculableNumber())

	# the readable twin carries separators; the numeric one must not, because
	# `0 + "9_007_199_254_740_992"` answers 9 in Ring -- it stops at the first non-digit
	# compared as a NUMBER, not as text: `"" + n` renders through Ring's global
	# decimals() display mode, so the string form of an integer picks up ".00"
	Then("the XT form is the same number, separated",
	     0 + StzReplace(MaxCalculableNumberXT(), "_", ""), RingMaxExactInteger())
	Then("...and the XT minimum tracks it rather than an old constant",
	     MinCalculableNumberXT(), "-" + MaxCalculableNumberXT())
EndScenario()

Scenario("the premise is FALSE for Softanza: twenty digits, held exactly")
	c20 = "99999999999999999999"
	Then("...and it is well past the limit", len(c20) > 16, TRUE)

	o = new stzNumber(c20)
	Then("the string survives intact", o.Content(), c20)
	Then("IsExact says so", o.IsExact(), TRUE)
	Then("...because it is a big integer, not a double", o.Representation(), "biginteger")

	o.Add("1")
	Then("and it CALCULATES exactly -- a double would answer 1e20",
	     o.Content(), "100000000000000000000")

	# the same value through Ring's double, for contrast: the tail is gone
	Then("...whereas Ring's own arithmetic loses the tail",
	     ("" + (0 + c20)) = "100000000000000000000", FALSE)
EndScenario()

Scenario("so 'calculable' is exactly 'well-formed', and nothing more")
	# All three predicates ARE their plain twins. Pinned as identities, so if anyone
	# ever gives them independent behaviour again this fails loudly.
	_aC137_ = [ "42", "-42", "4.2", "0.1", "99999999999999999999", ".5", "12.", "abc", "", "1_000" ]
	_nC137_ = len(_aC137_)
	for _iC137_ = 1 to _nC137_
		c = _aC137_[_iC137_]
		Then("calculable = number, for '" + c + "'",
		     StzStringQ(c).RepresentsCalculableNumber(),
		     StzStringQ(c).RepresentsNumber())
		Then("calculable-integer = integer, for '" + c + "'",
		     StzStringQ(c).RepresentsCalculableInteger(),
		     StzStringQ(c).RepresentsInteger())
		Then("calculable-real = real, for '" + c + "'",
		     StzStringQ(c).RepresentsCalculableRealNumber(),
		     StzStringQ(c).RepresentsRealNumber())
	next

	# and the magnitude has no say at all: the biggest thing here passes, the typo fails
	Then("a twenty-digit integer is 'calculable'",
	     StringRepresentsCalculableNumber("99999999999999999999"), TRUE)
	Then("...while '.5' is not", StringRepresentsCalculableNumber(".5"), FALSE)
	Then("...which is a WELL-FORMEDNESS verdict, not a size one",
	     StringRepresentsNumberInDecimalForm(".5"), TRUE)
EndScenario()

Scenario("the error message that gave a wrong diagnosis")
	# ".5" raises. It always did, and it should -- but the user used to be told the
	# number was "not calculable" and asked to pick one between MinCalculableNumber()
	# and MaxCalculableNumber(). The problem is the missing leading zero.
	Then("'.5' is still refused", RaisesNum(".5"), TRUE)
	Then("...and '0.5' is not", RaisesNum("0.5"), FALSE)
	Then("...and reads back correctly", (new stzNumber("0.5")).NumericValue(), 0.5)

	# the size story, stated once more where it belongs: nothing is refused for BEING
	# BIG. That is the whole content of the retirement.
	Then("a 40-digit integer is accepted",
	     RaisesNum("1234567890123456789012345678901234567890"), FALSE)
	Then("...and kept whole",
	     (new stzNumber("1234567890123456789012345678901234567890")).Content(),
	     "1234567890123456789012345678901234567890")
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
