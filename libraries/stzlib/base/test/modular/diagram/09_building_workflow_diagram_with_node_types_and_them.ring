# Narrative
# --------
# Building workflow diagram with node types and theme
#
# Extracted from stzdiagramtest.ring, block #9.

load "../../../stzBase.ring"


pr()

oDiag = new stzDiagram("OrderFlow")
oDiag {
	SetTheme("pro")
	AddNodeXTT("start", "Order Received", [
		:type = "start",
		:color = "success"]
	)

	AddNodeXTT("validate", "Validate", [
		:type = "process",
		:color = "primary"
	])

	AddNodeXTT("complete", "Done", [
		:type = "endpoint", :color = "success"
	])

	Connect("start", "validate")
	Connect("validate", "complete")

	? NodeCount() #--> 3
	? EdgeCount() #--> 2

	? Dot()

	View()
}

#-->
'
digraph "OrderFlow" {
    graph [rankdir=TB, bgcolor=white, fontname=Helvetica]
    node [fontname=Helvetica]
    edge [fontname=Helvetica, color=black]

    start [label="Order Received", shape=ellipse, style="filled", fillcolor="#006633", fontcolor="white"]
    validate [label="Validate", shape=box, style="rounded,filled", fillcolor="lightblue", fontcolor="black"]
    complete [label="Done", shape=doublecircle, style="filled", fillcolor="#006633", fontcolor="white"]

    start -> validate
    validate -> complete

}
'

pf()
# Executed in 0.53 second(s) in Ring 1.25
