load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	DN6 -- THE CATALOGUE, drawn against the book's own figures

	The Principal asked for a catalogue covering most of the examples in
	DRAKON: The Human Revolution in Understanding Programs (S. Mitkin,
	2011), so that mastery of the discipline is something SHOWN rather
	than claimed. Each scene below names the figure or the rule it comes
	from, and each is a construct the language has -- not a construct
	this plane found convenient.

	WHAT IS DELIBERATELY ABSENT. Four of the book's figures -- 13, 15,
	20 (left half) and 24 -- exist to show what must NOT be drawn:
	illegal joinings, an arrow pointing at an icon, a Switch with an
	icon between the Select and its Cases. A conformant engine cannot
	produce them, and a catalogue that faked them to look complete would
	be demonstrating the opposite of the thing being demonstrated. They
	are named here instead, and the rules they teach are enforced in
	gg_adversarial's sections 73k through 73v.

	Run:  ring gg_drakon_catalogue.ring
---------------------------------------------------------------------------*/

decimals(2)
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
OPT = [ :Font = FONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]
SIL = [ :Font = FONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20,
        :LayoutMode = :Silhouette ]

? "=============================================================="
? " DN6 -- THE DRAKON CATALOGUE"
? "=============================================================="

#-- 01. Fig 1 -- the simplest diagram ---------------------------------------
#   "The simplest DRAKON diagram." A Title, one Action, an End: entry at
#   the top, exit at the bottom, and one straight skewer between them.
c01 = new stzDiagram("simplest")
c01.SetNotation(StzDrakonNotation())
c01.AddNodeXTT("t", "Sum two numbers", [ :type = "title" ])
c01.AddNodeXTT("a", "result = a + b",  [ :type = "action" ])
c01.AddNodeXTT("e", "End",             [ :type = "end" ])
c01.AddEdge("t","a")  c01.AddEdge("a","e")
c01.ToCanvasXT(OPT)
c01.LastCanvas().ToPNG("cat_01_simplest.png")
? "  01 simplest            " + c01.LastCanvas().Width() + "x" +
  c01.LastCanvas().Height()

#-- 02. Fig 11 -- the If icon ------------------------------------------------
#   "The If icon has one entry, but two exits. The central exit comes out
#   of the bottom of the icon, the right exit comes out of its right
#   side. Placing an exit on the left side is not allowed."
c02 = new stzDiagram("theif")
c02.SetNotation(StzDrakonNotation())
c02.AddNodeXTT("t",  "Go out",           [ :type = "title" ])
c02.AddNodeXTT("q",  "Is it raining?",   [ :type = "question" ])
c02.AddNodeXTT("umb", "Take an umbrella",[ :type = "action" ])
c02.AddNodeXTT("go", "Leave the house",  [ :type = "action" ])
c02.AddNodeXTT("e",  "End",              [ :type = "end" ])
c02.AddEdge("t","q")
c02.AddEdgeXTT("q","umb","yes", [ :exit = :down ])
c02.AddEdgeXTT("q","go","no",   [ :exit = :right ])
c02.AddEdge("umb","go")  c02.AddEdge("go","e")
c02.ToCanvasXT(OPT)
c02.LastCanvas().ToPNG("cat_02_the_if.png")
? "  02 the If icon         " + c02.LastCanvas().Width() + "x" +
  c02.LastCanvas().Height()

#-- 03. Fig 8 -- the rule of secondary routes -------------------------------
#   "The rule of secondary routes: the further to the right -- the worse
#   it is." Three refusals at three depths, and the outermost is the
#   worst thing that can happen.
c03 = new stzDiagram("secondary")
c03.SetNotation(StzDrakonNotation())
c03.AddNodeXTT("t",  "Serve tea",        [ :type = "title" ])
c03.AddNodeXTT("q1", "Cup intact?",      [ :type = "question" ])
c03.AddNodeXTT("q2", "Tea still hot?",   [ :type = "question" ])
c03.AddNodeXTT("q3", "Guest seated?",    [ :type = "question" ])
c03.AddNodeXTT("ok", "Pour and serve",   [ :type = "action" ])
c03.AddNodeXTT("n3", "Wait a moment",    [ :type = "action" ])
c03.AddNodeXTT("n2", "Reheat the pot",   [ :type = "action" ])
c03.AddNodeXTT("n1", "Sweep the pieces", [ :type = "action" ])
c03.AddNodeXTT("e",  "End",              [ :type = "end" ])
c03.AddEdge("t","q1")
c03.AddEdgeXTT("q1","q2","yes", [ :exit = :down ])
c03.AddEdgeXTT("q1","n1","no",  [ :exit = :right ])
c03.AddEdgeXTT("q2","q3","yes", [ :exit = :down ])
c03.AddEdgeXTT("q2","n2","no",  [ :exit = :right ])
c03.AddEdgeXTT("q3","ok","yes", [ :exit = :down ])
c03.AddEdgeXTT("q3","n3","no",  [ :exit = :right ])
c03.AddEdge("ok","e")  c03.AddEdge("n1","e")
c03.AddEdge("n2","e")  c03.AddEdge("n3","e")
c03.ToCanvasXT(OPT)
c03.LastCanvas().ToPNG("cat_03_secondary_routes.png")
? "  03 secondary routes    " + c03.LastCanvas().Width() + "x" +
  c03.LastCanvas().Height()

