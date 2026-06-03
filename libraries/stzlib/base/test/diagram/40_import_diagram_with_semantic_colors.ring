# Narrative
# --------
# Import Diagram with Semantic Colors
#
# Extracted from stzdiagramtest.ring, block #40.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("MainFlow")

cImported = '
diagram "ProcessFlow"

properties
    theme: pro
    layout: topdown

nodes
    start
        label: "Begin"
        type: start
        color: success

    process
        label: "Work"
        type: process
        color: primary

    validate
        label: "Work"
        type: danger
        color: danger+

    end
        label: "Finish"
        type: endpoint
        color: success

edges
    start -> process
    process -> validate
    validate -> end
'

oDiag.ImportDiag(cImported)
oDiag.Show()
oDiag.View()

#-->
'
        ╭───────╮        
        │ Begin │        
        ╰───────╯        
            |            
            v            
       ╭────────╮        
       │ !Work! │        
       ╰────────╯        
            |            
            v            
       ╭────────╮        
       │ !Work! │        
       ╰────────╯        
            |            
            v            
       ╭────────╮        
       │ Finish │        
       ╰────────╯   
'

pf()
#--> Executed in 0.62 second(s) in Ring 1.25
