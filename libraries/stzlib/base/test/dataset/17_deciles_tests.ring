# Narrative
# --------
# Deciles Tests
#
# Extracted from stzdatasettest.ring, block #17.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

# Deciles divide data into ten parts for finer distribution analysis.

pr()

o1 = new stzDataSet([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ])
o1 {
    ? @@(Deciles()) # (10th to 90th percentiles)
	#--> [
	# 	1.9000, 2.8000, 3.7000, 4.6000, 5.5000, 6.4000,
	# 	7.3000, 8.2000, 9.1000
	# ]

    ? @@(Quartiles()) # (for comparison)
	#--> [3.25, 5.5, 7.75]
}

pf()
# Executed in 0.0010 second(s) in Ring 1.24
# Executed in 0.0020 second(s) in Ring 1.22
