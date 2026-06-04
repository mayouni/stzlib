# Narrative
# --------
# Converting to Mermaid.js syntax
#
# Extracted from stzdiagramtest.ring, block #25.

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("MermaidTest")
oDiag.AddNodeXTT("start", "Start", [ :type = "start", :color = "success" ])
oDiag.AddNodeXTT("decision", "Check", [ :type = "decision", :color = "warning" ])
oDiag.AddNodeXTT("process", "Process", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("end", "End", [ :type = "endpoint", :color = "success" ])

oDiag.Connect("start", "decision")
oDiag.ConnectXT("decision", "process", "Yes")
oDiag.Connect("process", "end")

? oDiag.Mermaid()
#--> Past it in https://mermaid.live/
'
graph TD
    node_start(["Start"])
    decision{{"Check"}}
    process["Process"]
    node_end(["End"])

    node_start --> decision
    decision -->|Yes| process
    process --> node_end
'

oDiag.Show()
#-->
'
        ╭───────╮        
        │ Start │        
        ╰───────╯        
            |            
            v            
       ╭─────────╮       
       │ !Check! │       
       ╰─────────╯       
            |            
           Yes           
            |            
            v            
      ╭───────────╮      
      │ !Process! │      
      ╰───────────╯      
            |            
            v            
         ╭─────╮         
         │ End │         
         ╰─────╯   
'

pf()
# Executed in 0.06 second(s) in Ring 1.25
