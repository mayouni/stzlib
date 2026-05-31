# Narrative
# --------
# Core Descriptive Statistics
#
# Extracted from stzdatasettest.ring, block #1.

load "../../../stzBase.ring"

#NOTE: These functions provide basic summaries like mean (average), median (middle value),
# mode (most frequent value), and measures of spread like standard deviation and variance.

pr()

o1 = new stzDataSet([ 10, 15, 20, 25, 30, 35, 40 ])
o1 {
    ? Mean()            #--> 25 (arithmetic average)
    ? Median()          #--> 25 (middle value after sorting)
    ? @@(Mode())        #--> "10" (first value; no repeated values here)
    ? StandardDeviation() #--> 10.8012 (measure of data spread)
    ? Variance()        #--> 116.6667 (square of standard deviation)
    ? Range()           #--> 30 (max - min)
    ? Sum()             #--> 175 (total of all values)
    ? Min()             #--> 10 (smallest value)
    ? Max()             #--> 40 (largest value)
    ? Count()           #--> 7 (number of values)
    ? UniqueCount()     #--> 7 (number of distinct values)
}
pf()
# Executed in 0.0040 second(s) in Ring 1.24
