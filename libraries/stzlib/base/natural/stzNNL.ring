#---------------------------------------------------------------------------#
#  stzNNL -- Near-Natural Language 2.0: the renovated device layer           #
#                                                                            #
#  See doc/design/NNL_REVIEW.md. This file holds the GLOBAL side of the      #
#  NNL devices: the expectation register (the anaphoric-ellipsis context     #
#  generalized with COMPARATIVE MODES) and the accountability register       #
#  (WhyB -- every B-comparison explains itself). The chainable devices       #
#  live on stzObject (marked NNL sections at the end of stzObject.ring);     #
#  the noun surface (VowelN/VowelNB/...) is GENERATED there from the         #
#  semantic lexicon.                                                         #
#---------------------------------------------------------------------------#

# THE EXPECTATION REGISTER -- the discourse context of NNL:
#   "has a length of 4 ... and ONLY 1 vowel"       -> :Exactly
#   "with AT LEAST 2 vowels"                       -> :AtLeast
#   "containing ABOUT 100 items"                   -> :About (vagueness!)
#   "with BETWEEN 3 and 5 words"                   -> :Between
# SetLastValue() (stzNaturalCode) stores WHAT is expected; the mode says
# HOW to compare. Every *NB()/*B() device compares through the register
# and records its explanation in $cStzLastWhyB.

$cStzExpectMode = :Exactly
$nStzExpectTol = 0
$cStzLastWhyB = ""

func ExpectExactly(n)
	SetLastValue(n)
	$cStzExpectMode = :Exactly

func ExpectAtLeast(n)
	SetLastValue(n)
	$cStzExpectMode = :AtLeast

func ExpectAtMost(n)
	SetLastValue(n)
	$cStzExpectMode = :AtMost

func ExpectMoreThan(n)
	SetLastValue(n)
	$cStzExpectMode = :MoreThan

func ExpectLessThan(n)
	SetLastValue(n)
	$cStzExpectMode = :LessThan

func ExpectAbout(n)
	ExpectAboutXT(n, 0.1)

func ExpectAboutXT(n, nTolerance)
	SetLastValue(n)
	$cStzExpectMode = :About
	$nStzExpectTol = nTolerance

func ExpectBetween(n1, n2)
	SetLastValue([ n1, n2 ])
	$cStzExpectMode = :Between

# THE ACCOUNTABILITY SURFACE -- two scopes, two names (the archived
# WhyChainStopped precedent: explanations live ON the chain):
#
#   CHAIN-LOCAL (the real device): o.WhyAnswered() -- the reason of the
#   last check THIS object answered; oFalse.WhyStopped() -- why the chain
#   stopped at a false premise. Two interleaved chains never lie to each
#   other. A live object answers WhyStopped() with "the chain is not
#   stopped", exactly like the archive.
#
#   DETACHED (console/test convenience): Why() -- the last check anywhere
#   in the session, read from the process register. Handy right after a
#   `? o.SomethingNB()` line; NOT reliable across interleaved chains --
#   use the chain-local forms in real code.
# NAMING: never WhyB -- the B suffix is RESERVED by the NNL grammar for
# boolean-returning devices; Why* is the explanation family.

func Why()
	return $cStzLastWhyB

	func @Why()
		return $cStzLastWhyB