#-- 04. Fig 16 -- the Insertion icon ----------------------------------------
#   "The Insertion icon is the DRAKON notation for calling another
#   DRAKON diagram as a sub-routine."
c04 = new stzDiagram("insertion")
c04.SetNotation(StzDrakonNotation())
c04.AddNodeXTT("t",  "Print the report", [ :type = "title" ])
c04.AddNodeXTT("g",  "Gather the rows",  [ :type = "action" ])
c04.AddNodeXTT("ins","Format the page",  [ :type = "insertion" ])
c04.AddNodeXTT("s",  "Send to printer",  [ :type = "action" ])
c04.AddNodeXTT("e",  "End",              [ :type = "end" ])
c04.AddEdge("t","g")  c04.AddEdge("g","ins")
c04.AddEdge("ins","s")  c04.AddEdge("s","e")
c04.ToCanvasXT(OPT)
c04.LastCanvas().ToPNG("cat_04_insertion.png")
? "  04 the Insertion       " + c04.LastCanvas().Width() + "x" +
  c04.LastCanvas().Height()

#-- 05. Fig 17 -- the For loop ----------------------------------------------
#   "The For icon is actually two icons: Begin For and End For. The code
#   that runs several times is represented by the icons placed between
#   the Begin For and End For icons."
c05 = new stzDiagram("forloop")
c05.SetNotation(StzDrakonNotation())
c05.AddNodeXTT("t", "Total a basket",  [ :type = "title" ])
c05.AddNodeXTT("f", "for each line",   [ :type = "foreach" ])
c05.AddNodeXTT("p", "Read its price",  [ :type = "action" ])
c05.AddNodeXTT("a", "Add to the total",[ :type = "action" ])
c05.AddNodeXTT("z", "end for",         [ :type = "endforeach" ])
c05.AddNodeXTT("s", "Show the total",  [ :type = "action" ])
c05.AddNodeXTT("e", "End",             [ :type = "end" ])
c05.AddEdge("t","f")  c05.AddEdge("f","p")  c05.AddEdge("p","a")
c05.AddEdge("a","z")
c05.AddEdge("z","f")
c05.AddEdgeXTT("z","s","", [ :exit = :down ])
c05.AddEdge("s","e")
c05.ToCanvasXT(OPT)
c05.LastCanvas().ToPNG("cat_05_for_loop.png")
? "  05 the For loop        " + c05.LastCanvas().Width() + "x" +
  c05.LastCanvas().Height()

#-- 06. Fig 18 -- a For loop with an early exit -----------------------------
#   "The Begin For icon is the only single entry into the loop body.
#   There can be several additional, early exits from the loop body.
#   Early exits come from the conditional icons: If and Switch."
c06 = new stzDiagram("forexit")
c06.SetNotation(StzDrakonNotation())
c06.AddNodeXTT("t", "Scan the file",   [ :type = "title" ])
c06.AddNodeXTT("f", "for each row",    [ :type = "foreach" ])
c06.AddNodeXTT("r", "Read the row",    [ :type = "action" ])
c06.AddNodeXTT("q", "Row readable?",   [ :type = "question" ])
c06.AddNodeXTT("k", "Keep it",         [ :type = "action" ])
c06.AddNodeXTT("z", "end for",         [ :type = "endforeach" ])
c06.AddNodeXTT("bad","Report damage",  [ :type = "action" ])
c06.AddNodeXTT("e", "End",             [ :type = "end" ])
c06.AddEdge("t","f")  c06.AddEdge("f","r")  c06.AddEdge("r","q")
c06.AddEdgeXTT("q","k","yes",   [ :exit = :down ])
c06.AddEdgeXTT("q","bad","no",  [ :exit = :right ])
c06.AddEdge("k","z")
c06.AddEdge("z","f")
c06.AddEdgeXTT("z","e","", [ :exit = :down ])
c06.AddEdge("bad","e")
c06.ToCanvasXT(OPT)
c06.LastCanvas().ToPNG("cat_06_for_early_exit.png")
? "  06 For + early exit    " + c06.LastCanvas().Width() + "x" +
  c06.LastCanvas().Height()

