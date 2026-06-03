# Narrative
# --------
# Select DISTINCT
#
# Extracted from stzgraphquerytest.ring, block #15.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:dept = "Engineering"])
	AddNodeXTT("bob", "Employee", [:dept = "Sales"])
	AddNodeXTT("carol", "Employee", [:dept = "Engineering"])
}

aResults = StzGraphQueryQ(oGraph).
	MatchQ([:node = "n"]).
	DistinctQ().
	Select("n.dept")

? len(aResults)
#--> 2

pf()
# Executed in 0.01 second(s) in Ring 1.25

#---------------------#
#  ORDERING & LIMITS  #
#---------------------#
