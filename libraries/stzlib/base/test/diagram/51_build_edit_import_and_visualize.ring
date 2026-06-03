# Narrative
# --------
# Build, Edit, Import, and Visualize
#
# Extracted from stzdiagramtest.ring, block #51.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

# Build initial diagram
oDiag = new stzDiagram("PaymentFlow")
oDiag.SetTheme(:pro)
oDiag.AddNodeXTT("start", "Request", [ :type = "start", :color = "success" ])
oDiag.AddNodeXTT("validate", "Validate", [ :type = "decision", :color = "warning" ])
oDiag.AddNodeXTT("approved", "Approved", [ :type = "endpoint", :color = "success" ])

oDiag.Connect("start", "validate")
oDiag.Connect("validate", "approved")

# Add properties
oDiag.SetNodeProps("validate", [
    :rule = "amount < 10000",
    :approver = "system"
])

# Import subflow for manual approval
cManualFlow = '
diagram "ManualApproval"

nodes
    validate
        label: "Validate"
        type: decision
        color: #FFFF00

    manual
        label: "Manual Review"
        type: process
        color: #FFA500

    manager
        label: "Manager Approval"
        type: decision
        color: #FFFF00

    approved
        label: "Approved"
        type: endpoint
        color: #008000

edges
    validate -> manual
    manual -> manager
    manager -> approved
'

oDiag.ImportDiag(cManualFlow)

? @@( oDiag.NodesNames() )
#--< [ "start", "validate", "approved", "manual", "manager", "approved" ]

? oDiag.NodeCount()
#--> 6

? oDiag.HasNode("manager")
#--> TRUE

# Update properties
oDiag.UpdateNodeProp(:validate, "type", "action")
? @@NL( oDiag.Node(:validate) )
#--> [
# 	[ "id", "validate" ],
# 	[ "label", "Validate" ],
# 	[
# 		"properties",
# 		[
# 			[ "type", "action" ],  # HAS BEEN AUPDATED!
# 			[ "color", "warning" ],
# 			[ "rule", "amount < 10000" ],
# 			[ "approver", "system" ]
# 		]
# 	]
# ]

# Visualize
oDiag.View()

oDiag.Show()
#-->
`
       ╭─────────╮       
       │ Request │       
       ╰─────────╯       
            |            
            v            
     ╭────────────╮      
     │ !Validate! │      
     ╰────────────╯      
            |            
            v            
      ╭──────────╮       
      │ Approved │       
      ╰──────────╯       

          ////

     ╭────────────╮  ↑
     │ !Validate! │──╯
     ╰────────────╯      
            |            
            v            
    ╭───────────────╮    
    │ Manual_Review │    
    ╰───────────────╯    
            |            
            v            
  ╭──────────────────╮   
  │ Manager_Approval │   
  ╰──────────────────╯   
            |            
            v            
      ╭──────────╮       
      │ Approved │       
      ╰──────────╯ 
`


pf()
#--> Executed in 0.73 second(s) in Ring 1.25

#======================================#
#  TESTING stzDiagram RULE SYSTEM      #
#  Now properly aligned with stzGraph  #
#======================================#