#-- 07. Fig 19a -- the while loop (Question - Action) -----------------------
#   "The If icon can organize a loop in three ways: 1. Question - Action.
#   This is similar to the while loop in programming languages."
c07 = new stzDiagram("whileloop")
c07.SetNotation(StzDrakonNotation())
c07.AddNodeXTT("t", "Drain the queue", [ :type = "title" ])
c07.AddNodeXTT("q", "Anything left?",  [ :type = "question" ])
c07.AddNodeXTT("a", "Handle one item", [ :type = "action" ])
c07.AddNodeXTT("e", "End",             [ :type = "end" ])
c07.AddEdge("t","q")
c07.AddEdgeXTT("q","a","yes", [ :exit = :down ])
c07.AddEdgeXTT("q","e","no",  [ :exit = :right ])
c07.AddEdge("a","q")
c07.ToCanvasXT(OPT)
c07.LastCanvas().ToPNG("cat_07_while.png")
? "  07 while loop          " + c07.LastCanvas().Width() + "x" +
  c07.LastCanvas().Height()

#-- 08. Fig 19b -- the do-until loop (Action - Question) --------------------
#   "2. Action - Question. This is similar to the do-until loop."
c08 = new stzDiagram("dountil")
c08.SetNotation(StzDrakonNotation())
c08.AddNodeXTT("t", "Dial the number", [ :type = "title" ])
c08.AddNodeXTT("a", "Place the call",  [ :type = "action" ])
c08.AddNodeXTT("q", "Answered?",       [ :type = "question" ])
c08.AddNodeXTT("e", "End",             [ :type = "end" ])
c08.AddEdge("t","a")  c08.AddEdge("a","q")
c08.AddEdgeXTT("q","e","yes", [ :exit = :down ])
c08.AddEdgeXTT("q","a","no",  [ :exit = :right ])
c08.ToCanvasXT(OPT)
c08.LastCanvas().ToPNG("cat_08_do_until.png")
? "  08 do-until loop       " + c08.LastCanvas().Width() + "x" +
  c08.LastCanvas().Height()

#-- 09. Fig 19c -- the hybrid loop (Action - Question - Action) -------------
#   "3. Action - Question - Action. This one is called the hybrid loop."
c09 = new stzDiagram("hybrid")
c09.SetNotation(StzDrakonNotation())
c09.AddNodeXTT("t",  "Fill the tank",   [ :type = "title" ])
c09.AddNodeXTT("a1", "Pour a litre",    [ :type = "action" ])
c09.AddNodeXTT("q",  "Tank full?",      [ :type = "question" ])
c09.AddNodeXTT("a2", "Wait for settle", [ :type = "action" ])
c09.AddNodeXTT("e",  "End",             [ :type = "end" ])
c09.AddEdge("t","a1")  c09.AddEdge("a1","q")
c09.AddEdgeXTT("q","e","yes", [ :exit = :down ])
c09.AddEdgeXTT("q","a2","no", [ :exit = :right ])
c09.AddEdge("a2","a1")
c09.ToCanvasXT(OPT)
c09.LastCanvas().ToPNG("cat_09_hybrid.png")
? "  09 hybrid loop         " + c09.LastCanvas().Width() + "x" +
  c09.LastCanvas().Height()

#-- 10. Fig 23 -- the Switch construct --------------------------------------
#   "The Switch construct consists of: one Select icon that contains a
#   question, and two or more Case icons holding possible answers."
c10 = new stzDiagram("switch")
c10.SetNotation(StzDrakonNotation())
c10.AddNodeXTT("t",  "Route the parcel",[ :type = "title" ])
c10.AddNodeXTT("s",  "Destination?",    [ :type = "select" ])
c10.AddNodeXTT("k1", "local",           [ :type = "case" ])
c10.AddNodeXTT("k2", "national",        [ :type = "case" ])
c10.AddNodeXTT("k3", "abroad",          [ :type = "case" ])
c10.AddNodeXTT("d1", "Bike courier",    [ :type = "action" ])
c10.AddNodeXTT("d2", "Post it",         [ :type = "action" ])
c10.AddNodeXTT("d3", "Air freight",     [ :type = "action" ])
c10.AddNodeXTT("e",  "End",             [ :type = "end" ])
c10.AddEdge("t","s")
c10.AddEdge("s","k1")  c10.AddEdge("s","k2")  c10.AddEdge("s","k3")
c10.AddEdge("k1","d1") c10.AddEdge("k2","d2") c10.AddEdge("k3","d3")
c10.AddEdge("d1","e")  c10.AddEdge("d2","e")  c10.AddEdge("d3","e")
c10.ToCanvasXT(OPT)
c10.LastCanvas().ToPNG("cat_10_switch.png")
? "  10 the Switch          " + c10.LastCanvas().Width() + "x" +
  c10.LastCanvas().Height()

