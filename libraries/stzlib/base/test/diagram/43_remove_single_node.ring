# Narrative
# --------
# Remove Single Node
#
# Extracted from stzdiagramtest.ring, block #43.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("Test")
oDiag.AddNodeXTT("n1", "Node 1", [ :type = "process", :color = "blue" ])
oDiag.AddNodeXTT("n2", "Node 2", [ :type = "process", :color = "blue" ])
oDiag.AddNodeXTT("n3", "Node 3", [ :type = "process", :color = "blue" ])

oDiag.Connect("n1", "n2")
oDiag.Connect("n2", "n3")

? oDiag.NodeCount()
#--> 3
? oDiag.EdgeCount()
#--> 2


oDiag.Show()
#-->
'
       ╭────────╮        
       │ Node 1 │        
       ╰────────╯        
            |            
            v            
      ╭──────────╮       
      │ !Node 2! │       
      ╰──────────╯       
            |            
            v            
       ╭────────╮        
       │ Node 3 │        
       ╰────────╯ 
'

? NL + "------------" + NL + NL

oDiag.RemoveNode("n2")

? oDiag.NodeCount()
#--> 2
? oDiag.EdgeCount()
#--> 0 (both edges removed)

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
#--> Executed in 0.06 second(s) in Ring 1.25
