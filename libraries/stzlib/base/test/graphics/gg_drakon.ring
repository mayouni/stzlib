load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	DN6 -- DRAKON, and the kill measured before a line of it was written

	The Principal named DRAKON as the next deep task in this plane: "the
	best visual language for designing any diagram", to be embraced as a
	first-class citizen. Its three governing ideas are laws about
	READING:

	    the skewer        one vertical line carries the main path
	    no crossings      by construction, not by a router
	    the happy path    is the leftmost line, and horizontal distance
	                      measures how unusual a branch is

	The third is the one this library already arrived at from the other
	end, by the Principal marking pictures that were wrong. DN6 is where
	it stops being a rule the plane patched in and becomes a law a
	notation declares -- SetBranchSide(:Right).

	THE KILL, MEASURED FIRST. DRAKON's no-crossing guarantee comes from
	the source being a STRUCTURED algorithm; an IRREDUCIBLE flow graph
	cannot be laid on skewers without a crossing or a duplicated node.
	Measured over every model in this plane's fixtures by extracting the
	edge lists and running the T1/T2 collapse: 139 models, 52 with a
	cycle, 117 reducible once given a single entry, and ZERO genuinely
	irreducible. The other 22 have no entry at all -- circuits and ring
	lifecycles, outside DRAKON's scope by construction. The kill does not
	fire.

	Run:  ring gg_drakon.ring
---------------------------------------------------------------------------*/

decimals(2)
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
OPT = [ :Font = FONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]

? "=============================================================="
? " DN6 -- DRAKON"
? "=============================================================="

#-- 1. NESTED QUESTIONS -- the shape the whole notation is about -------------
#   Two refusals at different depths. The skewer carries every yes; both
#   noes stand to the right, and the OUTER one stands further out.
o1 = new stzDiagram("signin")
o1.SetNotation(StzDrakonNotation())
o1.AddNodeXTT("t",  "Sign in",          [ :type = "title" ])
o1.AddNodeXTT("ask","Read credentials", [ :type = "input" ])
o1.AddNodeXTT("q1", "Known user?",      [ :type = "question" ])
o1.AddNodeXTT("q2", "Password ok?",     [ :type = "question" ])
o1.AddNodeXTT("ok", "Open session",     [ :type = "action" ])
o1.AddNodeXTT("no1","Report unknown",   [ :type = "action" ])
o1.AddNodeXTT("no2","Report refusal",   [ :type = "action" ])
o1.AddNodeXTT("e",  "Done",             [ :type = "end" ])
o1.AddEdge("t","ask")
o1.AddEdge("ask","q1")
o1.AddEdgeXT("q1","q2","yes")
o1.AddEdgeXT("q1","no1","no")
o1.AddEdgeXT("q2","ok","yes")
o1.AddEdgeXT("q2","no2","no")
o1.AddEdge("ok","e")
o1.AddEdge("no1","e")
o1.AddEdge("no2","e")
o1.ToCanvasXT(OPT)
o1.LastCanvas().ToPNG("drakon_1_signin.png")
? "  nested questions   " + o1.LastCanvas().Width() + "x" +
  o1.LastCanvas().Height()

#-- 2. ONE QUESTION -- the smallest thing the law can be read on -------------
o2 = new stzDiagram("guard")
o2.SetNotation(StzDrakonNotation())
o2.AddNodeXTT("t", "Withdraw",     [ :type = "title" ])
o2.AddNodeXTT("q", "Funds enough?",[ :type = "question" ])
o2.AddNodeXTT("y", "Pay out",      [ :type = "action" ])
o2.AddNodeXTT("n", "Decline",      [ :type = "action" ])
o2.AddNodeXTT("e", "Done",         [ :type = "end" ])
o2.AddEdge("t","q")
o2.AddEdgeXT("q","y","yes")
o2.AddEdgeXT("q","n","no")
o2.AddEdge("y","e")
o2.AddEdge("n","e")
o2.ToCanvasXT(OPT)
o2.LastCanvas().ToPNG("drakon_2_guard.png")
? "  one question       " + o2.LastCanvas().Width() + "x" +
  o2.LastCanvas().Height()

#-- 3. THE ICONS ------------------------------------------------------------
#   DRAKON's vocabulary mapped onto glyphs the renderer already draws,
#   which is DN0's rule for what a glyph IS.
o3 = new stzDiagram("icons")
o3.SetNotation(StzDrakonNotation())
o3.AddNodeXTT("t", "Title",     [ :type = "title" ])
o3.AddNodeXTT("i", "Input",     [ :type = "input" ])
o3.AddNodeXTT("a", "Action",    [ :type = "action" ])
o3.AddNodeXTT("q", "Question",  [ :type = "question" ])
o3.AddNodeXTT("s", "Insertion", [ :type = "insertion" ])
o3.AddNodeXTT("m", "Timer",     [ :type = "timer" ])
o3.AddNodeXTT("e", "End",       [ :type = "end" ])
o3.AddEdge("t","i")  o3.AddEdge("i","a")  o3.AddEdge("a","q")
o3.AddEdgeXT("q","s","yes")  o3.AddEdge("s","m")  o3.AddEdge("m","e")
o3.ToCanvasXT(OPT)
o3.LastCanvas().ToPNG("drakon_3_icons.png")
? "  the icons          " + o3.LastCanvas().Width() + "x" +
  o3.LastCanvas().Height()

? ""
? "wrote drakon_1..drakon_3"