#-- 11. Fig 25 -- the Switch loop -------------------------------------------
#   "The rightmost Case icons can lead to some place above the Case icon
#   and form a cycle. This construct is called the Switch loop."
c11 = new stzDiagram("switchloop")
c11.SetNotation(StzDrakonNotation())
c11.AddNodeXTT("t",  "Read a command",  [ :type = "title" ])
c11.AddNodeXTT("rd", "Take one word",   [ :type = "input" ])
c11.AddNodeXTT("s",  "Which command?",  [ :type = "select" ])
c11.AddNodeXTT("k1", "run",             [ :type = "case" ])
c11.AddNodeXTT("k2", "stop",            [ :type = "case" ])
c11.AddNodeXTT("k3", "anything else",   [ :type = "case" ])
c11.AddNodeXTT("d1", "Start the job",   [ :type = "action" ])
c11.AddNodeXTT("d2", "Halt the job",    [ :type = "action" ])
c11.AddNodeXTT("d3", "Say it is unknown",[ :type = "action" ])
c11.AddNodeXTT("e",  "End",             [ :type = "end" ])
c11.AddEdge("t","rd")  c11.AddEdge("rd","s")
c11.AddEdge("s","k1")  c11.AddEdge("s","k2")  c11.AddEdge("s","k3")
c11.AddEdge("k1","d1") c11.AddEdge("k2","d2") c11.AddEdge("k3","d3")
c11.AddEdge("d1","e")  c11.AddEdge("d2","e")
# the loop: the last case goes back above the Select and asks again
c11.AddEdge("d3","rd")
c11.ToCanvasXT(OPT)
c11.LastCanvas().ToPNG("cat_11_switch_loop.png")
? "  11 the Switch loop     " + c11.LastCanvas().Width() + "x" +
  c11.LastCanvas().Height()

#-- 12. Fig 27/28 -- visual logic: AND on the skewer ------------------------
#   "Rule: For AND, put the if icons on the skewer. For OR, arrange the
#   if icons as stair steps." Buying only when BOTH hold.
c12 = new stzDiagram("logicand")
c12.SetNotation(StzDrakonNotation())
c12.AddNodeXTT("t",  "Buy the gadget?",  [ :type = "title" ])
c12.AddNodeXTT("q1", "Looks good?",      [ :type = "question" ])
c12.AddNodeXTT("q2", "Affordable?",      [ :type = "question" ])
c12.AddNodeXTT("yes","Buy it",           [ :type = "action" ])
c12.AddNodeXTT("no", "Walk away",        [ :type = "action" ])
c12.AddNodeXTT("e",  "End",              [ :type = "end" ])
c12.AddEdge("t","q1")
c12.AddEdgeXTT("q1","q2","yes", [ :exit = :down ])
c12.AddEdgeXTT("q1","no","no",  [ :exit = :right ])
c12.AddEdgeXTT("q2","yes","yes",[ :exit = :down ])
c12.AddEdgeXTT("q2","no","no",  [ :exit = :right ])
c12.AddEdge("yes","e")  c12.AddEdge("no","e")
c12.ToCanvasXT(OPT)
c12.LastCanvas().ToPNG("cat_12_logic_and.png")
? "  12 visual AND          " + c12.LastCanvas().Width() + "x" +
  c12.LastCanvas().Height()

