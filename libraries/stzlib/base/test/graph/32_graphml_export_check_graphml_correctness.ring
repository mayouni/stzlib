# Narrative
# --------
# GraphML export #TODO Check GraphML correctness
#
# Extracted from stzgraphtest.ring, block #32.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("SimpleGraph")
oGraph {
	AddNodeXT("n1", "Node 1")
	AddNodeXT("n2", "Node 2")
	AddNodeXT("n3", "Node 3")
	
	Connect("n1", "n2")
	Connect("n2", "n3")

	? ToGraphMl() + NL
	SaveToGraphML("../_data/simple.graphml")

}
#-->
`
<?xml version="1.0" encoding="UTF-8"?>
<graphml xmlns="http://graphml.graphdrawing.org/xmlns"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns
         http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">

  <key id="label" for="node" attr.name="label" attr.type="string"/>
  <key id="type" for="graph" attr.name="type" attr.type="string"/>
  <key id="edge_label" for="edge" attr.name="label" attr.type="string"/>

  <graph id="SimpleGraph" edgedefault="directed">
    <data key="type">structural</data>

    <node id="n1">
      <data key="label">Node_1</data>
    </node>
    <node id="n2">
      <data key="label">Node_2</data>
    </node>
    <node id="n3">
      <data key="label">Node_3</data>
    </node>

    <edge id="e1" source="n1" target="n2">
    </edge>
    <edge id="e2" source="n2" target="n3">
    </edge>
  </graph>
</graphml>
`

oOtherGraph = new stzGraph("")
oOtherGraph.LoadFromGraphML("../_data/simple.graphml")
oOtherGraph.Show()
#-->
'
       ╭────────╮        
       │ Node_1 │        
       ╰────────╯        
            |            
            v            
      ╭──────────╮       
      │ !Node_2! │       
      ╰──────────╯       
            |            
            v            
       ╭────────╮        
       │ Node_3 │        
       ╰────────╯  
'

pf()
# Executed in 0.04 second(s) in Ring 1.24


#============================================#
#  SECTION 8: EXPLAIN FEATURE
#============================================#
