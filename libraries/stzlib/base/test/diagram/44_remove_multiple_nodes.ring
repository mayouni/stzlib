# Narrative
# --------
# Remove Multiple Nodes
#
# Extracted from stzdiagramtest.ring, block #44.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("Test")

oDiag.AddNodeXTT("n1", "Node 1", [ :type = "process", :color = "blue" ])
oDiag.AddNodeXTT("n2", "Node 2", [ :type = "process", :color = "blue" ])
oDiag.AddNodeXTT("n3", "Node 3", [ :type = "process", :color = "blue" ])
oDiag.AddNodeXTT("n4", "Node 4", [ :type = "process", :color = "blue" ])

oDiag.Connect("n1", "n2")
oDiag.Connect("n3", "n4")
oDiag.show()
#♦-->
'
       ╭────────╮        
       │ Node 1 │        
       ╰────────╯        
            |            
            v            
       ╭────────╮        
       │ Node 2 │        
       ╰────────╯        

          ////

       ╭────────╮        
       │ Node 3 │        
       ╰────────╯        
            |            
            v            
       ╭────────╮        
       │ Node 4 │        
       ╰────────╯ 
'

? NL + "-----------" + NL + NL

oDiag.RemoveTheseNodes(["n2", "n4"])

? oDiag.NodeCount()
#--> 2

oDiag.Show()
#-->
'
       ╭────────╮        
       │ Node 1 │        
       ╰────────╯        

          ////

       ╭────────╮        
       │ Node 3 │        
       ╰────────╯ 
'

pf()
#--> Executed in 0.07 second(s) in Ring 1.25
