# Narrative
# --------
# pr()
#
# Extracted from stzgraphtest.ring, block #18.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

oGraph = new stzGraph("UnifiedTest")
oGraph {
	AddNodeXTT("n1", "Server1", [
		:config = [:memory = 1024, :cpu = 4],
		:status = "active",
		:tags = ["prod", "web"]
	])
	AddNodeXTT("n2", "Server2", [
		:config = [:memory = 2048, :cpu = 8],
		:status = "active",
		:tags = ["prod", "db"]
	])
	AddNodeXTT("n3", "Server3", [
		:config = [:memory = 512, :cpu = 2],
		:status = "maintenance",
		:tags = ["dev"]
	])
	
	ConnectXTT("n1", "n2", "link1", [:bandwidth = 100, :tags = ["critical"]])
	ConnectXTT("n2", "n3", "link2", [:bandwidth = 50])
	
	# NODES - All queries use same pattern

	? @@( FindQ("nodes").
	      WithPropertyQ("config.memory").
	      Run()
	)
	#--> ["n1", "n2", "n3"]
	
	? @@( FindQ("nodes").
	      WhereQ("config.memory", "=", 1024).
	      Run()
	)
	#--> ["n1"]
	
	? @@( FindQ("nodes").
	      WhereQ("config.cpu", ">", 4).
	      Run()
	)
	#--> ["n2"]
	
	? @@( FindQ("nodes").
	      WhereQ("label", :contains, "Server").
	      Run()
	)
	#--> ["n1", "n2", "n3"]
	
	? @@( FindQ("nodes").
	      HavingQ("status", "active").
	      Run()
	)
	#--> ["n1", "n2"]
	
	? @@( FindQ("nodes").WithTagQ("prod").Run() )
	#--> ["n1", "n2"]
	
	# CHAINING
	? @@( FindQ("nodes").
	      WhereQ("config.cpu", ">", 2).
	      HavingQ("status", "active").
	      Run()
	)
	#--> ["n1", "n2"]
	
	# EDGES - Same syntax
	? @@( FindQ("edges").WithPropertyQ("bandwidth").Run() )
	#--> ["n1->n2", "n2->n3"]
	
	? @@( FindQ("edges").WhereQ("bandwidth", "=", 100).Run() )
	#--> ["n1->n2"]
	
	? @@( FindQ("edges").WithTagQ("critical").Run() )
	#--> ["n1->n2"]
	
	# RANGES
	? @@( FindQ("nodes").
	      WhereQ("config.memory", :between, [500, 1500]).
	      Run()
	)
	#--> ["n1", "n3"]
}

pf()
# Executed in 0.04 second(s) in Ring 1.24

#============================================#
#  SECTION 4: GRAPH ANALYSIS
#============================================#
