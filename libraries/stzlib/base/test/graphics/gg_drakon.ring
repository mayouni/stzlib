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

#-- 4. THE SILHOUETTE -- DN6b -----------------------------------------------
#   An algorithm too large for one skewer. Several skewers side by side,
#   each under its own NAME, and control leaves the foot of one to resume
#   at the head of another -- written as an ADDRESS, not drawn, which is
#   why a silhouette has no long connecting lines to cross.
#
#   Written LARGE on purpose. The measurement that cleared this form also
#   said the plane's own fixtures average 2.5 branches, which is too few
#   to need it: a feature demonstrated only on cases that do not want it
#   is not demonstrated.
o4 = new stzDiagram("order")
o4.SetNotation(StzDrakonNotation())

o4.AddNodeXTT("b1", "Take the order",  [ :type = "branch" ])
o4.AddNodeXTT("read", "Read basket",   [ :type = "input" ])
o4.AddNodeXTT("q1", "Basket empty?",   [ :type = "question" ])
o4.AddNodeXTT("warn", "Say so",        [ :type = "action" ])
o4.AddNodeXTT("a1", "Charge",          [ :type = "address" ])

o4.AddNodeXTT("b2", "Charge",          [ :type = "branch" ])
o4.AddNodeXTT("auth", "Authorise card",[ :type = "action" ])
o4.AddNodeXTT("q2", "Authorised?",     [ :type = "question" ])
o4.AddNodeXTT("decl", "Record refusal",[ :type = "action" ])
o4.AddNodeXTT("a2", "Ship",            [ :type = "address" ])

o4.AddNodeXTT("b3", "Ship",            [ :type = "branch" ])
o4.AddNodeXTT("pack", "Pack",          [ :type = "action" ])
o4.AddNodeXTT("send", "Hand to carrier",[ :type = "action" ])
o4.AddNodeXTT("a3", "End",             [ :type = "address" ])

o4.AddEdge("b1","read")   o4.AddEdge("read","q1")
o4.AddEdgeXT("q1","a1","no")   o4.AddEdgeXT("q1","warn","yes")
o4.AddEdge("warn","a1")
o4.AddEdge("a1","b2")

o4.AddEdge("b2","auth")   o4.AddEdge("auth","q2")
o4.AddEdgeXT("q2","a2","yes")  o4.AddEdgeXT("q2","decl","no")
o4.AddEdge("decl","a2")
o4.AddEdge("a2","b3")

o4.AddEdge("b3","pack")   o4.AddEdge("pack","send")
o4.AddEdge("send","a3")

o4.ToCanvasXT([ :Font = FONT, :NodeWidth = 150, :NodeHeight = 56,
                :FontSize = 20, :LayoutMode = :Silhouette ])
o4.LastCanvas().ToPNG("drakon_4_silhouette.png")
? "  the silhouette     " + o4.LastCanvas().Width() + "x" +
  o4.LastCanvas().Height()

#-- 5. THE EXITS ARE DECLARED, NOT GUESSED -- DN6c ---------------------------
#   Learned from DRAKON's own engine rather than from its pictures.
#   DrakonWidget gives every icon exactly two exits and fixes what each
#   MEANS: `one` is the next item BELOW, `two` the next to the RIGHT. A
#   question is not two arrows to be sorted out by reading their labels.
#
#   THIS SCENE IS BUILT SO THE WORDS MISLEAD. The main path leaves by
#   "insufficient" and the branch by "ok" -- a reading of the wording puts
#   the skewer through the branch and is confident about it. The declared
#   exit puts it right, and that is the difference between a language and
#   a heuristic.
o5 = new stzDiagram("declared")
o5.SetNotation(StzDrakonNotation())
o5.AddNodeXTT("t",  "Top up",          [ :type = "title" ])
o5.AddNodeXTT("q",  "Balance?",        [ :type = "question" ])
o5.AddNodeXTT("add","Add funds",       [ :type = "action" ])
o5.AddNodeXTT("skip","Nothing to do",  [ :type = "action" ])
o5.AddNodeXTT("e",  "Done",            [ :type = "end" ])
o5.AddEdge("t","q")
o5.AddEdgeXTT("q","add","insufficient", [ :exit = :down ])
o5.AddEdgeXTT("q","skip","ok",          [ :exit = :right ])
o5.AddEdge("add","e")
o5.AddEdge("skip","e")
o5.ToCanvasXT(OPT)
o5.LastCanvas().ToPNG("drakon_5_declared.png")
? "  declared exits     " + o5.LastCanvas().Width() + "x" +
  o5.LastCanvas().Height()

