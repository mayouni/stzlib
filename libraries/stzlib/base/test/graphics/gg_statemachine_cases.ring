load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	STATE MACHINES FROM PRACTICE -- what the engine is for

	Six machines a working programmer actually writes, drawn by the mode
	template. The point is not that they render: it is what a reader can
	SEE without being told.

	COLOUR CARRIES THE MEANING, in the house roles:

	    Info      an ordinary state, carrying no urgency of its own
	    Success   somewhere the work ended well
	    Danger    somewhere it ended badly
	    Warning   somewhere it is waiting on the world
	    Muted     a live thing that is temporarily not live
	    Focus     LOOK HERE -- magenta, the reader's attention, and the
	              one role that says nothing about what the state IS

	And the REGION says what no colour can: the states inside one are
	mutually reachable -- you move among them freely, at the mercy of
	events -- while leaving a region is a one-way door. That is the
	single fact a state machine has that a picture may honestly order.

	Run:  ring gg_statemachine_cases.ring
---------------------------------------------------------------------------*/

decimals(2)
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")

# LARGE ENOUGH TO READ. A diagram nobody can read at the size it is
# shipped has not been drawn, it has been filed.
OPT = [ :Font = FONT, :NodeWidth = 132, :NodeHeight = 52, :FontSize = 17 ]

? "=============================================================="
? " STATE MACHINES FROM PRACTICE"
? "=============================================================="

#-- 1. A MEDIA PLAYER ------------------------------------------------------
#   The smallest machine worth drawing, and the clearest demonstration:
#   Stopped, Playing and Paused are ONE region because you move among
#   them all day. Nothing is a "step".
o1 = new stzWorkflow("player")
o1.SetWorkflowType("statemachine")
o1.AddStateXTT("i", "", [ :isInitial = 1 ])
o1.AddStateXTT("stopped", "Stopped", [ :color = "Muted" ])
o1.AddStateXTT("playing", "Playing", [ :color = "Focus.Solid" ])
o1.AddStateXTT("paused", "Paused", [ :color = "Warning.Solid" ])
o1.AddTransition("i", "stopped", "")
o1.AddTransition("stopped", "playing", "play")
o1.AddTransition("playing", "paused", "pause")
o1.AddTransition("paused", "playing", "resume")
o1.AddTransition("playing", "stopped", "stop")
o1.AddTransition("paused", "stopped", "stop")
o1.ToCanvasXT(OPT)
o1.LastCanvas().ToPNG("case_1_player.png")
? "  1. media player        " + o1.LastCanvas().Width() + "x" +
  o1.LastCanvas().Height() + "   regions " + len(o1.Clusters())

#-- 2. AN ORDER'S LIFETIME -------------------------------------------------
#   Mostly one way, with one place you can go back and forth (a payment
#   that fails and is retried) and two doors that never reopen.
o2 = new stzWorkflow("order")
o2.SetWorkflowType("statemachine")
o2.AddStateXTT("i", "", [ :isInitial = 1 ])
o2.AddStateXTT("cart", "In Cart", [ :color = "Muted" ])
o2.AddStateXTT("pending", "Awaiting Payment", [ :color = "Warning.Solid" ])
o2.AddStateXTT("failed", "Payment Failed", [ :color = "Danger.Solid" ])
o2.AddStateXTT("paid", "Paid", [ :color = "Focus.Solid" ])
o2.AddStateXTT("shipped", "Shipped", [ :color = "Info.Solid" ])
o2.AddStateXTT("delivered", "Delivered", [ :color = "Success.Solid",
	:isFinal = 1 ])
o2.AddTransition("i", "cart", "")
o2.AddTransition("cart", "pending", "checkout")
o2.AddTransition("pending", "failed", "declined")
o2.AddTransition("failed", "pending", "retry")
o2.AddTransition("pending", "paid", "authorised")
o2.AddTransition("paid", "shipped", "dispatch")
o2.AddTransition("shipped", "delivered", "signed for")
o2.ToCanvasXT(OPT)
o2.LastCanvas().ToPNG("case_2_order.png")
? "  2. order lifetime      " + o2.LastCanvas().Width() + "x" +
  o2.LastCanvas().Height() + "   regions " + len(o2.Clusters())

#-- 3. A TRAFFIC LIGHT -----------------------------------------------------
#   A machine with NO exit: one region, and the picture says so by having
#   nothing outside it. Every colour here is the real one, which is the
#   case where semantic roles must step aside for the domain's own.
o3 = new stzWorkflow("lights")
o3.SetWorkflowType("statemachine")
o3.AddStateXTT("red", "Red", [ :color = "Danger.Solid" ])
o3.AddStateXTT("green", "Green", [ :color = "Success.Solid" ])
o3.AddStateXTT("amber", "Amber", [ :color = "Warning.Solid" ])
o3.AddTransition("red", "green", "timer")
o3.AddTransition("green", "amber", "timer")
o3.AddTransition("amber", "red", "timer")
o3.ToCanvasXT(OPT)
o3.LastCanvas().ToPNG("case_3_lights.png")
? "  3. traffic light       " + o3.LastCanvas().Width() + "x" +
  o3.LastCanvas().Height() + "   regions " + len(o3.Clusters())

