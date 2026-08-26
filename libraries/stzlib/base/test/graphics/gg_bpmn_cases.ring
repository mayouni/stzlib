load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	BUSINESS PROCESSES FROM PRACTICE -- BPMN under its own notation

	Five processes a working analyst actually draws, through the one
	renderer, governed by the BPMN profile (DN3a).

	WHAT THE PICTURES ARE MEANT TO SHOW:

	  1. a three-way decision -- one question, three answers, one moment
	  2. a rework loop -- the correction that runs backwards
	  3. waiting -- a timer, an event, and a process parked
	  4. compensation -- undoing what was already done
	  5. THE COLOUR LAW -- and it is the strongest one in this library:
	     white by default, and the ONLY thing that colours a node is a
	     verdict from an analyzer. Four of these drawings have no colour
	     in them, which is the notation saying there is nothing wrong.
	     The fifth carries two verdicts, and they are the only thing a
	     reader's eye is asked to go to.

	Run:  ring gg_bpmn_cases.ring
---------------------------------------------------------------------------*/

decimals(2)
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
OPT = [ :Font = FONT, :NodeWidth = 132, :NodeHeight = 52, :FontSize = 15 ]

? "=============================================================="
? " BUSINESS PROCESSES, UNDER BPMN'S NOTATION"
? "=============================================================="

#-- 1. HIRING ---------------------------------------------------------------
#   One question with three answers. They sit in one column because they
#   happen at one moment -- there is no order between "hired", "held" and
#   "rejected", and a picture that staggered them would invent one.
o1 = new stzWorkflow("hiring")
o1.SetWorkflowType("bpmn")
o1.AddStateXTT("s", "", [ :type = "entry" ])
o1.AddStateXTT("screen", "Screen CV", [ :type = "human" ])
o1.AddStateXTT("iview", "Interview", [ :type = "human" ])
o1.AddStateXTT("decide", "Decision", [ :type = "gateway" ])
o1.AddStateXTT("offer", "Send Offer", [ :type = "invoke" ])
o1.AddStateXTT("hired", "Hired", [ :type = "terminal" ])
o1.AddStateXTT("held", "Kept on File", [ :type = "terminal" ])
o1.AddStateXTT("nope", "Rejected", [ :type = "terminal" ])
o1.AddTransition("s", "screen", "")
o1.AddTransition("screen", "iview", "shortlisted")
o1.AddTransition("iview", "decide", "interviewed")
o1.AddTransition("decide", "offer", "yes")
o1.AddTransition("decide", "held", "maybe")
o1.AddTransition("decide", "nope", "no")
o1.AddTransition("offer", "hired", "accepted")
o1.ToCanvasXT(OPT)
o1.LastCanvas().ToPNG("bpmn_1_hiring.png")
? "  1. hiring           " + o1.LastCanvas().Width() + "x" +
  o1.LastCanvas().Height() + "   findings " + len(o1.NotationO().Check(o1))

#-- 2. AN EXPENSE CLAIM -----------------------------------------------------
#   The rework loop is the whole point of the drawing: a claim can circle
#   between Review and Correct for as long as it takes, and the line that
#   says so runs BACKWARDS -- which is the one direction a reader has to
#   be shown rather than told.
o2 = new stzWorkflow("expense")
o2.SetWorkflowType("bpmn")
o2.AddStateXTT("s", "", [ :type = "entry" ])
o2.AddStateXTT("file", "File Claim", [ :type = "human" ])
o2.AddStateXTT("review", "Review", [ :type = "human" ])
o2.AddStateXTT("ok", "Approved?", [ :type = "gateway" ])
o2.AddStateXTT("fix", "Correct", [ :type = "human" ])
o2.AddStateXTT("pay", "Reimburse", [ :type = "invoke" ])
o2.AddStateXTT("paid", "Paid", [ :type = "terminal" ])
o2.AddTransition("s", "file", "")
o2.AddTransition("file", "review", "filed")
o2.AddTransition("review", "ok", "reviewed")
o2.AddTransition("ok", "pay", "approved")
o2.AddTransition("ok", "fix", "needs work")
o2.AddTransition("fix", "review", "resubmitted")
o2.AddTransition("pay", "paid", "transferred")
o2.ToCanvasXT(OPT)
o2.LastCanvas().ToPNG("bpmn_2_expense.png")
? "  2. expense claim    " + o2.LastCanvas().Width() + "x" +
  o2.LastCanvas().Height() + "   findings " + len(o2.NotationO().Check(o2))

