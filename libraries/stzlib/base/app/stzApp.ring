# base/app/stzApp.ring
# -----------------------------------------------------------------------------
# stzApp -- "an application is a living world of meaning."
#
#   CONSTITUTIVE -- what the world is made of
#     A - BEING (Domain):  things, truths, relations                [stzGraph]
#     B - LIFE-behavior:   flows + reactions                        [stzWorkflow, Reaxis]
#     C - LIFE-purpose:    goals + plans                            [stzGraphGoal, stzGraphPlanner]
#     D - BODY:            where the world endures                  [.stzgraf/.stzrulz, stzGraphView]
#   RELATIONAL (emergent) -- how the world is met from without
#     E - PRESENCE (seen) - INTENT (engaged) - REFINEMENT (tuned) - REACH (appears)
#
# See doc/design/STZAPP_DESIGN.md (+ PURPOSE/BODY deepenings). Examples in test/app/.
#
# R7 COMPLETION (2026-07-14): slices B..E converted from the sub-builder
# shape (When() returned a method-local stzAppFlow -- R31 "destroy the
# object using the self reference" on every brace, and the list held a
# pre-brace COPY anyway: the brace-copy trap) to the SAME cursor/method
# pattern Slice A validated: every builder verb is a method ON THE APP
# operating on a "current record" cursor over plain app-held lists, so
# the brace after When/Whenever/Want/LivesIn/Screen runs app methods and
# persists for real. Attribute-style braces (Want/LivesIn) flush their
# cursor in BraceEnd(). Pursue() is REAL now: the goal's Means compiles
# to an stzGraphGoal (a wanted graph state) whose GapOn(@oGraph) lists
# the instances breaking the pattern; each gap item becomes a proposal
# through the matching Whenever/Propose reaction.
#
# Ring gotchas honored: reserved names Load/Import/Put/Set/Get; var oR ==
# keyword 'or'; top-level code before class defs; new X(){} fails but
# method(){} braces work; lambdas do not capture (hence cursors, not
# closures); ring_len()/engine helpers in class scope.
# -----------------------------------------------------------------------------

func StzAppQ(pcName)
    return new stzApp(pcName)

