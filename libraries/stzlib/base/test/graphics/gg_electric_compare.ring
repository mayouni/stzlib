load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	DN5 AGAINST THE CANON

	The Principal's judgement: the first DN5 pictures do not resemble the
	schematics in textbooks, on the web, or in EDA tools. They do not.
	This file builds the circuits every one of those sources uses as its
	worked example -- a divider, an RC low-pass, a bridge rectifier, a
	common-emitter stage -- so the gap can be READ rather than argued.

	Run:  ring gg_electric_compare.ring
---------------------------------------------------------------------------*/

decimals(2)
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
# TYPE SIZED TO THE PICTURE IT LANDS ON. These came out at 13px on an
# 830px sheet -- 1.6% of the width, where every other gallery in this
# folder runs about 3.4% -- so the words read as half the size the rest
# of the library draws. The glyphs were never small: a resistor asked
# for at 92px draws at 79. The type was.
OPT = [ :Font = FONT, :NodeWidth = 110, :NodeHeight = 68, :FontSize = 26 ]

? "=============================================================="
? " DN5 -- THE CANONICAL CIRCUITS"
? "=============================================================="

#-- 1. VOLTAGE DIVIDER -- every textbook's first circuit ---------------------
o1 = new stzDiagram("divider")
o1.SetNotation(StzElectricNotation())
o1.AddNodeXTT("v", "12V", [ :type = "source" ])
o1.AddNodeXTT("r1", "R1 10k", [ :type = "resistor" ])
o1.AddNodeXTT("r2", "R2 10k", [ :type = "resistor" ])
o1.AddNodeXTT("g", "", [ :type = "ground" ])
o1.AddNodeXTT("vcc", "VCC", [ :type = "net" ])
o1.AddNodeXTT("out", "VOUT", [ :type = "net" ])
o1.AddNodeXTT("gnd", "GND", [ :type = "net" ])
o1.AddEdge("v", "vcc")   o1.AddEdge("vcc", "r1")
o1.AddEdge("r1", "out")  o1.AddEdge("out", "r2")
o1.AddEdge("r2", "gnd")  o1.AddEdge("gnd", "g")
o1.AddEdge("gnd", "v")
o1.ToCanvasXT(OPT)
o1.LastCanvas().ToPNG("cmp_1_divider.png")
? "  divider        " + o1.LastCanvas().Width() + "x" + o1.LastCanvas().Height()

#-- 2. RC LOW-PASS ----------------------------------------------------------
o2 = new stzDiagram("rc")
o2.SetNotation(StzElectricNotation())
o2.AddNodeXTT("v", "VIN", [ :type = "source" ])
o2.AddNodeXTT("r", "R 1k", [ :type = "resistor" ])
o2.AddNodeXTT("c", "C 100n", [ :type = "capacitor" ])
o2.AddNodeXTT("g", "", [ :type = "ground" ])
o2.AddNodeXTT("nin", "IN", [ :type = "net" ])
o2.AddNodeXTT("nout", "OUT", [ :type = "net" ])
o2.AddNodeXTT("n0", "GND", [ :type = "net" ])
o2.AddEdge("v", "nin")    o2.AddEdge("nin", "r")
o2.AddEdge("r", "nout")   o2.AddEdge("nout", "c")
o2.AddEdge("c", "n0")     o2.AddEdge("n0", "g")
o2.AddEdge("n0", "v")
o2.ToCanvasXT(OPT)
o2.LastCanvas().ToPNG("cmp_2_rc.png")
? "  RC low-pass    " + o2.LastCanvas().Width() + "x" + o2.LastCanvas().Height()

#-- 3. A LOOP -- the shape a layered layout has no answer for ---------------
#   Every real circuit is a set of LOOPS: current leaves a source and must
#   return to it. This is the smallest one that says so.
o3 = new stzDiagram("loop")
o3.SetNotation(StzElectricNotation())
o3.AddNodeXTT("v", "9V", [ :type = "source" ])
o3.AddNodeXTT("r", "R", [ :type = "resistor" ])
o3.AddNodeXTT("top", "A", [ :type = "net" ])
o3.AddNodeXTT("bot", "B", [ :type = "net" ])
o3.AddEdge("v", "top")   o3.AddEdge("top", "r")
o3.AddEdge("r", "bot")   o3.AddEdge("bot", "v")
o3.ToCanvasXT(OPT)
o3.LastCanvas().ToPNG("cmp_3_loop.png")
? "  a closed loop  " + o3.LastCanvas().Width() + "x" + o3.LastCanvas().Height()

#-- 4. THE SYMBOLS, BOTH WAYS ----------------------------------------------
#   A component lies along its wire, so the same four glyphs must read
#   correctly in a left-to-right circuit as well as a top-down one.
o4 = new stzDiagram("lr")
o4.SetNotation(StzElectricNotation())
o4.SetLayout(:LeftToRight)
o4.AddNodeXTT("v", "VIN", [ :type = "source" ])
o4.AddNodeXTT("r", "R", [ :type = "resistor" ])
o4.AddNodeXTT("c", "C", [ :type = "capacitor" ])
o4.AddNodeXTT("g", "", [ :type = "ground" ])
o4.AddEdge("v", "r")  o4.AddEdge("r", "c")  o4.AddEdge("c", "g")
o4.ToCanvasXT(OPT)
o4.LastCanvas().ToPNG("cmp_4_lr.png")
? "  left-to-right  " + o4.LastCanvas().Width() + "x" + o4.LastCanvas().Height()

? ""
? "wrote cmp_1..cmp_4"
