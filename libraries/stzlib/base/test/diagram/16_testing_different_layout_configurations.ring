# Narrative
# --------
# Testing different layout configurations
#
# Extracted from stzdiagramtest.ring, block #16.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzDiagram("")
o1 {
	AddNode("a")
	AddNodeXT("b", "pass")
	AddNodeXTT("c", "end", [ :type = "endpoint", :color = "green" ]) 
	Connect("a", "b")
	ConnectXT("a", "c", "focus")

	SetLayout(:LeftRight) # Try with :LeftRight
	SetSplines("spline") # or curved, ortho, polyline, line

	View()
}

pf()
# Executed in 0.60 second(s) in Ring 1.25

#---------------------------#
#  EXPORT TO OTHER FORMATS  #
#---------------------------#