#-- 6. THE LOOP -- DN6d ------------------------------------------------------
#   DRAKON has foreach and this library had no loop at all. The gap was
#   invisible from the pictures being corrected, because not one of them
#   looped, and it took reading the language's own icon list to see that
#   a whole construct was missing rather than merely unpolished.
#
#   Three separate defects stood between the model and this picture, and
#   each hid the next:
#
#     the two-node cycle was claimed by the PAIR rule and drawn as two
#     arrows side by side -- right for a call and its reply, and for a
#     loop it is the same ink pointing both ways
#
#     the return then routed generically and left the paper on the right
#
#     the loop icon was told to hold its name and given a box the name
#     did not fit, so the name went outside onto the return wires
#
#   What it draws now is DRAKON's own shape: down out of the body, left
#   into a lane clear of everything, up, and in at the icon's SIDE --
#   which is how a reader tells a re-entry from the flow coming down.
o6 = new stzDiagram("total")
o6.SetNotation(StzDrakonNotation())
o6.AddNodeXTT("t","Total a basket", [ :type = "title" ])
o6.AddNodeXTT("f","for each line",  [ :type = "foreach" ])
o6.AddNodeXTT("a","Add its price",  [ :type = "action" ])
o6.AddNodeXTT("e","Done",           [ :type = "end" ])
o6.AddEdge("t","f")
o6.AddEdgeXTT("f","a","", [ :exit = :down ])
o6.AddEdge("a","f")
o6.AddEdgeXTT("f","e","", [ :exit = :right ])
o6.ToCanvasXT(OPT)
o6.LastCanvas().ToPNG("drakon_6_loop.png")
? "  the loop           " + o6.LastCanvas().Width() + "x" +
  o6.LastCanvas().Height()

#-- 7. SELECT AND CASE -- DN6e -----------------------------------------------
#   A three-way choice, which the language has and this plane could not
#   draw at all: two of the three cases came out at the SAME coordinates,
#   so "national" and "abroad" printed on top of each other as
#   "natiobroadl" and neither word existed on the paper.
#
#   The cause was one word doing two jobs. A branch's column was "one
#   plus the number of branches nested inside it", which orders
#   alternatives that CONTAIN one another and says nothing about peers:
#   a select's cases leave the same icon at the same moment and rejoin at
#   the same place, so every one of them counted zero and every one of
#   them claimed the first column. The comment above that code said its
#   intent was to COLOUR the intervals; a count is not a colouring.
#
#   The second half was the same word again: a branch is a CHAIN, not a
#   node. Every fixture until now had a single icon standing beside the
#   line, so "branch" and "node" agreed everywhere -- and the moment a
#   case had a body under it, the case went in one column and the step it
#   selects went in another.
o7 = new stzDiagram("route")
o7.SetNotation(StzDrakonNotation())
o7.AddNodeXTT("t", "Route the parcel", [ :type = "title" ])
o7.AddNodeXTT("s", "Destination?",     [ :type = "select" ])
o7.AddNodeXTT("c1","local",            [ :type = "case" ])
o7.AddNodeXTT("c2","national",         [ :type = "case" ])
o7.AddNodeXTT("c3","abroad",           [ :type = "case" ])
o7.AddNodeXTT("a1","Bike courier",     [ :type = "action" ])
o7.AddNodeXTT("a2","Post",             [ :type = "action" ])
o7.AddNodeXTT("a3","Air freight",      [ :type = "action" ])
o7.AddNodeXTT("e", "Done",             [ :type = "end" ])
o7.AddEdge("t","s")
o7.AddEdge("s","c1")   o7.AddEdge("s","c2")   o7.AddEdge("s","c3")
o7.AddEdge("c1","a1")  o7.AddEdge("c2","a2")  o7.AddEdge("c3","a3")
o7.AddEdge("a1","e")   o7.AddEdge("a2","e")   o7.AddEdge("a3","e")
o7.ToCanvasXT(OPT)
o7.LastCanvas().ToPNG("drakon_7_select.png")
? "  select and case    " + o7.LastCanvas().Width() + "x" +
  o7.LastCanvas().Height()

#-- 8. THE BRANCHES ARE ORDERED BY branchId -- DN6f --------------------------
#   DRAKON carries a branchId on every branch: the columns run in
#   ascending order of it, and the FIRST icon of the silhouette is the
#   lowest -- which is how a reader knows where the algorithm begins.
#
#   This library read the order the branch nodes happened to be WRITTEN
#   in, which gives the right picture until somebody inserts a phase, and
#   gives no way at all to say "this one is the entry" except by moving
#   lines of source. Here the branches are declared backwards on purpose:
#   Ship, then Charge, then Take the order. The ids put them right.
o8 = new stzDiagram("ordered")
o8.SetNotation(StzDrakonNotation())
o8.AddNodeXTT("b3","Ship",           [ :type = "branch", :branchId = 3 ])
o8.AddNodeXTT("pack","Pack",         [ :type = "action" ])
o8.AddNodeXTT("a3","End",            [ :type = "address" ])
o8.AddNodeXTT("b2","Charge",         [ :type = "branch", :branchId = 2 ])
o8.AddNodeXTT("auth","Authorise card",[ :type = "action" ])
o8.AddNodeXTT("a2","Ship",           [ :type = "address" ])
o8.AddNodeXTT("b1","Take the order", [ :type = "branch", :branchId = 1 ])
o8.AddNodeXTT("read","Read basket",  [ :type = "input" ])
o8.AddNodeXTT("a1","Charge",         [ :type = "address" ])
o8.AddEdge("b1","read")  o8.AddEdge("read","a1")  o8.AddEdge("a1","b2")
o8.AddEdge("b2","auth")  o8.AddEdge("auth","a2")  o8.AddEdge("a2","b3")
o8.AddEdge("b3","pack")  o8.AddEdge("pack","a3")
o8.ToCanvasXT([ :Font = FONT, :NodeWidth = 150, :NodeHeight = 56,
                :FontSize = 20, :LayoutMode = :Silhouette ])
o8.LastCanvas().ToPNG("drakon_8_branchid.png")
? "  branchId ordering  " + o8.LastCanvas().Width() + "x" +
  o8.LastCanvas().Height()