#-- 13. Fig 28 -- visual logic: OR as stair steps ---------------------------
#   The mirror pattern: any one of the tests is enough, so the ifs step
#   to the right and their affirmative exits gather on one line.
c13 = new stzDiagram("logicor")
c13.SetNotation(StzDrakonNotation())
c13.AddNodeXTT("t",  "Let them in?",    [ :type = "title" ])
c13.AddNodeXTT("q1", "On the list?",    [ :type = "question" ])
c13.AddNodeXTT("q2", "Has a ticket?",   [ :type = "question" ])
c13.AddNodeXTT("q3", "Knows the host?", [ :type = "question" ])
c13.AddNodeXTT("in", "Open the door",   [ :type = "action" ])
c13.AddNodeXTT("out","Turn them away",  [ :type = "action" ])
c13.AddNodeXTT("e",  "End",             [ :type = "end" ])
c13.AddEdge("t","q1")
c13.AddEdgeXTT("q1","in","yes",  [ :exit = :down ])
c13.AddEdgeXTT("q1","q2","no",   [ :exit = :right ])
c13.AddEdgeXTT("q2","in","yes",  [ :exit = :down ])
c13.AddEdgeXTT("q2","q3","no",   [ :exit = :right ])
c13.AddEdgeXTT("q3","in","yes",  [ :exit = :down ])
c13.AddEdgeXTT("q3","out","no",  [ :exit = :right ])
c13.AddEdge("in","e")  c13.AddEdge("out","e")
c13.ToCanvasXT(OPT)
c13.LastCanvas().ToPNG("cat_13_logic_or.png")
? "  13 visual OR           " + c13.LastCanvas().Width() + "x" +
  c13.LastCanvas().Height()

#-- 14. Fig 2/4 -- branches and the header ----------------------------------
#   "The branch names together with the Begin label are placed in the
#   header of the diagram, which ensures that the summary of the diagram
#   can always be found at the same place." The book's own lunch.
c14 = new stzDiagram("cooklunch")
c14.SetNotation(StzDrakonNotation())
c14.AddNodeXTT("b1", "Salad",           [ :type = "branch", :branchId = 1 ])
c14.AddNodeXTT("w1", "wash vegetables", [ :type = "action" ])
c14.AddNodeXTT("w2", "slice vegetables",[ :type = "action" ])
c14.AddNodeXTT("w3", "blend vegetables",[ :type = "action" ])
c14.AddNodeXTT("a1", "Potatoes",        [ :type = "address" ])
c14.AddNodeXTT("b2", "Potatoes",        [ :type = "branch", :branchId = 2 ])
c14.AddNodeXTT("p1", "peel potatoes",   [ :type = "action" ])
c14.AddNodeXTT("p2", "boil potatoes",   [ :type = "action" ])
c14.AddNodeXTT("p3", "add butter",      [ :type = "action" ])
c14.AddNodeXTT("a2", "Meat",            [ :type = "address" ])
c14.AddNodeXTT("b3", "Meat",            [ :type = "branch", :branchId = 3 ])
c14.AddNodeXTT("m1", "cut in pieces",   [ :type = "action" ])
c14.AddNodeXTT("m2", "stuff with garlic",[ :type = "action" ])
c14.AddNodeXTT("m3", "bake in oven",    [ :type = "action" ])
c14.AddNodeXTT("fin","End",             [ :type = "end" ])
c14.AddEdge("b1","w1")  c14.AddEdge("w1","w2")  c14.AddEdge("w2","w3")
c14.AddEdge("w3","a1")  c14.AddEdge("a1","b2")
c14.AddEdge("b2","p1")  c14.AddEdge("p1","p2")  c14.AddEdge("p2","p3")
c14.AddEdge("p3","a2")  c14.AddEdge("a2","b3")
c14.AddEdge("b3","m1")  c14.AddEdge("m1","m2")  c14.AddEdge("m2","m3")
c14.AddEdge("m3","fin")
c14.ToCanvasXT(SIL)
c14.LastCanvas().ToPNG("cat_14_cook_lunch.png")
? "  14 branches (lunch)    " + c14.LastCanvas().Width() + "x" +
  c14.LastCanvas().Height()

