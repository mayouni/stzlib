# Narrative
# --------
# Using SubMean()
#
# Extracted from stzmatrixtest.ring, block #24.

load "../../stzBase.ring"


pr()

# Consider a matrix of students' test scores

o1 = new stzMatrix([
	[ 80, 85, 90 ],
	[ 70, 75, 80 ],
	[ 60, 65, 70 ]
])

# Scores Adjusted by Row Mean

o1.SubMean() # Or SubtractMean()

o1.Show()
#-->
# ┌        ┐
# │ -5 0 5 │
# │ -5 0 5 │
# │ -5 0 5 │
# └        ┘

#~> This centers the scores around 0 for each student group.

pf()
# Executed in 0.02 second(s) in Ring 1.22
