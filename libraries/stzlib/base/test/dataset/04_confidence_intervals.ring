# Narrative
# --------
# Confidence Intervals
#
# Extracted from stzdatasettest.ring, block #4.

load "../../stzBase.ring"

# Confidence intervals estimate the range where the true population mean lies,
# with a specified confidence level (e.g., 95%).

pr()

o1 = new stzDataSet([ 10, 20, 30, 40, 50 ])
o1 {
    ? @@(ConfidenceInterval(95)) #--> [ 16.1407, 43.8593 ] (95% confidence range)
    ? @@(ConfidenceInterval(90)) #--> [ 18.3681, 41.6319 ] (90% confidence range)
    ? @@(ConfidenceInterval(99)) #--> [ 11.7849, 48.2151 ] (99% confidence range)
}

pf()
# Executed in 0.0020 second(s) in Ring 1.24
