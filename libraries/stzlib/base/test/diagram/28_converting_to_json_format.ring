# Narrative
# --------
# Converting to JSON format
#
# Extracted from stzdiagramtest.ring, block #28.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDiag = new stzDiagram("JsonTest")
oDiag.SetTheme(:pro)
oDiag.AddNodeXTT("a", "NodeA", [ :type = "process", :color = "primary" ])
oDiag.AddNodeXTT("b", "NodeB", [ :type = "process", :color = "primary" ])
oDiag.Connect("a", "b")

? oDiag.Json()
#-->
'
{
	"id": "jsontest",
	"nodes": [
		{
			"id": "a",
			"label": "NodeA",
			"properties": {
				"type": "process",
				"color": "primary"
			}
		},
		{
			"id": "b",
			"label": "NodeB",
			"properties": {
				"type": "process",
				"color": "primary"
			}
		}
	],
	"edges": [
		{
			"from": "a",
			"to": "b",
			"label": "",
			"properties": {

			}
		}
	],
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
