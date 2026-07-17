# Narrative
# --------
# Box Plot Statistics Tests
#
# Extracted from stzdatasettest.ring, block #18.

load "../../stzBase.ring"

# Summarizes data for box plot visualization (quartiles, whiskers, outliers).

pr()

o1 = new stzDataSet([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20 ])

o1 {
    ? @@NL(BoxPlotStats())
	#--> [
	# 	[ "min", 1 ],
	# 	[ "q1", 3.7500 ],
	# 	[ "median", 6.5000 ],
	# 	[ "q3", 9.2500 ],
	# 	[ "max", 20 ],
	# 	[ "whisker_low", 1 ],
	# 	[ "whisker_high", 15 ],
	# 	[ "iqr", 5.5000 ]
	# ]

    ? @@(Outliers()) # (beyond 1.5*IQR)
	#--> [20]
}

pf()
# Executed in 0.0020 second(s) in Ring 1.24
# Executed in 0.0050 second(s) in Ring 1.22
