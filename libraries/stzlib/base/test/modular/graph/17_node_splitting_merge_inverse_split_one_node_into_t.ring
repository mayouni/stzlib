# Narrative
# --------
# Node Splitting (merge inverse: split one node into two with property division)
#
# Extracted from stzgraphtest.ring, block #17.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("SplitTest")
oGraph {
	AddNodeXTT("combined", "Combined", [:tasks = ["t1", "t2"], :priority = 10])
	AddNodeXT("dependent", "Dependent")
	Connect("combined", "dependent")

	# Split into two nodes, dividing properties
	SplitNode("combined", "part1", "part2")
	SetNodeProperty("part1", :tasks, ["t1"])
	SetNodeProperty("part2", :tasks, ["t2"])

	? NodeCount()  #--> 3
	? EdgeExists("part1", "dependent")  #--> TRUE  # Edges duplicated
	? EdgeExists("part2", "dependent")  #--> TRUE
}
pf()
# Executed in 0.01 second(s) in Ring 1.24

#============================================#
#  SECTION 3: PROPERTY & TAG QUERIES
#============================================#

# ONE PATTERN - NO CONFUSION
# Find(what).Where(key, op, val)
# Find(what).Having(key, val)
# Find(what).WithProperty(key)
# Find(what).WithTag(tag)
