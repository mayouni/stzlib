# Narrative
# --------
# Import as Subdiagram
#
# Extracted from stzdiagramtest.ring, block #41.

load "../../../stzBase.ring"


pr()

oDiag = new stzDiagram("MainFlow")

oDiag.AddNodeXTT("start", "Main Start", [
	:type = "start", :color = "success"
])

oDiag.AddNodeXTT("main", "Main Process", [
	:type = "process", :color = "primary"
])

oDiag.Connect("start", "main")

# Diagram before import (note how it contains a "Main Process" node
oDiag.Show()
#-->
'
     ╭────────────╮      
     │ Main Start │      
     ╰────────────╯      
            |            
            v            
    ╭──────────────╮     
    │ Main Process │     
    ╰──────────────╯  
'

# The stzdiag string to be imported (node that it starts with a "Main Process" node

cSubFlow = '
diagram "SubFlow"

nodes
    main
        label: "Main Process"
        type: process
        color: #0000FF

    sub1
        label: "Sub Task 1"
        type: process
        color: #FFA500

    sub2
        label: "Sub Task 2"
        type: process
        color: #FFA500

    result
        label: "Result"
        type: endpoint
        color: #008000

edges
    main -> sub1
    main -> sub2
    sub1 -> result
    sub2 -> result
'

# The import will incrust the subflow in the common "Main Process" node

oDiag.ImportDiag(cSubFlow)
? oDiag.NodeCount()
#--> 5 (start, main, sub1, sub2, result)

? oDiag.HasNode("sub1")
#--> TRUE

? oDiag.Code()

# Let's visuaise the actual diagram (not view() ~> image vs show() ~> ascii from stzGraph)
oDiag.View()

pf()
#--> Executed in 0.67 second(s) in Ring 1.25