#-- 15. Fig 26 -- the branch loop -------------------------------------------
#   "The next branch can be the same branch or some branch to the left if
#   the intention is to repeat some sequence of actions. The latter case
#   is called the branch loop."
c15 = new stzDiagram("branchloop")
c15.SetNotation(StzDrakonNotation())
c15.AddNodeXTT("b1", "Prepare",         [ :type = "branch", :branchId = 1 ])
c15.AddNodeXTT("s1", "Open the line",   [ :type = "action" ])
c15.AddNodeXTT("x1", "Attempt",         [ :type = "address" ])
c15.AddNodeXTT("b2", "Attempt",         [ :type = "branch", :branchId = 2 ])
c15.AddNodeXTT("s2", "Send the packet", [ :type = "action" ])
c15.AddNodeXTT("q",  "Acknowledged?",   [ :type = "question" ])
c15.AddNodeXTT("x2", "Finish",          [ :type = "address" ])
c15.AddNodeXTT("rt", "Attempt",         [ :type = "address" ])
c15.AddNodeXTT("b3", "Finish",          [ :type = "branch", :branchId = 3 ])
c15.AddNodeXTT("s3", "Close the line",  [ :type = "action" ])
c15.AddNodeXTT("fin","End",             [ :type = "end" ])
c15.AddEdge("b1","s1")  c15.AddEdge("s1","x1")  c15.AddEdge("x1","b2")
c15.AddEdge("b2","s2")  c15.AddEdge("s2","q")
c15.AddEdgeXTT("q","x2","yes", [ :exit = :down ])
c15.AddEdgeXTT("q","rt","no",  [ :exit = :right ])
c15.AddEdge("x2","b3")
# the branch loop: this address names a branch to the LEFT
c15.AddEdge("rt","b2")
c15.AddEdge("b3","s3")  c15.AddEdge("s3","fin")
c15.ToCanvasXT(SIL)
c15.LastCanvas().ToPNG("cat_15_branch_loop.png")
? "  15 the branch loop     " + c15.LastCanvas().Width() + "x" +
  c15.LastCanvas().Height()

#-- 16. The Principal's own sample: advanceStep -----------------------------
#   A Switch whose cases each carry their own nested Ifs -- the hardest
#   shape in the set, and the one he supplied alongside its JavaScript.
c16 = new stzDiagram("advancestep")
c16.SetNotation(StzDrakonNotation())
c16.AddNodeXTT("t",  "advanceStep",       [ :type = "title" ])
c16.AddNodeXTT("s",  "module.state",      [ :type = "select" ])
c16.AddNodeXTT("k1", "playing",           [ :type = "case" ])
c16.AddNodeXTT("k2", "dropping",          [ :type = "case" ])
c16.AddNodeXTT("k3", "finished",          [ :type = "case" ])
c16.AddNodeXTT("p1", "module.projectile", [ :type = "question" ])
c16.AddNodeXTT("p2", "canMoveDown()",     [ :type = "question" ])
c16.AddNodeXTT("p3", "moveDown()",        [ :type = "action" ])
c16.AddNodeXTT("p4", "return getStepPeriod()", [ :type = "action" ])
c16.AddNodeXTT("p5", "freezeProjectile()",[ :type = "action" ])
c16.AddNodeXTT("p6", "return noProjectile()",  [ :type = "action" ])
c16.AddNodeXTT("d1", "canMoveDown()",     [ :type = "question" ])
c16.AddNodeXTT("d2", "moveDown()",        [ :type = "action" ])
c16.AddNodeXTT("d3", "return DropPeriod", [ :type = "action" ])
c16.AddNodeXTT("d4", "freezeProjectile()",[ :type = "action" ])
c16.AddNodeXTT("d5", "return getStepPeriod()", [ :type = "action" ])
c16.AddNodeXTT("f1", "return undefined",  [ :type = "action" ])
c16.AddNodeXTT("e",  "End",               [ :type = "end" ])
c16.AddEdge("t","s")
c16.AddEdge("s","k1")  c16.AddEdge("s","k2")  c16.AddEdge("s","k3")
c16.AddEdge("k1","p1")
c16.AddEdgeXTT("p1","p2","yes", [ :exit = :down ])
c16.AddEdgeXTT("p1","p6","no",  [ :exit = :right ])
c16.AddEdgeXTT("p2","p3","yes", [ :exit = :down ])
c16.AddEdgeXTT("p2","p5","no",  [ :exit = :right ])
c16.AddEdge("p3","p4")  c16.AddEdge("p5","p6")
c16.AddEdge("p4","e")   c16.AddEdge("p6","e")
c16.AddEdge("k2","d1")
c16.AddEdgeXTT("d1","d2","yes", [ :exit = :down ])
c16.AddEdgeXTT("d1","d4","no",  [ :exit = :right ])
c16.AddEdge("d2","d3")  c16.AddEdge("d4","d5")
c16.AddEdge("d3","e")   c16.AddEdge("d5","e")
c16.AddEdge("k3","f1")  c16.AddEdge("f1","e")
c16.ToCanvasXT(OPT)
c16.LastCanvas().ToPNG("cat_16_advance_step.png")
? "  16 advanceStep         " + c16.LastCanvas().Width() + "x" +
  c16.LastCanvas().Height()

