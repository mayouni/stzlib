# Narrative
# --------
# Diameter of graph
#
# Extracted from stzgraphtest.ring, block #55.

load "../../../stzBase.ring"


pr()

oGraph = new stzGraph("Chain")
oGraph {
	AddNode(:n1)
	AddNode(:n2)
	AddNode(:n3)
	AddNode(:n4)
	
	Connect(:n1, :n2)
	Connect(:n2, :n3)
	Connect(:n3, :n4)
	
	? Diameter()
	#--> 3 (longest path: n1 to n4)

	Show()
	#-->
	'
	         ╭────╮          
	         │ n1 │          
	         ╰────╯          
	            |            
	            v            
	        ╭──────╮         
	        │ !n2! │         
	        ╰──────╯         
	            |            
	            v            
	        ╭──────╮         
	        │ !n3! │         
	        ╰──────╯         
	            |            
	            v            
	         ╭────╮          
	         │ n4 │          
	         ╰────╯  
	'

}

pf()
# Executed in 0.03 second(s) in Ring 1.24
