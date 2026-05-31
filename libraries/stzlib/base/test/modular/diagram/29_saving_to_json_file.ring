# Narrative
# --------
# Saving to JSON file
#
# Extracted from stzdiagramtest.ring, block #29.

load "../../../stzBase.ring"


pr()

oDiag = new stzDiagram("simple")
oDiag.AddNodeXTT("x", "X Node", [ :type = "process", :color = "primary" ])

if oDiag.WriteToJsonInFolder("txtfiles")
	? read("txtfiles/simple.json")
ok
'
{
	"id": "simple",
	"nodes": [
		{
			"id": "x",
			"label": "X_Node",
			"properties": {
				"type": "process",
				"color": "primary"
			}
		}
	],
	"edges": {

	},
	"properties": [
		"type",
		"color"
	],
	"theme": "pro",
	"layout": "topdown",
	"clusters": {

	},
	"annotations": {

	},
	"templates": {

	}
}
'

pf()
# Executed in 0.03 second(s) in Ring 1.25
