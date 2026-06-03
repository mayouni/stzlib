# Narrative
# --------
# Generating .stzdiag native text format
#
# Extracted from stzdiagramtest.ring, block #18.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("FormatTest")
oDiag.SetTheme(:pro)
oDiag.SetLayout(:TopDown)
oDiag.AddNodeXTT("start", "Begin", [ :type = "start", :color = "success-" ])
oDiag.AddNodeXTT("process", "Work", [ :type = "process", :color = "primary+" ])
oDiag.AddNodeXTT("end", "Finish", [ :type = "endpoint", :color = "success" ])
oDiag.Connect("start", "process")
oDiag.Connect("process", "end")

? oDiag.stzdiag()
#-->
'
diagram "FormatTest"

properties
    theme: pro
    layout: topdown

nodes
    start
        label: "Begin"
        type: start
        color: success-

    process
        label: "Work"
        type: process
        color: primary+

    end
        label: "Finish"
        type: endpoint
        color: success

edges
    start -> process

    process -> end
'

oDiag.Show()
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
       │ Finish │        
       ╰────────╯    
'

oDiag.View()

pf()
# Executed in 0.49 second(s) in Ring 1.25
