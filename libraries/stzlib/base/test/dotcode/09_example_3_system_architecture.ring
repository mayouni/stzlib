# Narrative
# --------
# #  Example 3: System Architecture  #
#
# Extracted from stzdotcodetest.ring, block #9.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

#----------------------------------#

pr()

Dot = XDot()  # Using the XDot() function

Dot.SetCode('
digraph {
  rankdir=LR
  node [shape=box]
  edge [headport=w, tailport=e]
  node [fontname="Courier New"]
  node [style=filled colorscheme=dark26]
  ranksep=0.8

  client [label="Client", color=1, group=main]
  lb [label="Load balancer", color=2, group=main]
  backend1 [label="Backend", color=3]
  backend2 [label="Backend", color=3, group=main]
  backend3 [label="Backend", color=3]
  db [label="DB", color=4]
  cache [label="Cache", color=5, group=main]
  streamer [label="Streamer", color=6, group=main]

  subgraph f {
    rank=same
    edge [style=invis, headport=s, tailport=n]
    backend1 -> backend2 -> backend3
  }

  client -> lb
  lb -> {backend1, backend2, backend3}
  {backend1, backend2, backend3} -> db
  {backend1, backend2, backend3} -> cache
  cache -> streamer [weight=1]
  streamer:n -> client:n [weight=0]
}
')

Dot.SetOutputFormat("svg")
Dot.SetVerbose(1)
Dot.ExecuteAndView()

#--> The diagram is dispalyed in your default browser (or svg viewer)
#-->
'
Command: D:\Graphviz\bin\dot.exe -Tsvg temp\temp.dot -o output\architecture.svg > temp\dotlog.txt 2>&1
Output file: output\architecture.svg
Log: ""
'

pf()
# Executed in 0.45 second(s) in Ring 1.24
