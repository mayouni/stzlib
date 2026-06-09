# Narrative
# --------
# Color resolution
#
# Extracted from stzdiagramtest.ring, block #38.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag6 = new stzDiagram("ColorTest")
oDiag6 {
	SetTheme(:vibrant)
	
	# Symbolic colors from palette
	AddNodeXTT("n1", "Success", [ :type = "process", :color = "success" ])
	AddNodeXTT("n2", "Warning", [ :type = "process", :color = "warning" ])
	AddNodeXTT("n3", "Danger", [ :type = "process", :color = "danger" ])
	
	# Direct color names
	AddNodeXTT("n4", "Blue", [ :type = "process", :color = "lightblue" ])
	AddNodeXTT("n5", "Green", [ :type = "process", :color = "lightgreen" ])
	
	# Hex colors
	AddNodeXTT("n6", "Custom", [ :type = "process", :color = "#FF9900" ])
	
	Connect("n1", "n2")
	Connect("n2", "n3")
	Connect("n3", "n4")
	Connect("n4", "n5")
	Connect("n5", "n6")
	
	View()
}

pf()
# Executed in 0.66 second(s) in Ring 1.25

#----------------#
#  FONT EXAMPLE  #
#----------------#

pr()

oDiag = new stzDiagram("FontTest")
oDiag {

	SetFont("helvetica")
	SetFontSize(24)

	AddNodeXTT("n1", "Custom Font", [ :type = "start", :color = "success" ])
	AddNodeXTT("n2", "Arial 24pt", [ :type = "process", :color = "primary" ])
	ConnectXT("n1", "n2", "size")
	? Code()
	View()
}

pf()
# Executed in 0.46 second(s) in Ring 1.25
# Executed in 0.72 second(s) in Ring 1.24

#-----------------------------------#
#  CONFIGURING THE DIAGRAM TOOLTIP  #
#-----------------------------------#

pr()

o1 = new stzDiagram("Sales")
o1 {

    AddNodeXTT("a", "Marketing", [ 
        :type = "process", 
        :color = "blue",
        :Department = "Sales",
        :Budget = "$50K"
    ])
    
    AddNodeXTT("b", "Operations", [ 
        :type = "process",
        :color = "green",
        :Department = "Ops",
        :Budget = "$100K"
    ])
    
    Connect("a", "b")
    ? Code()

    SetTooltip([ :NodeId, :Type, :Color, :Department, :Budget ])
    // DisableTooltip() # Or SetTooltip("")
    View()
}


# This will show tooltips on hover like:
`
ID: a
Type: process
Color: blue
Department: Sales
Budget: $50K
`

pf()
# Executed in 0.52 second(s) in Ring 1.25
# Executed in 0.60 second(s) in Ring 1.24

#=============================#
#  DIAGRAM IMPORT & EDITING   #
#=============================#
