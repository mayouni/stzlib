# Narrative
# --------
# Student grades validation
#
# Extracted from stztablextest.ring, block #47.

load "../../stzBase.ring"


pr()

oGrades = new stzTable([
	[ :STUDENT_ID, :NAME, :MATH, :SCIENCE, :ENGLISH ],
	[ 101, "Ali", 85, 90, 88 ],
	[ 102, "Sara", 92, 87, 95 ],
	[ 103, "Omar", 78, 82, 80 ]
])

# Validate: unique IDs, all grades present, reasonable averages
oTx = new stzTablex("{cols(5) & unique(student_id) & @!nulls(name) & mincol(math:>0) & maxcol(math:<101)}")

? oTx.Match(oGrades)
#--> TRUE

pf()
# Executed in 0.23 second(s) in Ring 1.24
