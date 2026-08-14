# Narrative
# --------
# Outlier Detection and Z-Scores
#
# Extracted from stzdatasettest.ring, block #14.

load "../../stzBase.ring"

# Outliers are extreme values; Z-scores show how many standard deviations from mean.

pr()

o1 = new stzDataSet([ 10, 12, 13, 15, 18, 20, 22, 25, 100 ])
o1 {
    ? @@(Outliers())      #--> [100] (beyond 1.5*IQR from quartiles)
    ? IsOutlier(100)      #--> TRUE
    ? IsOutlier(15)       #--> FALSE
    # WRITTEN OUT, not elided. "[-0.5725, ..., 2.6258]" cannot be checked
    # against anything -- the ellipsis is where the assertion would have
    # been. The nine values are the nine observations, standardized.
    ? @@(ZScores())       #--> [ -0.57, -0.50, -0.47, -0.39, -0.29, -0.22, -0.15, -0.04, 2.63 ]
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22
