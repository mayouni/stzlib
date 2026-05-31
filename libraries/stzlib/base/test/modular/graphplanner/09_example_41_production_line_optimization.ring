# Narrative
# --------
# Example 4.1: Production Line Optimization
#
# Extracted from stzgraphplannertest.ring, block #9.

load "../../../stzBase.ring"


`
  CONCEPT: Manufacturing often has optional steps
  
  Standard process: raw -> cut -> shape -> polish -> assemble -> finished
  Fast process: raw -> cut -> shape -> assemble -> finished (skip polish!)
  
  The planner will discover that skipping polish saves time.
`

pr()

oGraph = new stzGraph("production_line")
oGraph {
	AddNodeXTT("raw", "Raw Materials", [
		:inventory = 1000,
		:ready = TRUE
	])
	
	AddNodeXTT("cut", "Cutting Station", [
		:inventory = 0,
		:ready = FALSE
	])
	
	AddNodeXTT("shape", "Shaping Station", [
		:inventory = 0,
		:ready = FALSE
	])
	
	AddNodeXTT("polish", "Polishing Station", [
		:inventory = 0,
		:ready = FALSE
	])
	
	AddNodeXTT("assemble", "Assembly Station", [
		:inventory = 0,
		:ready = FALSE
	])
	
	AddNodeXTT("finished", "Finished Goods", [
		:inventory = 0,
		:ready = FALSE
	])
	
	# Standard workflow with all steps
	AddEdgeXTT("raw", "cut", "process", [
		:time = 10,
		:workers = 2
	])
	
	AddEdgeXTT("cut", "shape", "process", [
		:time = 15,
		:workers = 3
	])
	
	AddEdgeXTT("shape", "polish", "process", [
		:time = 8,
		:workers = 1
	])
	
	AddEdgeXTT("polish", "assemble", "process", [
		:time = 20,
		:workers = 4
	])
	
	AddEdgeXTT("assemble", "finished", "process", [
		:time = 5,
		:workers = 2
	])
	
	# Alternative: skip polishing for rough finish
	AddEdgeXTT("shape", "assemble", "skip_polish", [
		:time = 2,  # Much faster!
		:workers = 1
	])
}

oPlanner = new stzGraphPlanner(oGraph)
oPlanner {
	AddPlan("prod_optim")

	Walk(:FromNode = "raw", :ToNode = "finished")
	Minimizing("time")
	Execute()

	? Cost()
	#--> 32 (skipped polishing!)
	# Breakdown: 10(cut) + 15(shape) + 2(skip_polish) + 5(finish) = 32
	# vs. standard: 10 + 15 + 8 + 20 + 5 = 58
	
	? @@( Route() )
	#--> [ "raw", "cut", "shape", "assemble", "finished" ]
	# No "polish" in the path
}

pf()
# Executed in 0.01 second(s) in Ring 1.24
