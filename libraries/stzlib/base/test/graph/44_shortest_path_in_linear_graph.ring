# Narrative
# --------
# Shortest path in linear graph
#
# Extracted from stzgraphtest.ring, block #44.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("Linear")
oGraph {
	AddNodeXT(:n1, "Start")
	AddNodeXT(:n2, "Middle")
	AddNodeXT(:n3, "End")
	
	Connect(:n1, :n2)
	Connect(:n2, :n3)
	
	? @@( ShortestPath(:From = :n1, :To = :n3) )
	#--> ["n1", "n2", "n3"]
	
	? ShortestPathLength(:From = :n1, :To = :n3)
	#--> 2

	Show()
	#-->
	'
	        ╭───────╮        
	        │ Start │        
	        ╰───────╯        
	            |            
	            v            
	      ╭──────────╮       
	      │ !Middle! │       
	      ╰──────────╯       
	            |            
	            v            
	         ╭─────╮         
	         │ End │         
	         ╰─────╯     
	'

}

pf()
# Executed in 0.03 second(s) in Ring 1.24
