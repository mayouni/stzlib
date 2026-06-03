# Narrative
# --------
# DOT Export
#
# Extracted from stzgraphtest.ring, block #29.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

oGraph = new stzGraph("ExportTest")
oGraph {
	AddNode("A")
	AddNode("B")
	Connect("A", "B")
	
	? BoxRound("DOT FORMAT")

	? Dot()

	Show() # In ascii form in the console
	View() # In graphiz-generated diagram
}
#--> DOT CODE
'
╭────────────╮
│ DOT FORMAT │
╰────────────╯
digraph ExportTest {
  rankdir=LR;
  node [shape=box];

  a [label="A"];
  b [label="B"];

  a -> b;
}
'

#--> IN CONSOLE
'
          ╭───╮          
          │ A │          
          ╰───╯          
            |            
            v            
          ╭───╮          
          │ B │          
          ╰───╯ 
'

#--> (image generated as svg)

# NOTE: If you need more advanced visual diagram features,
# convert the stzGraph object into an stzDiagram object
# using the ToStzDiagram() method, and continue from there.
# TODO: Add an example demonstrating this.

pf()
# Executed in 0.61 second(s) in Ring 1.24
