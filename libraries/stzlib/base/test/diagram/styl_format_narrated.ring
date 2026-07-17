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
	StzFindFirst(cStyl, "colors") > 0 and StzFindFirst(cStyl, "fonts") > 0 and
	StzFindFirst(cStyl, "edges") > 0 and StzFindFirst(cStyl, "nodes") > 0 and
	StzFindFirst(cStyl, "focus") > 0)

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