#-- 17. The Principal's own sample: NumberToString --------------------------
#   The smallest Switch there is: four answers, four one-line bodies.
c17 = new stzDiagram("numbertostring")
c17.SetNotation(StzDrakonNotation())
c17.AddNodeXTT("t",  "NumberToString", [ :type = "title" ])
c17.AddNodeXTT("s",  "number",         [ :type = "select" ])
c17.AddNodeXTT("k0", "0",              [ :type = "case" ])
c17.AddNodeXTT("k1", "1",              [ :type = "case" ])
c17.AddNodeXTT("k2", "2",              [ :type = "case" ])
c17.AddNodeXTT("k3", "anything else",  [ :type = "case" ])
c17.AddNodeXTT("p0", "print(zero)",    [ :type = "action" ])
c17.AddNodeXTT("p1", "print(one)",     [ :type = "action" ])
c17.AddNodeXTT("p2", "print(two)",     [ :type = "action" ])
c17.AddNodeXTT("p3", "print(a lot)",   [ :type = "action" ])
c17.AddNodeXTT("e",  "End",            [ :type = "end" ])
c17.AddEdge("t","s")
c17.AddEdge("s","k0")  c17.AddEdge("s","k1")
c17.AddEdge("s","k2")  c17.AddEdge("s","k3")
c17.AddEdge("k0","p0") c17.AddEdge("k1","p1")
c17.AddEdge("k2","p2") c17.AddEdge("k3","p3")
c17.AddEdge("p0","e")  c17.AddEdge("p1","e")
c17.AddEdge("p2","e")  c17.AddEdge("p3","e")
c17.ToCanvasXT(OPT)
c17.LastCanvas().ToPNG("cat_17_number_to_string.png")
? "  17 NumberToString      " + c17.LastCanvas().Width() + "x" +
  c17.LastCanvas().Height()

#-- 18. The icon set --------------------------------------------------------
#   Every icon this profile draws, on one skewer, so a reader can check
#   the glyphs against the language's own table rather than against a
#   description of it.
c18 = new stzDiagram("icons")
c18.SetNotation(StzDrakonNotation())
c18.AddNodeXTT("t",  "Title",     [ :type = "title" ])
c18.AddNodeXTT("i",  "Input",     [ :type = "input" ])
c18.AddNodeXTT("o",  "Output",    [ :type = "output" ])
c18.AddNodeXTT("a",  "Action",    [ :type = "action" ])
c18.AddNodeXTT("q",  "Question",  [ :type = "question" ])
c18.AddNodeXTT("sel","Select",    [ :type = "select" ])
c18.AddNodeXTT("cs", "Case",      [ :type = "case" ])
c18.AddNodeXTT("ins","Insertion", [ :type = "insertion" ])
# A SHELF CARRIES TWO TEXTS OR IT IS A BOX. Declared with only a name
# it drew as one compartment, which is the icon with its own rule
# missing -- the thing that makes it a shelf.
c18.AddNodeXTT("sh", "Shelf",     [ :type = "shelf", :value = "what it is" ])
c18.AddNodeXTT("bf", "Begin For", [ :type = "foreach" ])
c18.AddNodeXTT("ef", "End For",   [ :type = "endforeach" ])
c18.AddNodeXTT("tm", "Timer",     [ :type = "timer" ])
c18.AddNodeXTT("pa", "Pause",     [ :type = "pause" ])
c18.AddNodeXTT("br", "Branch",    [ :type = "branch" ])
c18.AddNodeXTT("ad", "Address",   [ :type = "address" ])
c18.AddNodeXTT("e",  "End",       [ :type = "end" ])
c18.AddEdge("t","i")    c18.AddEdge("i","o")    c18.AddEdge("o","a")
c18.AddEdge("a","q")
c18.AddEdgeXTT("q","sel","yes", [ :exit = :down ])
c18.AddEdge("sel","cs") c18.AddEdge("cs","ins")  c18.AddEdge("ins","sh")
c18.AddEdge("sh","bf")  c18.AddEdge("bf","ef")   c18.AddEdge("ef","tm")
c18.AddEdge("tm","pa")  c18.AddEdge("pa","br")   c18.AddEdge("br","ad")
c18.AddEdge("ad","e")
c18.ToCanvasXT(OPT)
c18.LastCanvas().ToPNG("cat_18_icons.png")
? "  18 the icon set        " + c18.LastCanvas().Width() + "x" +
  c18.LastCanvas().Height()

