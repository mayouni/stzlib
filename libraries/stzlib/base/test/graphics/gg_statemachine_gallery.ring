load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	THE STATE MACHINE GALLERY -- Mermaid's own examples, in our system

	The Principal gave the mermaid stateDiagram page as the reference and
	asked for its examples rendered here, with our colours and our edge
	grammar, plus the thinking for what is not built yet.

	Each scene below names the mermaid source it mirrors. What we render
	differs from mermaid in one deliberate way and it is the DN2d model:
	mermaid draws every state machine as a top-down flow, so `Still` and
	`Moving` -- which you move BETWEEN freely -- are stacked as if one
	came first. We draw mutually reachable states as PEERS inside a
	region, because a state machine has no next.

	Run:  ring gg_statemachine_gallery.ring
---------------------------------------------------------------------------*/

decimals(2)
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
OPT = [ :Font = FONT, :NodeWidth = 104, :NodeHeight = 40, :FontSize = 13 ]

? "=============================================================="
? " STATE MACHINE GALLERY -- mermaid's examples, our grammar"
? "=============================================================="

#-- 1. "Simple sample" -----------------------------------------------------
#   [*] --> Still ; Still --> [*] ; Still --> Moving ; Moving --> Still
#   Moving --> Crash ; Crash --> [*]
o1 = new stzWorkflow("simple")
o1.SetWorkflowType("statemachine")
o1.AddStateXTT("i", "", [ :isInitial = 1 ])
o1.AddStateXT("still", "Still")
o1.AddStateXT("moving", "Moving")
o1.AddStateXT("crash", "Crash")
o1.AddStateXTT("e", "", [ :isFinal = 1 ])
o1.AddTransition("i", "still", "")
o1.AddTransition("still", "moving", "")
o1.AddTransition("moving", "still", "")
o1.AddTransition("moving", "crash", "")
o1.AddTransition("still", "e", "")
o1.AddTransition("crash", "e", "")
o1.ToCanvasXT(OPT)
o1.LastCanvas().ToPNG("sm_1_simple.png")
? "  1. simple sample          " + o1.LastCanvas().Width() + "x" +
  o1.LastCanvas().Height() + "  regions " + len(o1.Clusters())

#-- 2. Transitions that CARRY THEIR EVENT ----------------------------------
#   s1 --> s2: A transition
o2 = new stzWorkflow("labelled")
o2.SetWorkflowType("statemachine")
o2.AddStateXT("s1", "s1")
o2.AddStateXT("s2", "s2")
o2.AddTransition("s1", "s2", "A transition")
o2.ToCanvasXT(OPT)
o2.LastCanvas().ToPNG("sm_2_transition.png")
? "  2. a labelled transition  " + o2.LastCanvas().Width() + "x" +
  o2.LastCanvas().Height()

#-- 3. A CHOICE, with its guards -------------------------------------------
#   state if_state <<choice>> ; if_state --> False: if n < 0
#                              if_state --> True : if n >= 0
o3 = new stzWorkflow("choice")
o3.SetWorkflowType("statemachine")
o3.AddStateXTT("i", "", [ :isInitial = 1 ])
o3.AddStateXT("pos", "IsPositive")
o3.AddStateXTT("q", "", [ :type = "choice" ])
o3.AddStateXT("f", "False")
o3.AddStateXT("t", "True")
o3.AddTransition("i", "pos", "")
o3.AddTransition("pos", "q", "")
o3.AddTransition("q", "f", "if n < 0")
o3.AddTransition("q", "t", "if n >= 0")
o3.ToCanvasXT(OPT)
o3.LastCanvas().ToPNG("sm_3_choice.png")
? "  3. a choice + guards     " + o3.LastCanvas().Width() + "x" +
  o3.LastCanvas().Height()

