# Narrative
# --------
# Quartiles and Percentiles
#
# Extracted from stzdatasettest.ring, block #12.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

# Quartiles divide data into four parts; percentiles give specific percentage points.

pr()

o1 = new stzDataSet([ 1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 ])
o1 {
    ? Q1()
    #--> 12.5 (first quartile)

    ? Q2()
    #--> 25 (second quartile, median)

    ? Q3()
    #--> 37.5 (third quartile)

    ? IQR()
    #--> 25 (interquartile range, Q3 - Q1)

    ? @@(Quartiles())
    #--> [12.5, 25, 37.5] (using interpolation)

    ? @@(QuartilesXT(:Nearest))
    #--> [10, 25, 40] (using nearest value)

    ? Percentile(90)
    #--> 45 (90th percentile)
}

pf()
# Executed in 0.0020 second(s) in Ring 1.24
