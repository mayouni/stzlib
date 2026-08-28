load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	SEQUENCE DIAGRAMS -- DN4c, and the plan's sharpest kill criterion

	The plan attached this one to sequence and to nothing else:

	    "Its y-axis is TIME and its x-axis is participants. That is not a
	     graph layout, it is a schedule. If it cannot express as a layout
	     MODE over the one renderer -- the way :Modes and :Ring do -- it
	     is a second renderer wearing a profile's clothes, and the plan
	     says so. Measured when built, never before."

	MEASURED. IT EXPRESSES, and the reason is that the two axes are not
	symmetrical. Only ONE of them belongs to the nodes: participants
	stand side by side, a single row, and the mode that produces it is
	four lines of stzGraphCanvas. The other axis belongs to the MESSAGES,
	and a message is an edge -- its place comes from its ordinal in the
	model, the same way a lane's depth or a summit's side does. The time
	axis was never a layout question.

	WHAT IT COST, and each entered the way the earlier domains did:

	  the lifeline    a node property, drawn by the node pass, the way a
	                  class's compartments are
	  the message     one more branch in the edge loop that already had
	                  four -- self-loop, routed, twin, generic
	  the reply       DN4a's dashed stroke, unchanged
	  the row         _LayoutSequence(), four lines

	No second draw loop, which is the criterion the plan actually named.

	AND ONE THING THE MODEL OWED, found by the ordinary case. A checkout
	calls Inventory twice -- reserve, then commit -- and stzGraph refused
	the second, because it is a SIMPLE graph so that counts, paths and
	metrics stay true. That refusal is CORRECT and was not weakened.
	Who-talks-to-whom is a relation and repeats zero times; what-was-said
	is a sequence over it and repeats freely. So messages became their
	own ordered list -- AddMessage -- which also ensures the relation
	exists. The graph stays true and the picture became possible, with
	neither giving ground.

	Run:  ring gg_uml_sequence.ring
---------------------------------------------------------------------------*/

decimals(2)
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
OPT = [ :Font = FONT, :NodeWidth = 130, :NodeHeight = 52, :FontSize = 14 ]

? "=============================================================="
? " UML SEQUENCE -- DN4c"
? "=============================================================="

#-- 1. A LOGIN --------------------------------------------------------------
#   The plainest sequence there is, and the one every reader already
#   knows: a person, a form, a service, a store. Written with AddEdge,
#   because an author whose pairs never repeat never meets the message
#   list and should not have to learn it to draw this.
o1 = new stzDiagram("login")
o1.SetNotation(StzUmlSequenceNotation())
o1.AddNodeXTT("user", "User", [ :type = "actor" ])
o1.AddNodeXTT("ui", ":LoginForm", [ :type = "participant" ])
o1.AddNodeXTT("auth", ":AuthService", [ :type = "participant" ])
o1.AddNodeXTT("db", ":UserStore", [ :type = "participant" ])
o1.AddEdgeXT("user", "ui", "enters credentials")
o1.AddEdgeXT("ui", "auth", "authenticate(u, p)")
o1.AddEdgeXT("auth", "db", "findByName(u)")
o1.AddEdgeXT("db", "auth", "user record")
o1.AddEdgeXT("auth", "auth", "verify hash")
o1.AddEdgeXT("auth", "ui", "token")
o1.AddEdgeXT("ui", "user", "welcome page")
o1.ToCanvasXT(OPT)
o1.LastCanvas().ToPNG("umls_1_login.png")
? "  login         " + o1.LastCanvas().Width() + "x" +
  o1.LastCanvas().Height()

#-- 2. A CHECKOUT -----------------------------------------------------------
#   The case that needed the message list: Checkout speaks to Inventory
#   twice. Replies are dashed, which is what separates "do this" from
#   "here is the answer" without the reader counting arrows.
o2 = new stzDiagram("checkout")
o2.SetNotation(StzUmlSequenceNotation())
o2.AddNodeXTT("c", "Customer", [ :type = "actor" ])
o2.AddNodeXTT("shop", ":Checkout", [ :type = "participant" ])
o2.AddNodeXTT("stock", ":Inventory", [ :type = "participant" ])
o2.AddNodeXTT("pay", ":PaymentGw",
	[ :type = "participant", :color = "Focus.Surface" ])
o2.AddMessage("c", "shop", "checkout()")
o2.AddMessage("shop", "stock", "reserve(items)")
o2.AddMessageXT("stock", "shop", "reserved", [ :kind = "return" ])
o2.AddMessage("shop", "pay", "charge(total)")
o2.AddMessage("pay", "pay", "3-D Secure")
o2.AddMessageXT("pay", "shop", "approved", [ :kind = "return" ])
o2.AddMessage("shop", "stock", "commit(items)")
o2.AddMessageXT("stock", "shop", "committed", [ :kind = "return" ])
o2.AddMessageXT("shop", "c", "order confirmed", [ :kind = "return" ])
o2.ToCanvasXT(OPT)
o2.LastCanvas().ToPNG("umls_2_checkout.png")
? "  checkout      " + o2.LastCanvas().Width() + "x" +
  o2.LastCanvas().Height()

#-- 3. A RETRY --------------------------------------------------------------
#   The same pair, four times, in both directions. A renderer that pairs
#   an edge with its opposite draws this as two hooked routes and loses
#   six messages; a sequence has no twins, because a reply is a moment of
#   its own and not the other rail of one relationship.
o3 = new stzDiagram("retry")
o3.SetNotation(StzUmlSequenceNotation())
o3.AddNodeXTT("cli", ":Client", [ :type = "participant" ])
o3.AddNodeXTT("api", ":Api", [ :type = "participant" ])
o3.AddMessage("cli", "api", "GET /report")
o3.AddMessageXT("api", "cli", "503 unavailable", [ :kind = "return" ])
o3.AddMessage("cli", "cli", "back off 2s")
o3.AddMessage("cli", "api", "GET /report")
o3.AddMessageXT("api", "cli", "503 unavailable", [ :kind = "return" ])
o3.AddMessage("cli", "cli", "back off 4s")
o3.AddMessage("cli", "api", "GET /report")
o3.AddMessageXT("api", "cli", "200 OK", [ :kind = "return" ])
o3.ToCanvasXT(OPT)
o3.LastCanvas().ToPNG("umls_3_retry.png")
? "  retry         " + o3.LastCanvas().Width() + "x" +
  o3.LastCanvas().Height()

? ""
? "wrote umls_1..umls_3"
