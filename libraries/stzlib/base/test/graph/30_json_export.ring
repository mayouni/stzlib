# Narrative
# --------
# JSON Export
#
# Extracted from stzgraphtest.ring, block #30.

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("JSONTest")
oGraph {
	AddNode("input")
	AddNode("output")
	Connect(:node = "input", :tonode = "output")
	
	? BoxRound("JSON FORMAT")
	? Json()
}
#-->
'
╭─────────────╮
│ JSON FORMAT │
╰─────────────╯
{
  "id": "JSONTest",
  "nodes": [
    {"id":"input","label":"Input","properties":{}},
    {"id":"output","label":"Output","properties":{}}
  ],
  "edges": [
    {"from":"input","to":"output","label":"","properties":{}}
  ],
  "metrics": {"nodecount":2,"edgecount":1,"density":50,"longestpath":1,"hascycles":0}
}
'

pf()
# Executed in 0.01 second(s) in Ring 1.24
