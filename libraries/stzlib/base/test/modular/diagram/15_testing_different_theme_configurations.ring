# Narrative
# --------
# Testing different theme configurations
#
# Extracted from stzdiagramtest.ring, block #15.

load "../../../stzBase.ring"


pr()

o1 = new stzDiagram("")
o1 {
	SetSplines("curved") # or spline, ortho, polyline, line
	AddNode("a")
	AddNodeXT("b", "pass")
	AddNodeXTT("c", "end", [ :type = "endpoint", :color = "green" ]) 
	Connect("a", "b")
	ConnectXT("a", "c", "focus")

	SetTheme(:dark) # Test with :light or :pro or :neutral...
	? Theme() #--> dark
	View()
}

pf()
# Executed in 0.52 second(s) in Ring 1.25

#--------------#
#  SET LAYOUT  #
#--------------#
