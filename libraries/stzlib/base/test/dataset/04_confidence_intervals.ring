# Narrative
# --------
# Confidence Intervals
#
# Extracted from stzdatasettest.ring, block #4.

load "../../stzBase.ring"

# Confidence intervals estimate the range where the true population mean lies,
# with a specified confidence level (e.g., 95%).
#
# NOTE: this is the STUDENT t interval, with n - 1 degrees of freedom.
#
# The note here used to say "the NORMAL (z) approximation, and it now says so"
# and the expectations below were the z values -- [ 16.14, 43.86 ] at 95%.
# Numeric foundation phase 4 gave the engine an inverse incomplete beta, so a t
# critical value could finally be computed and ConfidenceInterval() moved to it.
# The note and the numbers stayed behind, so the file went on asserting the
# approximation the library had stopped making.
#
# The difference is not cosmetic: at n = 5 the z interval is 41% too narrow.
# t(0.975, 4) is 2.776 where z is 1.960, and the interval widens accordingly.
# t needs no threshold and no warning -- it converges on z as df grows.
#
# An untabulated level still RAISES rather than silently returning the 95%
# interval, and ConfidenceIntervalXT() reports :method and :critical, which is
# how the switch above is checkable rather than merely claimed.
# See SOFTANZA_NUMERIC_FOUNDATION.md.

pr()

o1 = new stzDataSet([ 10, 20, 30, 40, 50 ])
o1 {
    ? @@(ConfidenceInterval(95)) #--> [ 10.37, 49.63 ] (95% confidence range)
    ? @@(ConfidenceInterval(90)) #--> [ 14.93, 45.07 ] (90% confidence range)
    ? @@(ConfidenceInterval(99)) #--> [ -2.56, 62.56 ] (99% confidence range)
    ? @@(ConfidenceInterval(80)) #--> [ 19.16, 40.84 ] (80% -- used to return the 95% one)
}

pf()
# Executed in 0.0020 second(s) in Ring 1.24
