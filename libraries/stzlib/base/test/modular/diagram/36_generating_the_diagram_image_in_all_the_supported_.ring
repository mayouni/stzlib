# Narrative
# --------
# Generating the diagram image in all the supported themes
#
# Extracted from stzdiagramtest.ring, block #36.

load "../../../stzBase.ring"


pr()

# Test all themes with semantic colors
acThemes = [ "neutral", "light", "dark", "vibrant", "pro",
	     "access", "print", "gray", "lightgray", "darkgray"]

for cTheme in acThemes
	oDiag = new stzDiagram("Theme_" + cTheme)
	oDiag {
		SetTheme(cTheme)
		SetLayout(:LeftRight)
		SetTitle("THEME " + UPPER(cTheme))

		# All semantic color types
		AddNodeXTT("s", "Start", [ :type = "start", :color = "success" ])
		AddNodeXTT("p1", "Process", [ :type = "process", :color = "primary" ])
		AddNodeXTT("w", "Warning", [ :type = "decision", :color = "warning" ])
		AddNodeXTT("d", "Danger", [ :type = "process", :color = "danger" ])
		AddNodeXTT("i", "Info", [ :type = "storage", :color = "info" ])
		AddNodeXTT("n", "Neutral", [ :type = "process", :color = "neutral" ])
		AddNodeXTT("e", "End", [ :type = "endpoint", :color = "success" ])
		
		Connect("s", "p1")
		Connect("p1", "w")
		ConnectXT("w", "d", "Yes")
		ConnectXT("w", "i", "No")
		Connect("d", "n")
		Connect("i", "n")
		Connect("n", "e")
		
		? "Theme: " + cTheme
		View()
	}
next

pf()
# Executed in 6.67 second(s) in Ring 1.25
# Executed in 12.69 second(s) in Ring 1.24
