# Narrative
# --------
# pr()
#
# Extracted from stzdiagramtest.ring, block #8.

load "../../stzBase.ring"


oDiag = new stzDiagram("ColorSystemTest")
oDiag {
	SetTheme("pro")
	SetPenWidth(2)

	# Base colors
	AddNodeXTT("n1", "Red Base", [
		:type = "process",
		:color = "red"
	])

	AddNodeXTT("n2", "Blue Base", [
		:type = "process",
		:color = "blue"
	])

	# Intensities
	AddNodeXTT("n3", "Red Dark", [
		:type = "process",
		:color = "red++"
	])

	AddNodeXTT("n4", "Blue Light", [
		:type = "process",
		:color = "blue--"
	])
	
	# Semantic
	AddNodeXTT("n5", "Success", [
		:type = "process",
		:color = "success"
	])

	AddNodeXTT("n6", "Warning", [
		:tpe = "decision",
		:color = "warning"
	])
	
	# Extended palette
	AddNodeXTT("n7", "Coral", [
		:type = "process",
		:color = "coral"
	])

	AddNodeXTT("n8", "Lavender", [
		:type = "process",
		:color = "vender"
	])
	
	# Direct hex
	AddNodeXTT("n9", "Custom", [
		:type = "process",
		:color = "#FF6B9D"
	])
	
	Connect("n1", "n2")
	Connect("n2", "n3")
	Connect("n3", "n4")
	Connect("n4", "n5")
	Connect("n5", "n6")
	Connect("n6", "n7")
	Connect("n7", "n8")
	Connect("n8", "n9")
	
	View()
}

pf()
#--> Executed in 0.70 second(s) in Ring 1.25