#-- 4. A CONNECTION --------------------------------------------------------
#   The shape every network programmer knows. Connected and Reconnecting
#   are one region -- a connection that drops and recovers has not moved
#   on -- and Closed is the door that does not reopen.
o4 = new stzWorkflow("socket")
o4.SetWorkflowType("statemachine")
o4.AddStateXTT("i", "", [ :isInitial = 1 ])
o4.AddStateXTT("idle", "Idle", [ :color = "Muted" ])
o4.AddStateXTT("opening", "Connecting", [ :color = "Warning.Solid" ])
o4.AddStateXTT("open", "Connected", [ :color = "Focus.Solid" ])
o4.AddStateXTT("retry", "Reconnecting", [ :color = "Warning.Solid" ])
o4.AddStateXTT("closed", "Closed", [ :color = "Neutral.Solid",
	:isFinal = 1 ])
o4.AddTransition("i", "idle", "")
o4.AddTransition("idle", "opening", "connect")
o4.AddTransition("opening", "open", "handshake ok")
o4.AddTransition("open", "retry", "dropped")
o4.AddTransition("retry", "open", "recovered")
o4.AddTransition("open", "closed", "close")
o4.AddTransition("retry", "closed", "gave up")
o4.ToCanvasXT(OPT)
o4.LastCanvas().ToPNG("case_4_socket.png")
? "  4. connection          " + o4.LastCanvas().Width() + "x" +
  o4.LastCanvas().Height() + "   regions " + len(o4.Clusters())

#-- 5. A DOCUMENT UNDER REVIEW ---------------------------------------------
#   The rework loop is the whole point of the drawing: Draft, In Review
#   and Changes Requested form one region a document can circle in for
#   weeks, and Published is where circling stops.
o5 = new stzWorkflow("review")
o5.SetWorkflowType("statemachine")
o5.AddStateXTT("i", "", [ :isInitial = 1 ])
o5.AddStateXTT("draft", "Draft", [ :color = "Muted" ])
o5.AddStateXTT("review", "In Review", [ :color = "Focus.Solid" ])
o5.AddStateXTT("changes", "Changes Requested", [ :color = "Warning.Solid" ])
o5.AddStateXTT("rejected", "Rejected", [ :color = "Danger.Solid",
	:isFinal = 1 ])
o5.AddStateXTT("published", "Published", [ :color = "Success.Solid",
	:isFinal = 1 ])
o5.AddTransition("i", "draft", "")
o5.AddTransition("draft", "review", "submit")
o5.AddTransition("review", "changes", "request changes")
o5.AddTransition("changes", "review", "resubmit")
o5.AddTransition("review", "published", "approve")
o5.AddTransition("review", "rejected", "reject")
o5.ToCanvasXT(OPT)
o5.LastCanvas().ToPNG("case_5_review.png")
? "  5. document review     " + o5.LastCanvas().Width() + "x" +
  o5.LastCanvas().Height() + "   regions " + len(o5.Clusters())

#-- 6. THREE SWITCHES, INDEPENDENT -----------------------------------------
#   Concurrency, and it needed no machinery at all: three pairs nothing
#   links are three regions, DISCOVERED. A reader sees immediately that
#   no switch can affect another.
o6 = new stzWorkflow("panel")
o6.SetWorkflowType("statemachine")
o6.AddStateXTT("p0", "Power Off", [ :color = "Muted" ])
o6.AddStateXTT("p1", "Power On", [ :color = "Success.Solid" ])
o6.AddStateXTT("a0", "Alarm Armed", [ :color = "Focus.Solid" ])
o6.AddStateXTT("a1", "Alarm Off", [ :color = "Muted" ])
o6.AddStateXTT("d0", "Door Locked", [ :color = "Info.Solid" ])
o6.AddStateXTT("d1", "Door Open", [ :color = "Warning.Solid" ])
o6.AddTransition("p0", "p1", "switch on")
o6.AddTransition("p1", "p0", "switch off")
o6.AddTransition("a0", "a1", "disarm")
o6.AddTransition("a1", "a0", "arm")
o6.AddTransition("d0", "d1", "unlock")
o6.AddTransition("d1", "d0", "lock")
o6.ToCanvasXT(OPT)
o6.LastCanvas().ToPNG("case_6_panel.png")
? "  6. three switches      " + o6.LastCanvas().Width() + "x" +
  o6.LastCanvas().Height() + "   regions " + len(o6.Clusters())

? ""
? "wrote case_1..case_6"
