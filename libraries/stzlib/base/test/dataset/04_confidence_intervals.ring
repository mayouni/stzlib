# Narrative
# --------
# Confidence Intervals
#
# Extracted from stzdatasettest.ring, block #4.

load "../../stzBase.ring"

# Confidence intervals estimate the range where the true population mean lies,
# with a specified confidence level (e.g., 95%).
#
# NOTE (2026-07-25): this is the NORMAL (z) approximation, and it now says so --
# it was previously mislabelled "t-distribution". The critical values are also
# full precision now (1.959964 rather than 1.96), which moves the 99% lower bound
# from 11.78 to 11.79. And an untabulated level RAISES instead of silently
# returning the 95% interval; ConfidenceIntervalXT() reports the method and warns
# that n=5 is too small for a z interval. See SOFTANZA_NUMERIC_FOUNDATION.md.

pr()

o1 = new stzDataSet([ 10, 20, 30, 40, 50 ])
o1 {
    ? @@(ConfidenceInterval(95)) #--> [ 16.14, 43.86 ] (95% confidence range)
    ? @@(ConfidenceInterval(90)) #--> [ 18.37, 41.63 ] (90% confidence range)
    ? @@(ConfidenceInterval(99)) #--> [ 11.79, 48.21 ] (99% confidence range)
    ? @@(ConfidenceInterval(80)) #--> [ 20.94, 39.06 ] (80% -- used to return the 95% one)
}

pf()
# Executed in 0.0020 second(s) in Ring 1.24
