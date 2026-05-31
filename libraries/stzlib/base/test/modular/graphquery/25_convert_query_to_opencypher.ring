# Narrative
# --------
# Convert query to OpenCypher
#
# Extracted from stzgraphquerytest.ring, block #25.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("test")

cCypher = StzGraphQueryQ(oGraph).
	MatchQ([:node = "n", :labeled = "Person"]).
	WhereQ([:age, ">", 25]).
	OrderByQ("n.age", "ASC").
	LimitQ(10).
	ToOpenCypher()

? cCypher
# Output:
# MATCH (n:Person)
# WHERE n.age > 25
# ORDER BY n.age ASC
# LIMIT 10

pf()
# Executed in almost 0 second(s) in Ring 1.25

#-----------------------------------#
#  THREE STYLES OF USING THE CLASS  #
#-----------------------------------#
