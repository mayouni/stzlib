# Narrative
# --------
# Filter with function
#
# Extracted from stzgraphquerytest.ring, block #11.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("employees")
oGraph {
	AddNodeXTT("alice", "Employee", [:salary = 50000])
	AddNodeXTT("bob", "Employee", [:salary = 60000])
	AddNodeXTT("carol", "Employee", [:salary = 70000])
}

StzGraphQueryQ(oGraph) {
	Match(:nodes)
	
	WhereF(func aBinding {
		if @HasKey(aBinding, "node")
			aNode = aBinding["node"]
			if @HasKey(aNode, :properties)
				aProps = aNode[:properties]
				if @HasKey(aProps, "salary")
					return aProps["salary"] > 55000
				ok
			ok
		ok
		return FALSE
	})
	
	aResults = Select("*")
	? len(aResults)
	#--> 2 
}

pf()
# Executed in almost 0 second(s) in Ring 1.26
# Executed in 0.01 second(s) in Ring 1.25

#------------------------#
#  SELECT PROJECTIONS    #
#------------------------#
