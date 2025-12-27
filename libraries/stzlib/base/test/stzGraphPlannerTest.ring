load "../stzbase.ring"

#---------------------------#
#  EXAMPLE USAGE            #
#---------------------------#

/*--- Example 1: Simple Pathfinding

pr()

oGraph = new stzGraph("warehouse")
oGraph {
	AddNodeXTT("entrance", "Entrance", [:x = 0, :y = 0])
	AddNodeXTT("aisle_a", "Aisle A", [:x = 10, :y = 0])
	AddNodeXTT("shelf_5", "Shelf 5", [:x = 10, :y = 20])
	
	AddEdgeXTT("entrance", "aisle_a", '', [:distance = 10, :traffic = "low"])
	AddEdgeXTT("aisle_a", "shelf_5", '', [:distance = 20, :traffic = "high"])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlan = oPlanner.Plan()
	.StartingFrom("entrance")
	.To_("shelf_5")
	.Minimizing("distance")
	.Execute()

? oPlan.Cost() + NL
#--> 30

? oPlan.Explain()
#-->
# Step 1: entrance -> aisle_a (cost: 10)
# Step 2: aisle_a -> shelf_5 (cost: 20)

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*--- Example 2: Goal-Based Planning
*/
pr()

oGame = new stzGraph("rpg_world")
oGame {
	AddNodeXTT("village", "Village", [:gold = 0, :hasKey = FALSE])
	AddNodeXTT("forest", "Forest", [:gold = 500, :hasKey = FALSE])
	AddNodeXTT("dungeon", "Dungeon", [:gold = 1000, :hasKey = TRUE])
	
	AddEdgeXTT("village", "forest", "travel", [:danger = 2])
	AddEdgeXTT("forest", "dungeon", "travel", [:danger = 5])
}

oPlanner = new stzGraphPlanner(oGame)
oPlan = oPlanner.Plan()
	.StartingFrom("village")
	.ToReach(func(node) {
		return node[:properties][:gold] >= 1000 and 
		       node[:properties][:hasKey] = TRUE
	})
	.Minimizing("danger")
	.Execute()

? "Quest chain:"
oPlan.Show()
#-->
'
Quest chain:
Plan:
  Total Cost: 7
  Steps: 2

Actions:
  village -> forest
    Cost: 2
  forest -> dungeon
    Cost: 5

Explanation:
Step 1: village -> forest (cost: 2)
Step 2: forest -> dungeon (cost: 5)
'

pf()
# Executed in 0.01 second(s) in Ring 1.24
