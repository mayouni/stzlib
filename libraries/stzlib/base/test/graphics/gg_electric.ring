load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	DN5 -- ELECTRIC, and the kill it was aimed at

	The plan called this the stress test and put it last on purpose:

	    "a net is a HYPEREDGE (one wire, three pins), which the pair-edge
	     model must earn honestly -- junction nodes drawn as dots, or the
	     domain is faked. KILL: if nets cannot be modelled without lying
	     about the graph, the domain waits for the model to grow."

	MEASURED, AND IT DOES NOT FIRE -- because its premise is about a
	DRAWING. A net looks like a line, so "edge" is the natural reach, and
	then edges turn out to have two ends. Ask the domain's own formats
	what a net IS and none of them says "a connection between two
	things":

	    SPICE    R1 n1 n2 1k          -- components NAME nets
	    KiCad    (net (code 1) (name "GND") (node ...) (node ...))
	    Verilog  wire [7:0] databus;  -- declared, typed, sized

	A net is a first-class named object that pins attach to, with
	properties an edge cannot carry, existing whether or not anything is
	attached. Modelling it as a NODE is the domain's own model; modelling
	it as an edge is what would have been the lie.

	ONE THING IS GENUINELY OWED, and it is a drawing rule. A schematic
	draws a junction dot only where THREE OR MORE wires meet; two pins on
	one net are a plain wire. So the net stays in the graph at any degree
	-- named, queryable -- and the PICTURE elides the dot at degree two.
	The model does not bend; the picture tells the truth about a junction.

	Run:  ring gg_electric.ring
---------------------------------------------------------------------------*/

decimals(2)
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
# TYPE SIZED TO THE PICTURE IT LANDS ON -- see gg_electric_compare.ring.
OPT = [ :Font = FONT, :NodeWidth = 110, :NodeHeight = 68, :FontSize = 26 ]

? "=============================================================="
? " DN5 -- ELECTRIC"
? "=============================================================="

#-- 1. AN RC FILTER ---------------------------------------------------------
#   The smallest circuit that exercises both halves of the junction rule:
#   two nets of degree 2 (a plain wire) and two of degree 3 (a dot).
o1 = new stzDiagram("rc")
o1.SetNotation(StzElectricNotation())
o1.AddNodeXTT("v1", "V1", [ :type = "source" ])
o1.AddNodeXTT("r1", "R1", [ :type = "resistor" ])
o1.AddNodeXTT("c1", "C1", [ :type = "capacitor" ])
o1.AddNodeXTT("gnd", "", [ :type = "ground" ])
o1.AddNodeXTT("nin", "IN", [ :type = "net" ])
o1.AddNodeXTT("nout", "OUT", [ :type = "net" ])
o1.AddNodeXTT("n0", "GND", [ :type = "net" ])
o1.AddEdge("v1", "nin")
o1.AddEdge("nin", "r1")
o1.AddEdge("r1", "nout")
o1.AddEdge("nout", "c1")
o1.AddEdge("c1", "n0")
o1.AddEdge("n0", "gnd")
o1.AddEdge("n0", "v1")
o1.ToCanvasXT(OPT)
o1.LastCanvas().ToPNG("elec_1_rc.png")
? "  RC filter      " + o1.LastCanvas().Width() + "x" +
  o1.LastCanvas().Height()
aNets1 = StzCircuitNets(o1)
? "  nets: " + len(aNets1)
for i = 1 to len(aNets1)
	? "    " + aNets1[i][2] + "  joins " + len(aNets1[i][3]) + " pin(s)" +
	  iif(o1._NetIsSpliced(aNets1[i][1]), "  -> drawn as a wire",
	      "  -> drawn as a junction")
next

#-- 2. A DIVIDER WITH A TAP -------------------------------------------------
#   The three-pin net the kill was written about: one wire, three pins,
#   and the dot that says so.
o2 = new stzDiagram("divider")
o2.SetNotation(StzElectricNotation())
o2.AddNodeXTT("v", "9V", [ :type = "source" ])
o2.AddNodeXTT("ra", "R1", [ :type = "resistor" ])
o2.AddNodeXTT("rb", "R2", [ :type = "resistor" ])
o2.AddNodeXTT("load", "LOAD", [ :type = "device" ])
o2.AddNodeXTT("g", "", [ :type = "ground" ])
o2.AddNodeXTT("top", "VCC", [ :type = "net" ])
o2.AddNodeXTT("mid", "TAP", [ :type = "net" ])
o2.AddNodeXTT("bot", "GND", [ :type = "net" ])
o2.AddEdge("v", "top")
o2.AddEdge("top", "ra")
o2.AddEdge("ra", "mid")
o2.AddEdge("mid", "rb")
o2.AddEdge("mid", "load")
o2.AddEdge("rb", "bot")
o2.AddEdge("load", "bot")
o2.AddEdge("bot", "g")
# THE SOURCE'S RETURN, which this fixture never had. Current leaves a
# source and must come back to it or nothing flows, and every other
# edge here was written while the picture was too tangled to notice the
# one that was missing: the 9V had a single connection, to R1, and its
# other terminal ended in air. The terminal-true wiring is what made it
# visible -- a lead pointing at nothing is obvious the moment every
# other lead is joined to something.
o2.AddEdge("bot", "v")
o2.ToCanvasXT(OPT)
o2.LastCanvas().ToPNG("elec_2_divider.png")
? ""
? "  divider        " + o2.LastCanvas().Width() + "x" +
  o2.LastCanvas().Height()
aNets2 = StzCircuitNets(o2)
for i = 1 to len(aNets2)
	? "    " + aNets2[i][2] + "  joins " + len(aNets2[i][3]) + " pin(s)" +
	  iif(o2._NetIsSpliced(aNets2[i][1]), "  -> drawn as a wire",
	      "  -> drawn as a junction")
next

#-- 3. THE GLYPHS -----------------------------------------------------------
#   Five shapes, and the only ones in the table read as VALUES rather
#   than as containers: a resistor symbol IS a resistance, where a box
#   with "R1" in it is merely a thing called R1.
o3 = new stzDiagram("symbols")
o3.SetNotation(StzElectricNotation())
o3.SetLayout(:LeftToRight)
o3.AddNodeXTT("s1", "source", [ :type = "source" ])
o3.AddNodeXTT("s2", "resistor", [ :type = "resistor" ])
o3.AddNodeXTT("s3", "capacitor", [ :type = "capacitor" ])
o3.AddNodeXTT("s4", "ground", [ :type = "ground" ])
o3.AddEdge("s1", "s2")
o3.AddEdge("s2", "s3")
o3.AddEdge("s3", "s4")
o3.ToCanvasXT(OPT)
o3.LastCanvas().ToPNG("elec_3_symbols.png")
? ""
? "  symbols        " + o3.LastCanvas().Width() + "x" +
  o3.LastCanvas().Height()

? ""
? "wrote elec_1..elec_3"
