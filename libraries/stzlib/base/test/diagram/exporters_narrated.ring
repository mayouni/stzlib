# The diagram EXPORTERS -- four ways out, and one way back.
#
# stzDiagram ships four exporters that no test had ever run: stzDiagramToDot
# (Graphviz), stzDiagramToMermaid, stzDiagramToJSON, and stzDiagramToStzDiag
# (Softanza's own .stzdiag). All four WROTE correctly -- exporters usually do,
# because the writer is the half you look at.
#
# The reader is the half that rots. ImportDiag() read .stzdiag back and
# dropped EVERY EDGE LABEL: an edge is two lines in that format --
#
#     a -> b
#         label: "next"
#
# -- and the parser's edges branch only ever matched the arrow line, so the
# label line matched nothing and was silently discarded, then the edge was
# added with Connect(), which takes no label. Same disease as .stzflow and
# .stzstyl: the writer says something the reader never listens for.
#
# Each exporter is judged by its TARGET, not by its own say-so: the JSON is
# handed to the engine's JSON validator, the DOT/Mermaid are checked for the
# syntax their tools require, and .stzdiag is asked to come back whole.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

oD = new stzDiagram("flow")
oD.AddNodeXTT("a", "Start", [ ["type", "start"] ])
oD.AddNodeXT("b", "Middle")
oD.AddNodeXT("c", "End")
oD.AddEdgeXT("a", "b", "next")
oD.AddEdge("b", "c")
oD.SetTheme("dark")

? "-- Scene 1: Graphviz DOT --"

cDot = oD.Dot()
chk("it writes something", len(cDot) > 0)
chk("a real digraph, named", StzFindFirst('digraph "flow" {', cDot) > 0)
chk("every node is declared", StzFindFirst('a [label="Start"', cDot) > 0 and
	StzFindFirst('b [label="Middle"', cDot) > 0)
chk("the edge carries its label", StzFindFirst("a -> b [label=", cDot) > 0)
chk("... and the plain edge has none", StzFindFirst("b -> c", cDot) > 0)
chk("it closes its brace", StzRight(StzTrim(cDot), 1) = "}")

? ""
? "-- Scene 2: Mermaid --"

cMer = oD.Mermaid()
chk("it declares a graph + direction", StzLeft(cMer, 8) = "graph TD")
chk("the start node takes the stadium shape", StzFindFirst('a(["Start"])', cMer) > 0)
chk("a plain node is a box", StzFindFirst('b["Middle"]', cMer) > 0)
chk("the labelled edge uses the pipe form", StzFindFirst("a -->|next| b", cMer) > 0)
chk("the plain edge is a bare arrow", StzFindFirst("b --> c", cMer) > 0)

? ""
? "-- Scene 3: JSON -- judged by the engine, not by itself --"

cJson = oD.Json()
chk("the ENGINE's JSON parser accepts it", StzJsonIsValid(cJson) = TRUE)
chk("... and reads the id back out of it", StzJsonGet(cJson, "id") = "flow")
chk("it carries nodes and edges", StzFindFirst('"nodes"', cJson) > 0 and
	StzFindFirst('"edges"', cJson) > 0)

? ""
? "-- Scene 4: .stzdiag -- the one that must come BACK --"

cDiag = oD.stzdiag()
chk("it writes its sections", StzFindFirst("nodes", cDiag) > 0 and
	StzFindFirst("edges", cDiag) > 0 and StzFindFirst("properties", cDiag) > 0)
chk("... including the edge label the reader used to drop",
	StzFindFirst('label: "next"', cDiag) > 0)

oBack = new stzDiagram("blank")
oBack.ImportDiag(cDiag)

chk("every node came back", oBack.NodeCount() = oD.NodeCount())
chk("every edge came back", oBack.EdgeCount() = oD.EdgeCount())
chk("a node's label came back", oBack.Node("a")[:label] = "Start")
chk("a node's property came back", oBack.NodeProperty("a", "type") = "start")
chk("the theme came back", oBack.Theme() = oD.Theme())

# THE defect this pins
chk("THE EDGE LABEL came back", oBack.Edge("a", "b")[:label] = "next")
chk("... and an unlabelled edge stays unlabelled", oBack.Edge("b", "c")[:label] = "")

? ""
? "-- Scene 5: importing into a diagram that already has nodes --"

# ImportDiag refuses unless the incoming first node anchors somewhere
bRefused = 0
try
	oOther = new stzDiagram("other")
	oOther.AddNodeXT("zzz", "Unrelated")
	oOther.ImportDiag(cDiag)
catch
	bRefused = 1
