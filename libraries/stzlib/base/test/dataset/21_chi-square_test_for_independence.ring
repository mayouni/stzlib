# Narrative
# --------
# Chi-Square Test for Independence
#
# Extracted from stzdatasettest.ring, block #21.

load "../../stzBase.ring"

# Tests association between two categorical variables.

pr()
aGender = [ " Male", "Female", "Male", "Female", "Male", "Female", "Male", "Female", "Male", "Female " ]
aPreference = [ " Like", "Like", "Dislike", "Dislike", "Like", "Like", "Dislike", "Like", "Dislike", "Like " ]

oGend = new stzDataSet(aGender)
oPref = new stzDataSet(aPreference)

? oGend.ChiSquareWith(oPref) 		#--> 22.5000 (chi-square statistic)
? @@NL(oGend.CompareWith(oPref)) 	#--> [ "Similar diversity levels" ]

pf()
# Executed in 0.0020 second(s) in Ring 1.24
# Executed in 0.0030 second(s) in Ring 1.22
