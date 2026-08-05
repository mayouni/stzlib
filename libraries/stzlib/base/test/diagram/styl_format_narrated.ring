# .stzstyl -- a diagram's STYLE, written down.
#
# ExportToStyl() has always written the file. LoadStyle() could never read one
# back -- not even the file ExportToStyl() had just produced. Two faults:
#
#   the PAIR/FLAT mismatch -- stzStylParser builds each section as a list of
#       PAIRS (`_aStyle_[section] + [key, value]` appends the pair as ONE
#       element), while _ApplyStyle walked all FIVE sections (colors, fonts,
#       edges, nodes, focus) as a flat [k,v,k,v] run -> R2 on the last pair.
#       The identical fault, from the same era, as the .stzflow parser's
#       _AddStep/_AddActor.
#   the MISSING SETTER -- the focus section is written by the exporter and
#       read by _ApplyStyle via This.SetFocusColor(), a method nobody had
#       ever written -> R14.
#
# So this asks the only question that matters of a file format: does what
# comes back equal what went in?

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: a styled diagram writes itself down --"

oD = new stzDiagram("showcase")
oD.AddNode("a")
oD.SetTheme("dark")
oD.SetLayout("leftright")
oD.SetEdgeColor("blue")
oD.SetFocusColor("red")

cStyl = oD.ExportToStyl()
chk("the export produces a file", len(cStyl) > 0)
chk("... naming every section it will need to read back",
	StzFindFirst("colors", cStyl) > 0 and StzFindFirst("fonts", cStyl) > 0 and
	StzFindFirst("edges", cStyl) > 0 and StzFindFirst("nodes", cStyl) > 0 and
	StzFindFirst("focus", cStyl) > 0)

write("_rt.stzstyl", cStyl)
chk("the file is really on disk", fexists("_rt.stzstyl"))

? ""
? "-- Scene 2: a FRESH diagram reads it back --"

oBack = new stzDiagram("blank")
chk("a fresh diagram starts on the default theme", oBack.Theme() != "dark")

oBack.LoadStyle("_rt.stzstyl")
chk("LoadStyle survives at all -- it used to die on R2", TRUE)

chk("the theme came back", oBack.Theme() = oD.Theme())
chk("the layout came back", oBack.Layout() = oD.Layout())

? ""
? "-- Scene 3: the sections the flat-run fault destroyed --"

# each of these lives in a different section of the file, and every section
# was read with the same broken stride
chk("edges: the colour survived", oBack.EdgeColor() = oD.EdgeColor())
chk("focus: the colour survived -- the section whose setter did not exist",
	oBack.FocusColor() = oD.FocusColor())
chk("... and it is the resolved value, not the name",
	StzLeft(oBack.FocusColor(), 1) = "#")

? ""
? "-- Scene 4: reading a style twice is harmless --"

bTwice = TRUE
try
	oBack.LoadStyle("_rt.stzstyl")
catch
	bTwice = FALSE
done
chk("loading the same style again does not raise", bTwice)
chk("... and changes nothing", oBack.FocusColor() = oD.FocusColor())

bMissing = 0
try
	oX = new stzDiagram("x")
	oX.LoadStyle("_no_such_file.stzstyl")
catch
	bMissing = 1
done
chk("a style file that isn't there REFUSES", bMissing = 1)

# -- THE EDGE PEN STYLE, which used to reach nothing --
#
# SetEdgePenStyle takes the Graphviz vocabulary (solid, dashed, dotted, bold,
# invis) and mirrors SetNodePenStyle, which has always worked -- there is no
# SetNodeStyle, so the node side has only a pen style. SetEdgeStyle is a
# different layer: it takes SEMANTIC values, and :Conditional resolves to dashed.
#
# _GetEdgeStyle() read only the semantic one, and read it whenever it was
# "not empty" -- which is every diagram ever made, because it is born holding
# $cDefaultEdgeStyle. So the pen style was shadowed on every path. It set an
# attribute, its accessor read the value back, and nothing ever drew it.
#
# Each check below comes in two halves, because a knob that agrees with the
# default proves nothing: the chosen style must be IN the DOT, and the style it
# replaced must be OUT of it.

oPen = new stzDiagram("pen")
oPen.AddNode(:A)  oPen.AddNode(:B)  oPen.AddEdge(:A, :B)
oPen.SetEdgePenStyle("bold")
cPen = oPen.ToDot()
chk("an edge pen style reaches the DOT", StzFindFirst("style=bold", cPen) > 0)
chk("...and displaces the default", StzFindFirst("style=solid", cPen) = 0)

oSem = new stzDiagram("sem")
oSem.AddNode(:A)  oSem.AddNode(:B)  oSem.AddEdge(:A, :B)
oSem.SetEdgeStyle(:Conditional)
chk("a semantic style still resolves", StzFindFirst("style=dashed", oSem.ToDot()) > 0)

oBoth = new stzDiagram("both")
oBoth.AddNode(:A)  oBoth.AddNode(:B)  oBoth.AddEdge(:A, :B)
oBoth.SetEdgePenStyle("dotted")
oBoth.SetEdgeStyle(:Conditional)
cBoth = oBoth.ToDot()
chk("the semantic style wins over the pen", StzFindFirst("style=dashed", cBoth) > 0)
chk("...and the pen style gives way", StzFindFirst("style=dotted", cBoth) = 0)

# THE NEGATIVE SIBLING: untouched, an edge is solid. Without this every check
# above would still pass against a diagram that emitted bold unconditionally.
oPlain = new stzDiagram("plain")
oPlain.AddNode(:A)  oPlain.AddNode(:B)  oPlain.AddEdge(:A, :B)
cPlain = oPlain.ToDot()
chk("an untouched edge is solid", StzFindFirst("style=solid", cPlain) > 0)
chk("...and carries no pen style of its own", StzFindFirst("style=bold", cPlain) = 0)

remove("_rt.stzstyl")

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
