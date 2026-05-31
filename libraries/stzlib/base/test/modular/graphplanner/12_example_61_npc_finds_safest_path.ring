# Narrative
# --------
# Example 6.1: NPC Finds Safest Path
#
# Extracted from stzgraphplannertest.ring, block #12.

load "../../../stzBase.ring"

  
`
  CONCEPT: Game AI needs context-aware pathfinding
  
  Open field is fast but dangerous (exposed, no cover).
  Forest route is safer (cover available, less danger).
  
  When minimizing danger, NPC takes the forest route even
  if it's longer. This creates believable AI behavior!
`

pr()

oGraph = new stzGraph("game_world")
oGraph {
	AddNodeXTT("spawn", "Spawn Point", [
		:danger = 0,
		:cover = TRUE
	])
	
	AddNodeXTT("open", "Open Field", [
		:danger = 8,    # Very dangerous!
		:cover = FALSE  # No protection
	])
	
	AddNodeXTT("forest", "Forest", [
		:danger = 3,
		:cover = TRUE
	])
	
	AddNodeXTT("river", "River Crossing", [
		:danger = 5,
		:cover = FALSE
	])
	
	AddNodeXTT("hill", "Hill", [
		:danger = 2,
		:cover = TRUE
	])
	
	AddNodeXTT("objective", "Objective Point", [
		:danger = 0,
		:cover = TRUE
	])
	
	# Direct but dangerous route
	AddEdgeXTT("spawn", "open", "direct", [:danger = 7])
	AddEdgeXTT("open", "objective", "direct", [:danger = 6])
	# Total danger: 7 + 6 = 13
	
	# Safer route through forest
	AddEdgeXTT("spawn", "forest", "safe", [:danger = 2])
	AddEdgeXTT("forest", "river", "path", [:danger = 3])
	AddEdgeXTT("river", "hill", "path", [:danger = 4])
	AddEdgeXTT("hill", "objective", "path", [:danger = 2])
	# Total danger: 2 + 3 + 4 + 2 = 11 ✓
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("safe_path")
	Walk(:From = "spawn", :To = "objective")
	Minimizing("danger")
	Execute()

	? Cost()
	#--> 11 (safer forest route, not 13 from open field)

	? @@( Route() )
	#--> [ "spawn", "forest", "river", "hill", "objective" ]
	# NPC wisely avoided the dangerous open field
}

pf()
# Executed in 0.02 second(s) in Ring 1.24

#============================================#
#  SECTION 7: REAL-WORLD SCENARIOS           #
#============================================#