class stzApp from stzObject

    @cName        = ""
    @oGraph       = NULL          # the world's domain graph (node registry)   (Being)
    @aThings      = []            # [ [ name, [fields], [ [field,expr] ], [ [rel,to] ] ], ... ]
    @aKnows       = []            # [ [ from, relation, to ], ... ]   (free relations)
    @nCur         = 0             # cursor: index of the thing being declared

    @aFlows       = []            # [ [ actor, verb, thing, [requires], [effects] ], ... ]
    @nCurFlow     = 0
    @aReactions   = []            # [ [ thing, condKind, [condArgs], [effects] ], ... ]
    @nCurReaction = 0
    @aGoals       = []            # [ [ name, means, reachedBy, within, [respecting] ], ... ]
    @nCurGoal     = 0
    @aBody        = []            # [ [kinds], graphPath, filesPath, keep ]  ([] = memory only)
    @bBodyPending = FALSE
    @aScreens     = []            # [ [ name, intent, subject, [shows], [acts] ], ... ]
    @nCurScreen   = 0
    @aRefinements = []            # [ [ knob, min, max, [options] ], ... ]
    @nCurRefinement = 0
    @aReaches     = []            # (Reach)
    @oReactive    = NULL
    @bLive        = FALSE
    @aProposals   = []            # [ [ :propose, thing, :for, instance ], ... ]

    # SCOPE SIGILS: every attribute above is @-prefixed. A BARE class-head
    # attribute CAPTURES a same-named user global in Ring 1.27 -- proven on
    # this very class (2026-07-16): `new stzApp` turned a user's oGraph string
    # into the app's graph OBJECT, overwrote cName, and emptied aGoals.
    #
    # The slots BELOW stay deliberately bare: they are the brace-DSL contract
    # (`AddGoal(:X) { Means = "..." }` assigns the bare attribute by name) and the
    # public data slots read as oGoal.Means. They are the DSL's surface, not
    # internal state -- keep this list SHORT for exactly the reason above.

    # goal-brace cursor attributes (assigned inside AddGoal(...) { ... })
    Means      = ""
    ReachedBy  = ""
    Within     = ""
    Respecting = []

    # body-brace cursor attributes (assigned inside SetBody(...) { ... }).
    # Graph/Keep coexist with the Graph() accessor and the Keep(thing)
    # flow verb -- Ring separates attr-assignment from method-call
    # (probed 2026-07-14: assignment targets the attr, parens the method).
    Graph      = ""
    Files      = ""
    Keep       = ""

    def init(pcName)
        @cName        = pcName
        @oGraph       = new stzGraph(pcName)
        @aThings      = []
        @aKnows       = []
        @nCur         = 0
        @aFlows       = []
        @aReactions   = []
        @aGoals       = []
        @aBody        = []
        @aScreens     = []
        @aRefinements = []
        @aReaches     = []
        @bLive        = FALSE
        @aProposals   = []

    #== Identity & substance =================================================

    def Name()
        return @cName

    def GraphQ()
        return @oGraph

    #== DOMAIN (Being) =======================================================
    # AddThing() returns This, so the block  AddThing(:X) { Has(...) Owns(:Y) }  runs the
    # app's OWN Has/IsTrue/Owns/Of on the current-thing cursor.

    def AddThing(pcName)
        n = This._ThingIndex(pcName)
        if n = 0
            if NOT @oGraph.NodeExists(pcName)
                @oGraph.AddNode(pcName)
            ok
            @aThings + [ pcName, [], [], [] ]
            n = len(@aThings)
        ok
        @nCur = n
        return This

    def Has(paFields)                       # fields of the current thing
        if @nCur > 0  @aThings[@nCur][2] = paFields  ok
        return This

    def IsTrue(pcField, pcExpr)             # a truth of the current thing
        if @nCur > 0  @aThings[@nCur][3] + [ pcField, pcExpr ]  ok
        return This

    def Owns(pcThing)                       # a relation of the current thing
        if @nCur > 0  @aThings[@nCur][4] + [ "owns", pcThing ]  ok
        return This

    def Of(pcThing)
        if @nCur > 0  @aThings[@nCur][4] + [ "of", pcThing ]  ok
        return This

    def AddRelation(pcFrom, pcRelation, pcTo)     # a free relation between two things
        @aKnows + [ pcFrom, pcRelation, pcTo ]
        return This

    #== BEING -- INSTANCES ===================================================
    # Schema things are declared; INSTANCES populate them. An instance
    # binds to its thing by an "isa" edge; instance relations are
    # labeled edges. Goals (wanted graph states) evaluate over these.

    def AddInstance(pcInstance, pcThing)
        if NOT @oGraph.NodeExists(pcInstance)
            @oGraph.AddNode(pcInstance)
        ok
        if NOT @oGraph.NodeExists(pcThing)
            @oGraph.AddNode(pcThing)
        ok
        @oGraph.AddEdgeXT(pcInstance, pcThing, "isa")
        return This

    def Relate(pcFrom, pcRelation, pcTo)
        if NOT @oGraph.NodeExists(pcFrom)
            @oGraph.AddNode(pcFrom)
        ok
        if NOT @oGraph.NodeExists(pcTo)
            @oGraph.AddNode(pcTo)
        ok
        @oGraph.AddEdgeXT(pcFrom, pcTo, "" + pcRelation)
        return This

    #== LIFE - BEHAVIOR (Becoming) ===========================================
    # When() returns This: the brace  { Require(:x)  Then( Keep(:Y) ) }
    # runs app methods against the current-flow cursor.

    def AddFlow(pcActor, pcVerb, pcThing)
        This._FlushCursors()
        @aFlows + [ pcActor, pcVerb, pcThing, [], [] ]
        @nCurFlow = len(@aFlows)
        return This

    def Require(pcField)
        if @nCurFlow > 0  @aFlows[@nCurFlow][4] + pcField  ok
        return This

    def Keep(pcThing)
        return [ :keep, pcThing ]

    def Then(paEffect)
        if @nCurFlow > 0  @aFlows[@nCurFlow][5] + paEffect  ok
        return This

    def AddReaction(pcThing)
        This._FlushCursors()
        @aReactions + [ pcThing, "", [], [] ]
        @nCurReaction = len(@aReactions)
        return This

    def Unseen(nQty, pUnit)
        if @nCurReaction > 0
            @aReactions[@nCurReaction][2] = :unseen
            @aReactions[@nCurReaction][3] = [ nQty, pUnit ]
        ok
        return This

    def Meets(pcExpr)
        if @nCurReaction > 0
            @aReactions[@nCurReaction][2] = :expr
            @aReactions[@nCurReaction][3] = [ pcExpr ]
        ok
        return This

    def Propose(pcThing)
        if @nCurReaction > 0  @aReactions[@nCurReaction][4] + [ :propose, pcThing ]  ok
        return This

    #== LIFE - PURPOSE (Becoming) ============================================
    # AddGoal() returns This; the brace assigns the goal-cursor ATTRIBUTES
    # (Means/ReachedBy/Within/Respecting), flushed into the record by
    # BraceEnd() when the brace closes.

    def AddGoal(pcGoal)
        This._FlushCursors()
        @aGoals + [ pcGoal, "", :planning, "", [] ]
        @nCurGoal = len(@aGoals)
        Means      = ""
        ReachedBy  = :planning
        Within     = ""
        Respecting = []
        return This

    def GoalQ(pcGoal)
        for i = 1 to len(@aGoals)
            if @aGoals[i][1] = pcGoal
                oG = new stzAppGoal(@aGoals[i][1])
                oG.Means      = @aGoals[i][2]
                oG.ReachedBy  = @aGoals[i][3]
                oG.Within     = @aGoals[i][4]
                oG.Respecting = @aGoals[i][5]
                return oG
            ok
        next
        return NULL

    # THE DATA FORM (the house rule: a plain name returns DATA, the Q form
    # returns the OBJECT). A goal as a plain record -- nothing to chain on.
    def Goal(pcGoal)
        for i = 1 to len(@aGoals)
            if @aGoals[i][1] = pcGoal
                return [ :name = @aGoals[i][1], :means = @aGoals[i][2],
                         :reachedBy = @aGoals[i][3], :within = @aGoals[i][4],
                         :respecting = @aGoals[i][5] ]
            ok
        next
        return []

    # just the goal's NAME -- said precisely, since that is all it returns
    def GoalName(pcGoal)
        for i = 1 to len(@aGoals)
            if @aGoals[i][1] = pcGoal  return @aGoals[i][1]  ok
        next
        return ""

    def GoalNames()
        _ac_ = []
        for i = 1 to len(@aGoals)
            _ac_ + @aGoals[i][1]
        next
        return _ac_

    # THE REAL PURSUIT: compile the goal's Means into an stzGraphGoal
    # (a wanted graph state), measure the GAP on the live world graph,
    # and turn each gap instance into a proposal through the matching
    # Whenever/Propose reaction (or a bare :attend proposal when no
    # reaction declares the way).
    def Pursue(pcGoal)
        nG = 0
        for i = 1 to len(@aGoals)
            if @aGoals[i][1] = pcGoal  nG = i  exit  ok
        next
        if nG = 0  return []  ok
        oWanted = new stzGraphGoal(pcGoal)
        oWanted.FromMeans(@aGoals[nG][2])
        aGap = oWanted.GapOn(@oGraph)
        @aProposals = []
        for i = 1 to len(aGap)
            cProposed = This._ProposedFor(oWanted.TypeName())
            if cProposed != ""
                @aProposals + [ :propose, cProposed, :for, aGap[i] ]
            else
                @aProposals + [ :attend, oWanted.TypeName(), :for, aGap[i] ]
            ok
        next
        ? "pursuing " + pcGoal + " via " + @aGoals[nG][3] + " -- " +
          len(@aProposals) + " proposal(s)"
        return @aProposals

    def GoalSatisfied(pcGoal)
        for i = 1 to len(@aGoals)
            if @aGoals[i][1] = pcGoal
                oWanted = new stzGraphGoal(pcGoal)
                oWanted.FromMeans(@aGoals[i][2])
                return oWanted.SatisfiedOn(@oGraph)
            ok
        next
        return FALSE

    # The thing a reaction proposes for a given subject thing ("" = none).
    def _ProposedFor(pcThing)
        for i = 1 to len(@aReactions)
            if StzLower("" + @aReactions[i][1]) = StzLower("" + pcThing)
                for j = 1 to len(@aReactions[i][4])
                    if @aReactions[i][4][j][1] = :propose
                        return @aReactions[i][4][j][2]
                    ok
                next
            ok
        next
        return ""

    #== BODY (embodiment) ====================================================
    # SetBody() returns This; the brace assigns the body-cursor
    # attributes (Graph_/Files/Keep_ -- note: the DSL keywords Graph and
    # Keep collide with the Graph() accessor and the Keep(thing) flow
    # verb, so the ATTRIBUTES carry a trailing underscore and BraceEnd
    # reads whichever was written).

    def SetBody(pBody)
        This._FlushCursors()
        @aKinds = pBody
        if NOT isList(pBody)  @aKinds = [ pBody ]  ok
        @aBody = [ @aKinds, "", "", "" ]
        @bBodyPending = TRUE
        Graph = ""
        Files = ""
        Keep  = ""
        return This

    def BodyQ()
        if len(@aBody) = 0  return NULL  ok
        oB = new stzAppBody(@aBody[1])
        oB.Graph = @aBody[2]
        oB.Files = @aBody[3]
        return oB

    # the body as DATA (the Q form above returns the object)
    def Body()
        if len(@aBody) = 0  return []  ok
        return [ :label = @aBody[1], :graph = @aBody[2], :files = @aBody[3] ]

    def Save()
        if len(@aBody) = 0  return This  ok
        if This._BodyHasKind(:GraphDB)
            cG = @aBody[2]
            if cG = ""  cG = ".stzapp/world.stzgraf"  ok
            This._EnsureParentDir(cG)
            @oGraph.SaveToStzGraf(cG)
        ok
        return This

    def _BodyHasKind(pKind)
        if len(@aBody) = 0  return FALSE  ok
        for i = 1 to len(@aBody[1])
            if @aBody[1][i] = pKind  return TRUE  ok
        next
        return FALSE

    def _EnsureParentDir(pcPath)
        nSlash = 0
        for i = 1 to len(pcPath)
            if pcPath[i] = "/"  nSlash = i  ok
        next
        if nSlash > 1
            StzMakeDir(StzLeft(pcPath, nSlash - 1))
        ok

    #== EMERGENTS (met from without) =========================================

    def AddScreen(pcName)
        This._FlushCursors()
        @aScreens + [ pcName, "understand", "", [], [] ]
        @nCurScreen = len(@aScreens)
        return This

    def ToDiscover(pcThing)
        return This._ScreenIntent("discover", pcThing)
    def ToUnderstand(pcThing)
        return This._ScreenIntent("understand", pcThing)
    def ToFocus(pcThing)
        return This._ScreenIntent("focus", pcThing)
    def ToSelect(pcThing)
        return This._ScreenIntent("select", pcThing)
    def ToAct(pcThing)
        return This._ScreenIntent("act", pcThing)

    def _ScreenIntent(pcIntent, pcThing)
        if @nCurScreen > 0
            @aScreens[@nCurScreen][2] = pcIntent
            @aScreens[@nCurScreen][3] = pcThing
        ok
        return This

    def Shows(paParts)
        if @nCurScreen > 0  @aScreens[@nCurScreen][4] = paParts  ok
        return This

    def Acts(pcAction, pcFlow)
        if @nCurScreen > 0  @aScreens[@nCurScreen][5] + [ pcAction, pcFlow ]  ok
        return This

    def AddRefinement(pcKnob)
        This._FlushCursors()
        @aRefinements + [ pcKnob, "", "", [] ]
        @nCurRefinement = len(@aRefinements)
        return This

    def Bounds(pLow, pHigh)
        if @nCurRefinement > 0
            @aRefinements[@nCurRefinement][2] = "" + pLow
            @aRefinements[@nCurRefinement][3] = "" + pHigh
        ok
        return This

    def Options(paOpts)
        if @nCurRefinement > 0  @aRefinements[@nCurRefinement][4] = paOpts  ok
        return This

    # THE DECLARATIONS, AS DATA. Anything outside (stzPlatform harvesting a
    # world, a generator, a doc tool) asks through these -- it never reaches
    # into the @attributes. AddReaches([...]) DECLARES the surfaces; Surfaces()
    # reports them.
    def Surfaces()
        return @aReaches

    # [ [ thingName, [fields] ], ... ]
    def Things()
        _a_ = []
        _n_ = len(@aThings)
        for _i_ = 1 to _n_
            _aF_ = []
            _nF_ = len(@aThings[_i_][2])
            for _j_ = 1 to _nF_
                _aF_ + @aThings[_i_][2][_j_]
            next
            _a_ + [ @aThings[_i_][1], _aF_ ]
        next
        return _a_

    def ScreenNames()
        _ac_ = []
        _n_ = len(@aScreens)
        for _i_ = 1 to _n_
            _ac_ + @aScreens[_i_][1]
        next
        return _ac_

    def AddReaches(paSurfaces)
        if NOT isList(paSurfaces)  paSurfaces = [ paSurfaces ]  ok
        for i = 1 to len(paSurfaces)
            @aReaches + paSurfaces[i]
        next
        return This

    #== CURSOR FLUSHING ======================================================
    # Attribute-style braces (Want/LivesIn) write cursor ATTRIBUTES;
    # Ring's BraceEnd hook fires when any brace on the app closes, so
    # the flush is idempotent and cursor-guarded. _FlushCursors() also
    # runs at the start of every builder verb, so a missing brace-end
    # (or plain method chaining) never loses a pending record.

    def BraceEnd()
        This._FlushCursors()

    def _FlushCursors()
        if @nCurGoal > 0
            @aGoals[@nCurGoal][2] = Means
            @aGoals[@nCurGoal][3] = ReachedBy
            @aGoals[@nCurGoal][4] = Within
            @aGoals[@nCurGoal][5] = Respecting
            @nCurGoal = 0
        ok
        if @bBodyPending
            @aBody[2] = Graph
            @aBody[3] = Files
            @aBody[4] = Keep
            @bBodyPending = FALSE
        ok

    #== ANIMATION ============================================================

    # Live() wires the world's reactions into a running reactive system
    # and does a first Pulse() so the live world already reflects what
    # its Whenever/Propose rules imply. Continuous/temporal firing rides
    # the R5 stzAgentHost runtime (supervise the world, tick Pulse()).
    def Live()
        This._FlushCursors()
        @oReactive = new stzReactiveSystem()
        @bLive = TRUE
        This.Pulse()
        ? "[" + @cName + "] is live -- " + len(@aThings) + " thing(s), " +
          len(@aFlows) + " flow(s), " + len(@aReactions) + " reaction(s), " +
          len(@aGoals) + " goal(s); " + len(@aProposals) + " proposal(s)"
        return This

    def IsLive()
        return @bLive

    # PULSE: evaluate every reaction against the live world. A reaction
    # 'Whenever :Thing ... Propose :Other' fires for each INSTANCE of
    # Thing that lacks an <other>-labeled relation -- producing one
    # proposal per gap (the same structural gap the goal machinery
    # measures). Idempotent: a proposal already standing is not
    # duplicated, and once the world Relate()s the instance the
    # proposal clears on the next pulse. Returns proposals added.
    def Pulse()
        _nAdded_ = 0
        # drop proposals the world has since satisfied
        This._PruneSatisfiedProposals()
        for r = 1 to len(@aReactions)
            cThing = "" + @aReactions[r][1]
            cProposed = This._ReactionProposes(r)
            if cProposed = ""  loop  ok
            aInst = This._InstancesOf(cThing)
            for k = 1 to len(aInst)
                if NOT This._InstanceHasRelation(aInst[k], cProposed)
                    if NOT This._ProposalStands(cProposed, aInst[k])
                        @aProposals + [ :propose, cProposed, :for, aInst[k] ]
                        _nAdded_++
                    ok
                ok
            next
        next
        return _nAdded_

    def Proposals()
        return @aProposals

    # React to an EVENT on one instance: pulse just that instance's
    # reactions. Returns proposals added.
    def React(pcInstance)
        _nAdded_ = 0
        This._PruneSatisfiedProposals()
        for r = 1 to len(@aReactions)
            cThing = "" + @aReactions[r][1]
            cProposed = This._ReactionProposes(r)
            if cProposed = ""  loop  ok
            if This._InstanceIsA(pcInstance, cThing)
                if NOT This._InstanceHasRelation(pcInstance, cProposed)
                    if NOT This._ProposalStands(cProposed, pcInstance)
                        @aProposals + [ :propose, cProposed, :for, pcInstance ]
                        _nAdded_++
                    ok
                ok
            ok
        next
        return _nAdded_

    #-- reaction/instance helpers -------------------------------------

    def _ReactionProposes(n)
        for j = 1 to len(@aReactions[n][4])
            if @aReactions[n][4][j][1] = :propose
                return "" + @aReactions[n][4][j][2]
            ok
        next
        return ""

    def _InstancesOf(pcThing)
        cT = StzLower("" + pcThing)
        aOut = []
        aE = @oGraph.Edges()
        for i = 1 to len(aE)
            if StzLower("" + aE[i][:label]) = "isa" and aE[i][:to] = cT
                aOut + aE[i][:from]
            ok
        next
        return aOut

    def _InstanceIsA(pcInstance, pcThing)
        cI = StzLower("" + pcInstance)
        cT = StzLower("" + pcThing)
        aE = @oGraph.Edges()
        for i = 1 to len(aE)
            if aE[i][:from] = cI and StzLower("" + aE[i][:label]) = "isa" and aE[i][:to] = cT
                return TRUE
            ok
        next
        return FALSE

    def _InstanceHasRelation(pcInstance, pcRelation)
        cI = StzLower("" + pcInstance)
        cR = StzLower("" + pcRelation)
        aE = @oGraph.Edges()
        for i = 1 to len(aE)
            if aE[i][:from] = cI and StzLower("" + aE[i][:label]) = cR
                return TRUE
            ok
        next
        return FALSE

    def _ProposalStands(pcThing, pcInstance)
        for i = 1 to len(@aProposals)
            if @aProposals[i][2] = pcThing and @aProposals[i][4] = pcInstance
                return TRUE
            ok
        next
        return FALSE

    def _PruneSatisfiedProposals()
        aKept = []
        for i = 1 to len(@aProposals)
            if NOT This._InstanceHasRelation(@aProposals[i][4], @aProposals[i][2])
                aKept + @aProposals[i]
            ok
        next
        @aProposals = aKept

    #== PRESENCE (emergent) -- make the world visible ========================

    def Explain()
        This._FlushCursors()
        ? "WORLD " + @cName + "   lives in: " + This._BodyLabel()
        ? "  BEING"
        for i = 1 to len(@aThings)
            cLine = "    " + @aThings[i][1]
            if len(@aThings[i][2]) > 0
                cLine += " (" + This._Join(@aThings[i][2], ", ") + ")"
            ok
            ? cLine
            for j = 1 to len(@aThings[i][3])
                ? "        true when " + @aThings[i][3][j][1] + " " + @aThings[i][3][j][2]
            next
        next
        if This._HasAnyRelation()
            ? "  RELATIONS"
            for i = 1 to len(@aThings)
                for j = 1 to len(@aThings[i][4])
                    ? "    " + @aThings[i][1] + " " + @aThings[i][4][j][1] + " " + @aThings[i][4][j][2]
                next
            next
            for i = 1 to len(@aKnows)
                ? "    " + @aKnows[i][1] + " " + @aKnows[i][2] + " " + @aKnows[i][3]
            next
        ok
        if len(@aFlows) > 0 or len(@aReactions) > 0 or len(@aGoals) > 0
            ? "  BECOMING"
            for i = 1 to len(@aFlows)      ? "    " + This._NarrateFlow(i)      next
            for i = 1 to len(@aReactions)  ? "    " + This._NarrateReaction(i)  next
            for i = 1 to len(@aGoals)      ? "    " + This._NarrateGoal(i)      next
        ok
        if len(@aScreens) > 0 or len(@aRefinements) > 0 or len(@aReaches) > 0
            ? "  MET FROM WITHOUT"
            for i = 1 to len(@aScreens)      ? "    " + This._NarrateScreen(i)      next
            for i = 1 to len(@aRefinements)  ? "    " + This._NarrateRefinement(i)  next
            if len(@aReaches) > 0  ? "    reaches " + This._Join(@aReaches, ", ")  ok
        ok
        return This

    def Show(pcThing)
        n = This._ThingIndex(pcThing)
        if n = 0  ? "(no such thing: " + pcThing + ")"  return This ok
        ? @aThings[n][1] + " (" + This._Join(@aThings[n][2], ", ") + ")"
        for j = 1 to len(@aThings[n][3])
            ? "  true when " + @aThings[n][3][j][1] + " " + @aThings[n][3][j][2]
        next
        for j = 1 to len(@aThings[n][4])
            ? "  " + @aThings[n][4][j][1] + " " + @aThings[n][4][j][2]
        next
        return This

    #== narration (formats are CANONICAL -- narration docs rule) =============

    def _NarrateFlow(n)
        cR = ""
        if len(@aFlows[n][4]) > 0  cR = " require " + This._Join(@aFlows[n][4], ", ")  ok
        cE = ""
        if len(@aFlows[n][5]) > 0  cE = " then keep " + @aFlows[n][3]  ok
        return "when " + @aFlows[n][1] + " " + @aFlows[n][2] + " " + @aFlows[n][3] + cR + cE

    def _NarrateReaction(n)
        cC = "" + @aReactions[n][2]
        if @aReactions[n][2] = :unseen
            cC = "unseen " + @aReactions[n][3][1] + " " + @aReactions[n][3][2]
        but @aReactions[n][2] = :expr
            cC = "meets " + @aReactions[n][3][1]
        ok
        cE = ""
        if len(@aReactions[n][4]) > 0  cE = " -> propose " + @aReactions[n][4][1][2]  ok
        return "whenever " + @aReactions[n][1] + " " + cC + cE

    def _NarrateGoal(n)
        cW = ""
        if @aGoals[n][4] != ""  cW = " within " + @aGoals[n][4]  ok
        return "wants " + @aGoals[n][1] + cW + " -> reached by " + @aGoals[n][3]

    def _NarrateScreen(n)
        cS = ""
        if len(@aScreens[n][4]) > 0  cS = " shows " + This._Join(@aScreens[n][4], ", ")  ok
        return "screen " + @aScreens[n][1] + ": " + @aScreens[n][2] + " " + @aScreens[n][3] + cS

    def _NarrateRefinement(n)
        if @aRefinements[n][2] != "" or @aRefinements[n][3] != ""
            return "refine " + @aRefinements[n][1] + " bounds [" +
                   @aRefinements[n][2] + ".." + @aRefinements[n][3] + "]"
        ok
        if len(@aRefinements[n][4]) > 0
            return "refine " + @aRefinements[n][1] + " options " + This._Join(@aRefinements[n][4], " | ")
        ok
        return "refine " + @aRefinements[n][1]

    #== internals ============================================================

    def _ThingIndex(pcThing)
        for i = 1 to len(@aThings)
            if @aThings[i][1] = pcThing  return i  ok
        next
        return 0

    def _HasAnyRelation()
        if len(@aKnows) > 0  return TRUE  ok
        for i = 1 to len(@aThings)
            if len(@aThings[i][4]) > 0  return TRUE  ok
        next
        return FALSE

    def _BodyLabel()
        if len(@aBody) = 0  return "memory (not persisted)"  ok
        return This._Join(@aBody[1], " + ")

    def _Join(paList, cSep)
        cRes = ""
        for i = 1 to len(paList)
            cRes += "" + paList[i]
            if i < len(paList)  cRes += cSep  ok
        next
        return cRes