#-- 19. THE SHELF AND THE INSERTION AT WORK ---------------------------------
#   The last two icons of the table this profile had been approximating.
#
#   The INSERTION is a call to another diagram, and DRAKON rules the box
#   once near each end -- the shape every notation has used for a
#   sub-routine since before flowcharts were printed. This profile had
#   reached for UML's COMPONENT because it was the nearest thing already
#   drawn, and left a comment saying so; a component reads as a
#   deployable part rather than a call, and its tabs sit OUTSIDE the
#   body, so a wire arriving at the left border met a tab.
#
#   The SHELF is a box ruled once across the middle holding two texts:
#   what is produced above the rule, and how it is produced below. That
#   is a two-compartment node and this plane already draws one for a UML
#   class -- so the shelf needed no glyph of its own, only the right to
#   NAME its second compartment. The compartment reader had UML's two
#   property names written into it, which is the same enumerated-list
#   fault as the four layout modes and the one shape called "diamond",
#   met a third time in a week.
c19 = new stzDiagram("shelfwork")
c19.SetNotation(StzDrakonNotation())
c19.AddNodeXTT("t",  "Price a basket",   [ :type = "title" ])
c19.AddNodeXTT("rd", "Read the lines",   [ :type = "input" ])
c19.AddNodeXTT("ins","Apply the tariff", [ :type = "insertion" ])
c19.AddNodeXTT("s1", "net",              [ :type = "shelf",
                                           :value = "sum of the lines" ])
c19.AddNodeXTT("s2", "total",            [ :type = "shelf",
                                           :value = "net + tax" ])
c19.AddNodeXTT("ou", "Show the total",   [ :type = "output" ])
c19.AddNodeXTT("e",  "End",              [ :type = "end" ])
c19.AddEdge("t","rd")   c19.AddEdge("rd","ins")  c19.AddEdge("ins","s1")
c19.AddEdge("s1","s2")  c19.AddEdge("s2","ou")   c19.AddEdge("ou","e")
c19.ToCanvasXT(OPT)
c19.LastCanvas().ToPNG("cat_19_shelf_insertion.png")
? "  19 shelf and insertion " + c19.LastCanvas().Width() + "x" +
  c19.LastCanvas().Height()

#-- 20. THE REAL-TIME ICONS, AND THE LAW THAT MAKES THEM A NOTATION ----------
#   The plan of record named these as the plane's last gap in these
#   words: they "are declared as kinds and draw as sensible shapes; none
#   of them has a LAW yet, which is the difference between a vocabulary
#   and a notation."
#
#   THE LAW IS IN THE MACROICON TABLE, thirteen rows of it. Every row of
#   the form "X by timer" -- action, shelf, fork, switch, input, output,
#   insertion, parallel process -- draws the timer trapezoid ATTACHED TO
#   THE LEFT of the icon it governs, on that icon's own row. Not above
#   it, and not in the flow.
#
#   That is the whole difference between having the icon and having the
#   construct. Drawn in sequence a timer says "wait, then do this",
#   which is a step. Drawn beside, it says "this step is governed by a
#   deadline", which is a property of the step. Those are different
#   algorithms, and the picture has to be able to tell them apart.
#
#   Three of these icons had also been drawn as HEXAGONS -- the
#   question's glyph -- so timer, pause and duration all wore the shape
#   that means "answer yes or no", and par wore the action's box.
c20 = new stzDiagram("realtime")
c20.SetNotation(StzDrakonNotation())
c20.AddNodeXTT("t",  "Poll the sensor",  [ :type = "title" ])
c20.AddNodeXTT("rd", "Read the value",   [ :type = "action" ])
c20.AddNodeXTT("tm", "500 ms",           [ :type = "timer" ])
c20.AddNodeXTT("pub","Publish the run",  [ :type = "par" ])
c20.AddNodeXTT("st", "Settle",           [ :type = "pause" ])
c20.AddNodeXTT("wr", "Write the log",    [ :type = "action" ])
c20.AddNodeXTT("e",  "Done",             [ :type = "end" ])
c20.AddEdge("t","rd")   c20.AddEdge("rd","pub")
c20.AddEdge("pub","wr") c20.AddEdge("wr","e")
# the two attachments: each governs the icon it points at, and neither
# is a step in the sequence
c20.AddEdge("tm","rd")
c20.AddEdge("st","wr")
c20.ToCanvasXT(OPT)
c20.LastCanvas().ToPNG("cat_20_realtime.png")
? "  20 the real-time set  " + c20.LastCanvas().Width() + "x" +
  c20.LastCanvas().Height()

? ""
? "wrote cat_01 .. cat_20"