#-- 4. COMPOSITE STATES, declared ------------------------------------------
#   state First { [*] --> second ; second --> [*] }
#   An author's OWN grouping, which discovery never overrules.
o4 = new stzWorkflow("composite")
o4.SetWorkflowType("statemachine")
o4.AddStateXTT("i", "", [ :isInitial = 1 ])
o4.AddStateXT("fir", "fir")
o4.AddStateXT("sec", "sec")
o4.AddStateXT("thi", "thi")
o4.AddTransition("i", "fir", "")
o4.AddTransition("fir", "sec", "")
o4.AddTransition("fir", "thi", "")
o4.AddClusterXTT("first", "First", [ "fir" ], "Info.Surface")
o4.AddClusterXTT("second", "Second", [ "sec" ], "Info.Surface")
o4.AddClusterXTT("third", "Third", [ "thi" ], "Info.Surface")
o4.ToCanvasXT(OPT)
o4.LastCanvas().ToPNG("sm_4_composite.png")
? "  4. composite states      " + o4.LastCanvas().Width() + "x" +
  o4.LastCanvas().Height() + "  frames " + len(o4.Clusters())

#-- 5. NESTED composite ----------------------------------------------------
#   state First { state Second { state Third { } } }
o5 = new stzWorkflow("nested")
o5.SetWorkflowType("statemachine")
o5.AddStateXTT("i", "", [ :isInitial = 1 ])
o5.AddStateXT("sec", "second")
o5.AddStateXT("thi", "third")
o5.AddTransition("i", "sec", "")
o5.AddTransition("sec", "thi", "")
o5.AddClusterXTT("f1", "First", [ "sec", "thi" ], "Info.Surface")
o5.AddClusterXTT("f3", "Third", [ "thi" ], "Info.Surface")
o5.ToCanvasXT(OPT)
o5.LastCanvas().ToPNG("sm_5_nested.png")
? "  5. nested composite      " + o5.LastCanvas().Width() + "x" +
  o5.LastCanvas().Height() + "  frames " + len(o5.Clusters())

#-- 6. CONCURRENCY: independent regions ------------------------------------
#   state Active { NumLock -- CapsLock -- ScrollLock }
#   Three independent machines. Nothing links them, and the MODE model
#   discovers each pair on its own -- which is what concurrency IS.
o6 = new stzWorkflow("locks")
o6.SetWorkflowType("statemachine")
o6.AddStateXT("n0", "NumLockOff")   o6.AddStateXT("n1", "NumLockOn")
o6.AddStateXT("c0", "CapsLockOff")  o6.AddStateXT("c1", "CapsLockOn")
o6.AddStateXT("s0", "ScrollOff")    o6.AddStateXT("s1", "ScrollOn")
o6.AddTransition("n0", "n1", "EvNumLock")
o6.AddTransition("n1", "n0", "EvNumLock")
o6.AddTransition("c0", "c1", "EvCapsLock")
o6.AddTransition("c1", "c0", "EvCapsLock")
o6.AddTransition("s0", "s1", "EvScrollLock")
o6.AddTransition("s1", "s0", "EvScrollLock")
o6.ToCanvasXT(OPT)
o6.LastCanvas().ToPNG("sm_6_concurrent.png")
? "  6. concurrent regions    " + o6.LastCanvas().Width() + "x" +
  o6.LastCanvas().Height() + "  regions " + len(o6.Clusters())

#-- 7. THE MODEL'S OWN EXAMPLE ---------------------------------------------
#   The door: what you can undo lives in a region, what you cannot is a
#   one-way door out of it.
o7 = new stzWorkflow("door")
o7.SetWorkflowType("statemachine")
o7.AddStateXTT("i", "", [ :isInitial = 1 ])
o7.AddStateXT("closed", "Closed")
o7.AddStateXT("open", "Open")
o7.AddStateXT("locked", "Locked")
o7.AddStateXTT("gone", "Demolished", [ :isFinal = 1 ])
o7.AddTransition("i", "closed", "")
o7.AddTransition("closed", "open", "open")
o7.AddTransition("open", "closed", "close")
o7.AddTransition("closed", "locked", "lock")
o7.AddTransition("locked", "closed", "unlock")
o7.AddTransition("locked", "locked", "lock")
o7.AddTransition("closed", "gone", "demolish")
o7.ToCanvasXT(OPT)
o7.LastCanvas().ToPNG("sm_7_door.png")
? "  7. the door              " + o7.LastCanvas().Width() + "x" +
  o7.LastCanvas().Height() + "  regions " + len(o7.Clusters())

? ""
? "wrote sm_1..sm_7"
