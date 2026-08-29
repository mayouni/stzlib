load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 4 of the numeric foundation, fifth slice: SPECIAL FUNCTIONS.
#
# The plan calls these "small, well-published mathematics, and the thing standing
# between us and real statistics." Section 2.6 is blunter: WITHOUT THEM, NO p-VALUE
# OR CDF IN THIS LIBRARY CAN BE CORRECT. It was not a hypothetical gap --
# `ConfidenceInterval` was labelled "t-distribution" while hardcoding three z
# values, and phase 0's repair could only make that honest, not right. Its raise
# message said so out loud: "a t-based interval for an arbitrary level needs the
# inverse incomplete beta function -- not in the engine yet."
#
# TWO CORE FUNCTIONS, EVERYTHING ELSE DERIVED. Rather than a dozen independent
# rational approximations -- which is exactly how a library ends up with two answers
# for one quantity, the disease phases 0, 3 and 4 each had to cure -- special.zig
# has two workhorses:
#
#   the regularised incomplete GAMMA  P(a,x), Q(a,x)  -> erf, erfc, normal, chi2
#   the regularised incomplete BETA   I_x(a,b)        -> Student t, F
#
# So erf is not an approximation OF erf; it IS P(1/2, x^2), and shares every digit
# of its accuracy with the chi-square CDF. Zig's std supplies lgamma; that is the
# only other ingredient.
#
# Quantiles are found by BISECTION on the CDF rather than by a separate
# approximation of each inverse. A quantile then costs ~60 CDF evaluations instead
# of ~20 flops, which is irrelevant -- a confidence interval is computed once, not
# per element -- and in exchange AN INVERSE CANNOT DISAGREE WITH THE FUNCTION IT
# INVERTS.

Scenario("the error function, against published values")
	Then("erf(0) is exactly 0", StzEngineErf(0), 0)
	Then("erf(1)", Rnd9(StzEngineErf(1)), 0.842700793)
	Then("erf(2)", Rnd9(StzEngineErf(2)), 0.995322265)
	Then("erf is odd: erf(-x) = -erf(x)",
	     Rnd9(StzEngineErf(-1.3)), Rnd9(-StzEngineErf(1.3)))
	Then("erfc(1) = 1 - erf(1)", Rnd9(StzEngineErfc(1)), 0.157299207)

	# WHY erfc EXISTS SEPARATELY, and it is not tidiness. erfc(6) is about
	# 2.15e-17, so computing it as 1 - erf(6) gives exactly 0 in a double: every
	# significant digit of the tail is lost. A p-value lives in that tail.
	Then("1 - erf(6) collapses to zero", (1 - StzEngineErf(6)) = 0, TRUE)
	Then("...while erfc(6) keeps its digits", StzEngineErfc(6) > 0, TRUE)
EndScenario()

Scenario("the normal distribution, and its inverse being its own inverse")
	Then("the CDF at 0 is a half", Rnd9(StzEngineNormalCdf(0)), 0.5)
	Then("...at 1.96", Rnd9(StzEngineNormalCdf(1.96)), 0.975002105)
	Then("...at 1", Rnd9(StzEngineNormalCdf(1)), 0.841344746)

	Then("the quantile every statistics table opens with",
	     Rnd8(StzEngineNormalQuantile(0.975)), 1.95996398)
	Then("...and the one-sided 95%", Rnd8(StzEngineNormalQuantile(0.95)), 1.64485363)

	# The round trip is the real test: because the quantile is the CDF bisected,
	# the two cannot drift apart the way two independent approximations would.
	nWorst = 0
	_aNP151_ = [ 0.001, 0.01, 0.1, 0.25, 0.5, 0.75, 0.9, 0.99, 0.999 ]
	_nNP151_ = len(_aNP151_)
	for _iNP151_ = 1 to _nNP151_
		nP = _aNP151_[_iNP151_]
		nBack = StzEngineNormalCdf(StzEngineNormalQuantile(nP))
		if fabs(nBack - nP) > nWorst
			nWorst = fabs(nBack - nP)
		ok
	next
	Then("CDF(quantile(p)) = p across nine probabilities", nWorst < 0.000000001, TRUE)
EndScenario()