# stzAppGoal -- the goal VALUE OBJECT returned by oApp.Goal(:X): a readable
# snapshot of the goal record (Means/ReachedBy/Within/Respecting).
# Evaluation happens on the app (Pursue/GoalSatisfied), which holds the
# live graph.
class stzAppGoal from stzObject
    @cName = ""
    Means      = ""
    ReachedBy  = :planning
    Within     = ""
    Respecting = []
    def init(pcName)
        @cName = pcName
        Respecting = []
    def Name()
        return @cName
    def Profile()
        return ReachedBy
    def Narrate()
        cW = "" if Within != ""  cW = " within " + Within  ok
        return "wants " + @cName + cW + " -> reached by " + ReachedBy


# stzAppBody -- the body VALUE OBJECT returned by oApp.Body(): a readable
# snapshot of the body record. Persistence happens on the app (Save()).
class stzAppBody from stzObject
    @aKinds = []
    Graph = ""
    Files = ""
    def init(paKinds)
        @aKinds = paKinds
    def Label()
        cRes = ""
        for i = 1 to len(@aKinds)
            cRes += "" + @aKinds[i]
            if i < len(@aKinds)  cRes += " + "  ok
        next
        return cRes
    def HasKind(pKind)
        for i = 1 to len(@aKinds)
            if @aKinds[i] = pKind  return TRUE  ok
        next
        return FALSE
    def Narrate()
        return "lives in " + This.Label()
