load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	A BUSINESS PROCESS, DRAWN TWICE ON PURPOSE -- DN3

	BPMN is the first domain in this library that already HAD a law when
	its profile arrived: a written, versioned specification with a second
	conforming implementation in another repository and a digest the two
	are held to. So the profile did not write BPMN's law. It lifted BPMN's
	VOCABULARY out of the one renderer that held it privately, so that the
	two faces cannot come to disagree about what a gateway looks like.

	THE CONFORMANCE FACE -- stzBpmnDiagram -- answers the digest and the
	consumer contract: stable ids, class tokens, BPMN's own task markers,
	a thick ring, a dashed double circle.

	THE HOUSE FACE -- this file -- draws the same process through the one
	renderer, under the visual contract every other domain obeys.

	Both read the same vocabulary. Neither is a copy of the other.

	Run:  ring gg_bpmn_process.ring
---------------------------------------------------------------------------*/

decimals(2)
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")

? "=============================================================="
? " A BUSINESS PROCESS UNDER BPMN'S NOTATION"
? "=============================================================="

o = new stzWorkflow("order")
o.SetWorkflowType("bpmn")

# L16 -- NOTHING HERE NAMES A COLOUR. White is the law: the only thing
# that colours a node is a verdict from an analyzer, so a drawing with
# no colour in it is a drawing with nothing wrong.
o.AddStateXTT("s", "", [ :type = "entry" ])
o.AddStateXTT("recv", "Receive Order", [ :type = "invoke" ])
o.AddStateXTT("check", "Check Stock", [ :type = "gateway" ])
o.AddStateXTT("pack", "Pack", [ :type = "human" ])
o.AddStateXTT("bill", "Bill", [ :type = "invoke" ])
o.AddStateXTT("wait", "Await Payment", [ :type = "timer-wait" ])
o.AddStateXTT("done", "Shipped", [ :type = "terminal" ])
o.AddStateXTT("nope", "Out of Stock", [ :type = "terminal" ])

o.AddTransition("s", "recv", "")
o.AddTransition("recv", "check", "received")
o.AddTransition("check", "pack", "in stock")
o.AddTransition("check", "nope", "none left")
o.AddTransition("pack", "bill", "packed")
o.AddTransition("bill", "wait", "invoiced")
o.AddTransition("wait", "done", "paid")

? "  notation      " + o.NotationO().Name_() +
  "   (closed: " + o.NotationO().IsClosed() + ")"
? "  findings      " + len(o.NotationO().Check(o))

o.ToCanvasXT([ :Font = FONT, :NodeWidth = 132, :NodeHeight = 52,
	:FontSize = 15 ])
o.LastCanvas().ToPNG("bpmn_order.png")
? "  canvas        " + o.LastCanvas().Width() + "x" +
  o.LastCanvas().Height()

# WHAT THE PROFILE REFUSES, and the editor inherits it free: a link a
# rule forbids is refused AT THE GESTURE, before it is ever drawn.
? ""
? "  a flow INTO a start event  : " +
  iif(o.NotationO().MayLink(o, "recv", "s"), "allowed", "REFUSED")
? "  a flow OUT of an end event : " +
  iif(o.NotationO().MayLink(o, "done", "recv"), "allowed", "REFUSED")
? "  an ordinary sequence flow  : " +
  iif(o.NotationO().MayLink(o, "recv", "pack"), "allowed", "REFUSED")

? ""
? "wrote bpmn_order.png"