Scenario("Student t -- the distribution the confidence interval was missing")
	# THE CASE FROM THE DEFECT. n = 5 is 4 degrees of freedom, and the two-sided
	# 95% critical value is 2.776, not the 1.96 that was hardcoded.
	Then("t(0.975, 4 df)", Rnd8(StzEngineTQuantile(0.975, 4)), 2.77644511)
	Then("t(0.975, 1 df) -- the fattest tail", Rnd6(StzEngineTQuantile(0.975, 1)), 12.706205)
	Then("t(0.975, 9 df)", Rnd8(StzEngineTQuantile(0.975, 9)), 2.26215716)
	Then("t(0.975, 30 df)", Rnd8(StzEngineTQuantile(0.975, 30)), 2.04227246)

	Then("...which is 41% wider than z, exactly as phase 0's warning said",
	     Rnd4(StzEngineTQuantile(0.975, 4) / StzEngineNormalQuantile(0.975)), 1.4166)

	# t converges on the normal as df grows. My first attempt asserted "equal to
	# six decimals at df = 100000", which FAILED -- and correctly: t is still
	# 2.37e-5 wider there. Measuring the gap instead gave something far better than
	# a tolerance:
	#
	#     df       t(0.975, df)     t - z
	#     100      1.9839715185     2.40e-2
	#     1000     1.9623390808     2.38e-3
	#     10000    1.9602012399     2.37e-4
	#     100000   1.9599877075     2.37e-5
	#     1000000  1.9599663566     2.37e-6
	#
	# Ten times the degrees of freedom, one tenth the gap: the convergence is
	# O(1/df), exactly as the theory says. THAT is the assertion worth making --
	# a rate is a mathematical property, and no amount of approximation error could
	# fake it, whereas any loose tolerance can be satisfied by accident.
	nZ = StzEngineNormalQuantile(0.975)
	nGap1 = StzEngineTQuantile(0.975, 1000) - nZ
	nGap2 = StzEngineTQuantile(0.975, 10000) - nZ
	nGap3 = StzEngineTQuantile(0.975, 100000) - nZ
	Then("t approaches z from ABOVE -- it is always the wider one",
	     nGap1 > 0 and nGap2 > 0 and nGap3 > 0, TRUE)
	# within 1%, not exactly ten: the leading term is 1/df but there are
	# higher-order ones, so the measured ratio is 10.01 rather than 10.00. Pinning
	# it to the exact decimal would be asserting something untrue about the
	# mathematics in order to make a test look tidy.
	Then("...and ten times the df closes the gap ten-fold, to within 1%",
	     nGap1 / nGap2 > 9.9 and nGap1 / nGap2 < 10.1, TRUE)
	Then("...again at the next decade",
	     nGap2 / nGap3 > 9.9 and nGap2 / nGap3 < 10.1, TRUE)
	Then("the CDF is symmetric: F(t) + F(-t) = 1",
	     Rnd9(StzEngineTCdf(1.3, 7) + StzEngineTCdf(-1.3, 7)), 1)
EndScenario()

Scenario("chi-square and F, and the identities that check them")
	Then("chi2(0.95, 1 df)", Rnd8(StzEngineChi2Quantile(0.95, 1)), 3.84145882)
	Then("chi2(0.95, 2 df)", Rnd8(StzEngineChi2Quantile(0.95, 2)), 5.99146455)
	Then("F(0.95; 3, 10)", Rnd6(StzEngineFQuantile(0.95, 3, 10)), 3.708265)

	# AN IDENTITY IS A STRONGER TEST THAN A TRANSCRIBED CONSTANT, and this slice
	# proved it the hard way: the F constant above was first typed as
	# 3.7082648979167185 instead of 3.708264819046839 -- wrong at the ninth digit --
	# and the test failed against correct code. A mistyped reference value looks
	# exactly like a broken implementation. An identity cannot be mistyped into
	# agreement.
	#
	# An F with 1 and v degrees of freedom is a squared t with v, reached through
	# the incomplete beta with entirely different parameters.
	nT = StzEngineTQuantile(0.975, 10)
	Then("F(0.95; 1, 10) = t(0.975; 10) squared",
	     Rnd8(StzEngineFQuantile(0.95, 1, 10)), Rnd8(nT * nT))

	# A chi-square with 1 df is a squared standard normal, so
	# chi2cdf(x,1) = 2*normalCdf(sqrt(x)) - 1
	Then("chi2 with 1 df is a squared normal",
	     Rnd9(StzEngineChi2Cdf(2.5, 1)), Rnd9(2 * StzEngineNormalCdf(sqrt(2.5)) - 1))

	# P + Q = 1 for the incomplete gamma, and the beta symmetry
	Then("P(a,x) + Q(a,x) = 1",
	     Rnd9(StzEngineGammaP(3, 5) + StzEngineGammaQ(3, 5)), 1)
	Then("I_x(a,b) = 1 - I_(1-x)(b,a)",
	     Rnd9(StzEngineBetaI(2, 3, 0.4) + StzEngineBetaI(3, 2, 0.6)), 1)
	Then("I_x(1,1) = x, the uniform case", Rnd9(StzEngineBetaI(1, 1, 0.37)), 0.37)
	Then("P(1,x) = 1 - exp(-x), the exponential",
	     Rnd9(StzEngineGammaP(1, 2.5)), Rnd9(1 - exp(-2.5)))
EndScenario()

Scenario("what this bought: the confidence interval is now a t interval")
	# The whole point of the slice. stzDataSet's own guard covers the behaviour in
	# detail; this records the arithmetic that closed the defect.
	oData = new stzDataSet([ 12, 15, 11, 14, 13 ])      # n = 5
	aXT = oData.ConfidenceIntervalXT(95)
	Then("the method reports itself as t", aXT[:method], :t)
	Then("...with 4 degrees of freedom", aXT[:df], 4)
	Then("...and the t critical value", Rnd6(aXT[:critical]), 2.776445)

	# ANY level, which the eight-row table could not do
	Then("97% is computable now", Rnd6(StzNormalCriticalValue(97)), 2.170090)
	Then("...and so is 42%", Rnd6(StzNormalCriticalValue(42)), 0.553385)
	Then("...and the t version of an odd level",
	     Rnd6(StzTCriticalValue(97, 4)), 3.297630)

	Given("a level that is not a level")
	Then("0 raises", RaisesLevel(0), TRUE)
	Then("100 raises", RaisesLevel(100), TRUE)
	Then("140 raises", RaisesLevel(140), TRUE)
EndScenario()

Summary()

func RaisesLevel(n)
	bR = FALSE
	try
		nIgnored = StzNormalCriticalValue(n)
	catch
		bR = TRUE
	done
	return bR

func Rnd2(n)
	return ceil(n * 100 - 0.5) / 100

func Rnd4(n)
	return ceil(n * 10000 - 0.5) / 10000
func Rnd6(n)
	return ceil(n * 1000000 - 0.5) / 1000000
func Rnd8(n)
	return ceil(n * 100000000 - 0.5) / 100000000
func Rnd9(n)
	return ceil(n * 1000000000 - 0.5) / 1000000000