done
chk("an import that anchors nowhere REFUSES (never a silent merge)", bRefused = 1)

? ""
? "-- STYLING SETTERS: does each one reach an output, and does it leave the others alone?"
#
# An audit ran all 32 stzDiagram setters against all five outputs -- dot, styl,
# stzdiag, json, hashlist -- because probing ONE output is what made two earlier
# readings wrong: node colours are absent from the DOT and present in the .styl,
# and subtitles were the other way round. A knob is only dead when it reaches NONE
# of them. Four came back real.
#
# Each check has its negative sibling: three of these knobs are validated, and a
# check that only ever sets a GOOD value cannot tell honouring it from ignoring
# everything.

# 1. A REJECTED VALUE MUST NOT DESTROY THE ONE ALREADY THERE. SetSplines reset to
#    the default on anything it did not recognise, so an ortho set earlier became
#    "spline" -- not what you asked for either time.
chk("a spline it knows is taken", SplineAfter([ "ortho" ]) = "ortho")
chk("...and one it does not is refused, not obeyed", SplineAfter([ "ortho", "dashed" ]) = "ortho")

# 2. THE TWO LINE ALIASES are named for a different Graphviz attribute than the one
#    they reached. A spline is the ROUTE an edge takes; a line style is how it is
#    DRAWN. Both delegated to the route, so the obvious call was swallowed.
chk("a line style now sets the pen style", PenAfterLine("dashed") = "dashed")
chk("...and lands in the DOT", DotHas(:LineStyle, "style=dashed"))
chk("...while a spline name still sets the spline", SplineAfterLine("ortho") = "ortho")
chk("...and does NOT touch the pen style", PenAfterLine("ortho") = "solid")

# 3. A SUBTITLE ON ITS OWN was dropped by both emitters: the label block that
#    carries it was gated on the title alone.
chk("a subtitle alone reaches the DOT", DotHas(:SubtitleOnly, "zzsub"))
chk("...and the .stzdiag", DiagHasSubtitle())
chk("...and a diagram with neither carries no label", NOT DotHas(:Bare, "labelloc"))

# 4. THE .styl EDGES BLOCK never carried the pen style its nodes block always had,
#    so a stylesheet could not round-trip one.
chk("the styl edges block carries a penstyle", StylEdgeHas("penstyle"))
chk("...and it is the one that was set", StylEdgeHas("penstyle: dotted"))

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

# -- the styling-setter helpers ------------------------------------------------

func KnobDia()
    _oK_ = new stzDiagram("demo")
    _oK_.AddNode(:A)
    _oK_.AddNode(:B)
    _oK_.AddEdge(:A, :B)
    return _oK_

func SplineAfter(paCalls)
    _oS_ = KnobDia()
    _nL_ = len(paCalls)
    for _i_ = 1 to _nL_
        _oS_.SetSplines(paCalls[_i_])
    next
    return _oS_.SplineType()

func PenAfterLine(cValue)
    _oP_ = KnobDia()
    _oP_.SetEdgeLineStyle(cValue)
    return _oP_.EdgePenStyle()

func SplineAfterLine(cValue)
    _oQ_ = KnobDia()
    _oQ_.SetEdgeLineType(cValue)
    return _oQ_.SplineType()

func DotHas(cWhat, cNeedle)
    _oD_ = KnobDia()
    switch cWhat
    on :LineStyle
        _oD_.SetEdgeLineStyle("dashed")
    on :SubtitleOnly
        _oD_.SetSubtitle("zzsub")
    on :Bare
        # nothing set -- the negative sibling
    off
    return StzFindFirst(cNeedle, _oD_.ToDot()) > 0

func DiagHasSubtitle()
    _oG_ = KnobDia()
    _oG_.SetSubtitle("zzsub")
    return StzFindFirst("zzsub", _oG_.ToStzDiagString()) > 0

# the edges block of the .styl export, on its own
func StylEdgeHas(cNeedle)
    _oE_ = KnobDia()
    _oE_.SetEdgePenStyle("dotted")
    _aL_ = @split(_oE_.ExportToStyl(), nl)
    _cBlock_ = ""
    _bIn_ = FALSE
    _nN_ = len(_aL_)
    for _i_ = 1 to _nN_
        if ring_trim(_aL_[_i_]) = "edges"
            _bIn_ = TRUE
            loop
        ok
        if _bIn_ and ring_trim(_aL_[_i_]) = "nodes"
            exit
        ok
        if _bIn_
            _cBlock_ += _aL_[_i_] + nl
        ok
    next
    return StzFindFirst(cNeedle, _cBlock_) > 0
