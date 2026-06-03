# Narrative
# --------
# Verifying JSON structure fields
#
# Extracted from stzdiagramtest.ring, block #30.

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("JsonStructureTest")
oDiag.AddNodeXTT("n", "Node", [ :type = "process", :color = "primary" ])

? oDiag.Json()
#-->
`
{
	"id": "jsonstructuretest",
	"nodes": [
		{
			"id": "n",
			"label": "Node",
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
`

pf()
# Executed in 0.03 second(s) in Ring 1.25