#-- 3. AN INSURANCE CLAIM ---------------------------------------------------
#   Three ways of waiting, and BPMN distinguishes them because they fail
#   differently: a TIMER waits for the clock, an EVENT waits for the
#   world, and a SUSPENSION is a process parked -- not finished, and not
#   running either.
o3 = new stzWorkflow("claim")
o3.SetWorkflowType("bpmn")
o3.AddStateXTT("s", "", [ :type = "entry" ])
o3.AddStateXTT("lodge", "Lodge Claim", [ :type = "invoke" ])
o3.AddStateXTT("docs", "Await Documents", [ :type = "event-wait" ])
o3.AddStateXTT("assess", "Assess", [ :type = "human" ])
o3.AddStateXTT("cool", "Cooling Period", [ :type = "timer-wait" ])
o3.AddStateXTT("g", "Complete?", [ :type = "gateway" ])
o3.AddStateXTT("settle", "Settle", [ :type = "invoke" ])
o3.AddStateXTT("done", "Settled", [ :type = "terminal" ])
o3.AddStateXTT("park", "Awaiting Client", [ :type = "suspension" ])
o3.AddTransition("s", "lodge", "")
o3.AddTransition("lodge", "docs", "lodged")
o3.AddTransition("docs", "g", "received")
o3.AddTransition("g", "assess", "complete")
o3.AddTransition("g", "park", "incomplete")
o3.AddTransition("assess", "cool", "assessed")
o3.AddTransition("cool", "settle", "14 days")
o3.AddTransition("settle", "done", "paid")
o3.ToCanvasXT(OPT)
o3.LastCanvas().ToPNG("bpmn_3_claim.png")
? "  3. insurance claim  " + o3.LastCanvas().Width() + "x" +
  o3.LastCanvas().Height() + "   findings " + len(o3.NotationO().Check(o3))

#-- 4. ORDER FULFILMENT, WITH COMPENSATION ----------------------------------
#   Compensation is the thing BPMN has that a flowchart does not: undoing
#   work that already succeeded, because something LATER failed. It is not
#   an error path -- the payment did go through -- it is the reversal.
o4 = new stzWorkflow("fulfil")
o4.SetWorkflowType("bpmn")
o4.AddStateXTT("s", "", [ :type = "entry" ])
o4.AddStateXTT("charge", "Charge Card", [ :type = "invoke" ])
o4.AddStateXTT("reserve", "Reserve Stock", [ :type = "invoke" ])
o4.AddStateXTT("g", "Reserved?", [ :type = "gateway" ])
o4.AddStateXTT("ship", "Ship", [ :type = "invoke" ])
o4.AddStateXTT("refund", "Refund Card", [ :type = "compensate" ])
o4.AddStateXTT("done", "Delivered", [ :type = "terminal" ])
o4.AddStateXTT("undone", "Order Reversed", [ :type = "terminal" ])
o4.AddTransition("s", "charge", "")
o4.AddTransition("charge", "reserve", "charged")
o4.AddTransition("reserve", "g", "attempted")
o4.AddTransition("g", "ship", "yes")
o4.AddTransition("g", "refund", "no")
o4.AddTransition("ship", "done", "dispatched")
o4.AddTransition("refund", "undone", "refunded")
o4.ToCanvasXT(OPT)
o4.LastCanvas().ToPNG("bpmn_4_compensation.png")
? "  4. compensation     " + o4.LastCanvas().Width() + "x" +
  o4.LastCanvas().Height() + "   findings " + len(o4.NotationO().Check(o4))

#-- 5. THE COLOUR LAW, IN ACTION --------------------------------------------
#   The four drawings above have no colour in them. That is not an
#   omission -- it is the notation saying there is nothing wrong.
#
#   Here an analyzer has returned two verdicts, and they are the only
#   colour on the page, so the reader's eye has exactly two places to go.
#   L17 asks for the verdict in THREE channels at once -- fill, a heavier
#   border, and a mark in the text -- because a print theme paints every
#   fill white and a verdict carried only by colour would vanish on
#   paper. The mark travels in the label here, which is the channel the
#   house face has.
o5 = new stzWorkflow("audited")
o5.SetWorkflowType("bpmn")
o5.AddStateXTT("s", "", [ :type = "entry" ])
o5.AddStateXTT("intake", "Intake", [ :type = "invoke" ])
o5.AddStateXTT("verify", "(?) Verify Identity", [ :type = "human",
	:color = "Warning.Solid" ])
o5.AddStateXTT("g", "Approved?", [ :type = "gateway" ])
o5.AddStateXTT("open", "(!) Open Account", [ :type = "invoke",
	:color = "Danger.Solid" ])
o5.AddStateXTT("decline", "Declined", [ :type = "terminal" ])
o5.AddStateXTT("live", "Account Live", [ :type = "terminal" ])
o5.AddTransition("s", "intake", "")
o5.AddTransition("intake", "verify", "received")
o5.AddTransition("verify", "g", "verified")
o5.AddTransition("g", "open", "yes")
o5.AddTransition("g", "decline", "no")
o5.AddTransition("open", "live", "opened")
o5.ToCanvasXT(OPT)
o5.LastCanvas().ToPNG("bpmn_5_verdicts.png")
? "  5. two verdicts     " + o5.LastCanvas().Width() + "x" +
  o5.LastCanvas().Height() + "   findings " + len(o5.NotationO().Check(o5))

? ""
? "wrote bpmn_1..bpmn_5"
