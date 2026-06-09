# Narrative
# --------
# Node type variations
#
# Extracted from stzdiagramtest.ring, block #34.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("ShapeTest")
oDiag {
	SetTheme(:pro)
	SetLayout(:TopDown)
	
	# Semantic types (shape auto-selected)
	AddNodeXTT("start", "Start", [ :type = "start", :color = "success" ])
	AddNodeXTT("validate", "Validate", [ :type = "process", :color = "primary" ])
	AddNodeXTT("check", "Valid?", [ :type = "decision", :color = "warning" ])
	AddNodeXTT("done", "Done", [ :type = "endpoint", :color = "success" ])
	
	# Direct DOT shapes (explicit control)
	AddNodeXTT("db", "Database", [ :type = "cylinder", :color = "neutral+" ]) # Note how we made neutral a bit darker with +
	AddNodeXTT("alert", "Alert", [ :type = "hexagon", :color = "danger" ])
	AddNodeXTT("backup", "Backup", [ :type = "parallelogram", :color = "info" ])
	AddNodeXTT("end", "End", [ :type = "octagon", :color = "success" ])
	
	Connect("start", "validate")
	Connect("validate", "check")
	ConnectXT("check", "db", "Yes")
	ConnectXT("check", "alert", "No")
	Connect("db", "backup")
	Connect("backup", "done")
	Connect("alert", "end")
	
	? Code()
	View()
}

pf()
# Executed in 0.65 second(s) in Ring 1.25
