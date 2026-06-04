# Narrative
# --------
# ASCII Visualization
#
# Extracted from stzgraphtest.ring, block #31.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("VisTest")
oGraph {
	AddNode("start")
	AddNode("middle")
	AddNode("end")
	
	Connect(:node = "start", :to = "middle")
	Connect(:nodes = "middle", :and = "end")
	#NOTE// how I diversified naming params alternatives

}

oGraph.Show() # ShowV by default
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

oGraph.ShowH()
#-->
'
╭───────╮     ╭──────────╮     ╭─────╮
│ Start │---->│ !Middle! │---->│ End │
╰───────╯     ╰──────────╯     ╰─────╯
'

pf()
# Executed in 0.04 second(s) in Ring 1.24
