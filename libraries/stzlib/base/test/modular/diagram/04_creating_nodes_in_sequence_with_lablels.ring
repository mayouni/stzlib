# Narrative
# --------
# Creating nodes in sequence with lablels
#
# Extracted from stzdiagramtest.ring, block #4.

load "../../../stzBase.ring"


pr()

oDiag = new stzDiagram("SequenceDemoXT")
oDiag {
	SetLayout("TB")
	SetEdgeStyle(:Normal)
	
	AddNodeXTT(:@Free, "Free", [ :type = "process", :color = "gray" ])
	AddNodeXTT(:@Basic, "Basic", [ :type = "process", :color = "primary" ])
	AddNodeXTT(:@Pro, "Pro", [ :type = "process", :color = "warning" ])
	AddNodeXTT(:@Enterprise, "Enterprise", [ :type = "process", :color = "success" ])
	
	# Sequence with labels between nodes
	ConnectSequenceXT([
		:@Free,
		"Upgrade",
		:@Basic,
		"Upgrade",
		:@Pro,
		"Upgrade",
		:@Enterprise
	])
	
	View()
}

pf()
# Executed in 0.61 second(s) in Ring 1.25
