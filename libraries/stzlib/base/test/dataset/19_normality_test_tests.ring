# Narrative
# --------
# Normality Test Tests
#
# Extracted from stzdatasettest.ring, block #19.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

# Checks if data follows a normal distribution using skewness and kurtosis.

pr()

o1 = new stzDataSet([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ])
o1 {
    aTest = NormalityTest()
    ? @@NL(aTest)
    #--> [
	# 	[ "test", "heuristic" ],
	# 	[ "skewness", 0 ],
	# 	[ "kurtosis", -4.0254 ],
	# 	[ "p_value", 0.0179 ],
	# 	[ "is_normal", 0 ]
	# ]
}

o1 = new stzDataSet([ 1, 1, 1, 2, 2, 3, 8, 9, 9, 9 ])
o1 {
    ? @@NL( NormalityTest() )
	#--> [
	# 	[ "test", "heuristic" ],
	# 	[ "skewness", 0.0413 ],
	# 	[ "kurtosis", -4.1210 ],
	# 	[ "p_value", 0.0162 ],
	# 	[ "is_normal", 0 ]
	# ]
}

pf()
# Executed in 0.0040 second(s) in Ring 1.24
# Executed in 0.0060 second(s) in Ring 1.22

#======================================================================#
#  PILLAR 4: RELATION - Correlation & Association Analysis             #
#======================================================================#

# This pillar explores relationships between variables.
