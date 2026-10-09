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

# Holds an application as a world of meaning: its things, instances, flows, reactions, goals, screens and reach, declared in plain words.
#
# Declare things with AddThing and their fields with Has, then instances and relations with
# AddInstance and Relate: these form a graph. Flows, reactions, goals, screens and refinements are
# cursor builders, each plain verb acting on the one declared last, and each verb has a Q form that
# returns the world so a brace can follow: AddGoalQ(:Visited) { Means = "every :Client
# Has(:visited)" }. A goal is a wanted state of the graph; Pursue measures its gap and proposes how
# to close it through the reactions, and Live and Pulse fire the reactions themselves. Explain
# prints the whole world in words. The world only describes: a stzPlatform wraps it to build,
# generate shells and serve it.
#
#   receiver   o1 = new stzApp("shop")
#   example    o1.AddThingQ("Client").Has([ "code", "name" ])
#              ? o1.Things()[1][1]
#              #--> Client
#              o1.AddInstance("anna", "Client")
#              o1.AddReactionQ("Client").Propose("Visit")
#              ? o1.Pulse()
#              #--> 1
#              ? o1.Proposals()[1][4]
#              #--> anna
#   see        StzAppQ, stzPlatform, stzGraph, stzGraphGoal
class stzApp from stzObject

    @cName        = ""
    @oGraph       = ""          # the world's domain graph (node registry)   (Being)
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
    @bBodyPending = 0
    @aScreens     = []            # [ [ name, intent, subject, [shows], [acts] ], ... ]
    @nCurScreen   = 0
    @aRefinements = []            # [ [ knob, min, max, [options] ], ... ]
    @nCurRefinement = 0
    @aReaches     = []            # (Reach)
    @oReactive    = ""
    @bLive        = 0
    @aProposals   = []            # [ [ :propose, thing, :for, instance ], ... ]

    # SCOPE SIGILS: every attribute above is @-prefixed. A BARE class-head
    # attribute CAPTURES a same-named user global in Ring 1.27 -- proven on
    # this very class (2026-07-16): `new stzApp` turned a user's oGraph string
    # into the app's graph OBJECT, overwrote cName, and emptied aGoals.
    #
    # The slots BELOW stay deliberately bare: they are the brace-DSL contract
    # (`AddGoalQ(:X) { Means = "..." }` assigns the bare attribute by name) and the
    # public data slots read as oGoal.Means. They are the DSL's surface, not
    # internal state -- keep this list SHORT for exactly the reason above.

    # goal-brace cursor attributes (assigned inside AddGoalQ(...) { ... })
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

    # Builds an empty world with the given name and a graph of the same name that holds its things and instances.
    #
    #   pcName     the world's name
    #   returns    nothing; the object is built
    #   see        AddThing, GraphQ, Explain
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
        @bLive        = 0
        @aProposals   = []

    # Returns the name the world was given.
    #
    #   returns    a text
    #   see        init
    #@ aka  == Identity & substance =================================================
    def Name()
        return @cName

    # Returns the graph that holds the world's things and instances.
    #
    #   returns    a stzGraph
    #   note       the graph ids are in lower case, whatever the case of the names given
    #   see        AddThing, AddInstance, Relate
    def GraphQ()
        return @oGraph

    # Declares a kind of thing, or selects it if already declared, and makes it the one that Has, IsTrue, Owns and Of describe.
    #
    #   pcName     the thing's name
    #   returns    nothing; use AddThingQ to chain or to open a brace
    #   note       calling it again with the same name selects the thing and adds no copy
    #   see        Has, IsTrue, Owns, Of, Things
    #@ aka  == DOMAIN (Being) ======================================================= AddThing() performs the act and returns NOTHING; AddThingQ() performs it and hands back the app, so the block AddThingQ(:X) { Has(...) Owns(:Y) } runs the app's OWN Has/IsTrue/Owns/Of on the current-thing cursor. (The core law: a plain name acts, the Q chains -- exactly as stzList does with AddItem() / AddItemQ().)
    def AddThing(pcName)
        # sigil'd: a bare `n` binds a caller's global of that name
        _n_ = This._ThingIndex(pcName)
        if _n_ = 0
            if NOT @oGraph.NodeExists(pcName)
                @oGraph.AddNode(pcName)
            ok
            @aThings + [ pcName, [], [], [] ]
            _n_ = len(@aThings)
        ok
        @nCur = _n_

        def AddThingQ(pcName)
            This.AddThing(pcName)
            return This

    # Sets the field names of the thing just added, replacing any set before.
    #
    #   paFields   a list of field names
    #   returns    the world itself, so calls chain
    #   note       with no thing added yet it does nothing
    #   see        AddThing, Things
    def Has(paFields)                       # fields of the current thing
        if @nCur > 0  @aThings[@nCur][2] = paFields  ok
        return This

    # Adds a truth to the thing just added: a field name and the expression that holds for it.
    #
    #   pcField    the field the truth is about
    #   pcExpr     the expression that must hold, such as > 18
    #   returns    the world itself, so calls chain
    #   note       Explain shows it as true when
    #   see        Has, Explain
    def IsTrue(pcField, pcExpr)             # a truth of the current thing
        if @nCur > 0  @aThings[@nCur][3] + [ pcField, pcExpr ]  ok
        return This

    # Adds the relation owns toward another thing to the thing just added.
    #
    #   pcThing    the thing that is owned
    #   returns    the world itself, so calls chain
    #   see        Of, AddRelation, Explain
    def Owns(pcThing)                       # a relation of the current thing
        if @nCur > 0  @aThings[@nCur][4] + [ "owns", pcThing ]  ok
        return This

    # Adds the relation of toward another thing to the thing just added.
    #
    #   pcThing    the thing that this one belongs to
    #   returns    the world itself, so calls chain
    #   see        Owns, AddRelation, Explain
    def Of(pcThing)
        if @nCur > 0  @aThings[@nCur][4] + [ "of", pcThing ]  ok
        return This

    # Declares a free relation between two things, kept apart from the things' own Owns and Of.
    #
    #   pcFrom       the first thing
    #   pcRelation   the relation's name
    #   pcTo         the second thing
    #   returns      nothing; use AddRelationQ to chain
    #   note         it is shown by Explain only: it adds no edge to the graph, unlike Relate
    #   see          Owns, Relate, Explain
    def AddRelation(pcFrom, pcRelation, pcTo)     # a free relation between two things
        @aKnows + [ pcFrom, pcRelation, pcTo ]

    #== BEING -- INSTANCES ===================================================
    # Schema things are declared; INSTANCES populate them. An instance
    # binds to its thing by an "isa" edge; instance relations are
    # labeled edges. Goals (wanted graph states) evaluate over these.

        def AddRelationQ(pcFrom, pcRelation, pcTo)
            This.AddRelation(pcFrom, pcRelation, pcTo)
            return This

    # Adds a named individual to the graph, linked to its kind of thing by an isa edge.
    #
    #   pcInstance   the individual's name
    #   pcThing      the thing it is an instance of
    #   returns      nothing; use AddInstanceQ to chain
    #   note         the nodes are created if absent
    #   see          Relate, AddThing, Pursue
    def AddInstance(pcInstance, pcThing)
        if NOT @oGraph.NodeExists(pcInstance)
            @oGraph.AddNode(pcInstance)
        ok
        if NOT @oGraph.NodeExists(pcThing)
            @oGraph.AddNode(pcThing)
        ok
        @oGraph.AddEdgeXT(pcInstance, pcThing, "isa")

        def AddInstanceQ(pcInstance, pcThing)
            This.AddInstance(pcInstance, pcThing)
            return This

    # Adds a labelled edge between two nodes of the graph, creating either node when absent.
    #
    #   pcFrom       the source node, usually an instance
    #   pcRelation   the label of the edge
    #   pcTo         the target node
    #   returns      the world itself, so calls chain
    #   note         goals and reactions are judged on these edges
    #   see          AddInstance, Pursue, Pulse
    def Relate(pcFrom, pcRelation, pcTo)
        if NOT @oGraph.NodeExists(pcFrom)
            @oGraph.AddNode(pcFrom)
        ok
        if NOT @oGraph.NodeExists(pcTo)
            @oGraph.AddNode(pcTo)
        ok
        @oGraph.AddEdgeXT(pcFrom, pcTo, "" + pcRelation)
        return This

    # Declares that an actor performs a verb on a thing, and makes it the flow that Require and Then complete.
    #
    #   pcActor    who acts
    #   pcVerb     what is done
    #   pcThing    what it is done to
    #   returns    nothing; use AddFlowQ to chain
    #   see        Require, Then, Explain
    #@ aka  == LIFE - BEHAVIOR (Becoming) =========================================== When() returns This: the brace { Require(:x) Then( Keep(:Y) ) } runs app methods against the current-flow cursor.
    def AddFlow(pcActor, pcVerb, pcThing)
        This._FlushCursors()
        @aFlows + [ pcActor, pcVerb, pcThing, [], [] ]
        @nCurFlow = len(@aFlows)

        def AddFlowQ(pcActor, pcVerb, pcThing)
            This.AddFlow(pcActor, pcVerb, pcThing)
            return This

    # Adds a required field to the flow just added.
    #
    #   pcField    the field that must be present
    #   returns    the world itself, so calls chain
    #   note       with no flow added yet it does nothing
    #   see        AddFlow, Then
    def Require(pcField)
        if @nCurFlow > 0  @aFlows[@nCurFlow][4] + pcField  ok
        return This

    # Returns the effect list that tells a flow to keep a thing, for Then to take.
    #
    #   pcThing    the thing to keep
    #   returns    a list of two items, the word keep and the thing
    #   note       it records nothing by itself, and inside a SetBody brace the name Keep also reads
    #              as an attribute
    #   see        Then
    def Keep(pcThing)
        return [ :keep, pcThing ]

    # Adds an effect to the flow just added.
    #
    #   paEffect   the effect, such as the list that Keep returns
    #   returns    the world itself, so calls chain
    #   note       Explain narrates any effect as then keep followed by the flow's thing
    #   see        Keep, Require, Explain
    def Then(paEffect)
        if @nCurFlow > 0  @aFlows[@nCurFlow][5] + paEffect  ok
        return This

    # Declares a reaction of a kind of thing, and makes it the one that Unseen, Meets and Propose complete.
    #
    #   pcThing    the thing whose instances the reaction watches
    #   returns    nothing; use AddReactionQ to chain
    #   see        Unseen, Meets, Propose, Pulse
    def AddReaction(pcThing)
        This._FlushCursors()
        @aReactions + [ pcThing, "", [], [] ]
        @nCurReaction = len(@aReactions)

        def AddReactionQ(pcThing)
            This.AddReaction(pcThing)
            return This

    # Sets the condition of the reaction just added to an instance left unseen for a length of time.
    #
    #   nQty       the length
    #   pUnit      its unit, such as Days
    #   returns    the world itself, so calls chain
    #   note       the condition is only narrated by Explain: Pulse does not test it
    #   see        AddReaction, Meets
    def Unseen(nQty, pUnit)
        if @nCurReaction > 0
            @aReactions[@nCurReaction][2] = :unseen
            @aReactions[@nCurReaction][3] = [ nQty, pUnit ]
        ok
        return This

    # Sets the condition of the reaction just added to an expression that must hold.
    #
    #   pcExpr     the expression, such as total > 100
    #   returns    the world itself, so calls chain
    #   note       the condition is only narrated by Explain: Pulse does not test it
    #   see        AddReaction, Unseen
    def Meets(pcExpr)
        if @nCurReaction > 0
            @aReactions[@nCurReaction][2] = :expr
            @aReactions[@nCurReaction][3] = [ pcExpr ]
        ok
        return This

    # Adds to the reaction just added the thing it proposes when it fires.
    #
    #   pcThing    the thing to propose
    #   returns    the world itself, so calls chain
    #   note       Pulse proposes it for each instance that lacks a relation of that name
    #   see        AddReaction, Pulse, Proposals
    def Propose(pcThing)
        if @nCurReaction > 0  @aReactions[@nCurReaction][4] + [ :propose, pcThing ]  ok
        return This

    # Declares a goal, and makes it the one that the brace assigns Means, ReachedBy, Within and Respecting to.
    #
    #   pcGoal     the goal's name
    #   returns    nothing; use AddGoalQ to chain or to open a brace
    #   note       the Means is read when the brace closes, so assign it inside AddGoalQ(name) { }
    #   see        Goal, Pursue, GoalSatisfied
    #@ aka  == LIFE - PURPOSE (Becoming) ============================================ AddGoal() returns This; the brace assigns the goal-cursor ATTRIBUTES (Means/ReachedBy/Within/Respecting), flushed into the record by BraceEnd() when the brace closes.
    def AddGoal(pcGoal)
        This._FlushCursors()
        @aGoals + [ pcGoal, "", :planning, "", [] ]
        @nCurGoal = len(@aGoals)
        Means      = ""
        ReachedBy  = :planning
        Within     = ""
        Respecting = []

        def AddGoalQ(pcGoal)
            This.AddGoal(pcGoal)
            return This

    def GoalQ(pcGoal)
        for i = 1 to len(@aGoals)
            if @aGoals[i][1] = pcGoal
                _oG_ = new stzAppGoal(@aGoals[i][1])
                _oG_.Means      = @aGoals[i][2]
                _oG_.ReachedBy  = @aGoals[i][3]
                _oG_.Within     = @aGoals[i][4]
                _oG_.Respecting = @aGoals[i][5]
                return _oG_
            ok
        next
        return ""

    # Returns a goal as plain data.
    #
    #   pcGoal     the goal's name
    #   returns    a hash list with the keys name, means, reachedby, within and respecting; an empty
    #              list for an unknown goal
    #   see        GoalName, GoalNames, Pursue
    #@ aka  THE DATA FORM (the house rule: a plain name returns DATA, the Q form returns the OBJECT). A goal as a plain record -- nothing to chain on.
    def Goal(pcGoal)
        for i = 1 to len(@aGoals)
            if @aGoals[i][1] = pcGoal
                return [ :name = @aGoals[i][1], :means = @aGoals[i][2],
                         :reachedBy = @aGoals[i][3], :within = @aGoals[i][4],
                         :respecting = @aGoals[i][5] ]
            ok
        next
        return []

    # Returns the goal's name if the goal is declared.
    #
    #   pcGoal     the goal's name
    #   returns    a text; empty for an unknown goal
    #   see        Goal, GoalNames
    #@ aka  just the goal's NAME -- said precisely, since that is all it returns
    def GoalName(pcGoal)
        for i = 1 to len(@aGoals)
            if @aGoals[i][1] = pcGoal  return @aGoals[i][1]  ok
        next
        return ""

    # Returns the names of all declared goals in declaration order.
    #
    #   returns    a list of texts
    #   see        Goal
    def GoalNames()
        _ac_ = []
        for i = 1 to len(@aGoals)
            _ac_ + @aGoals[i][1]
        next
        return _ac_

    # Measures the gap between the world graph and the goal, and turns each instance in the gap into a proposal.
    #
    #   pcGoal     the goal's name
    #   returns    a list of proposals such as propose Visit for bilal, empty when the gap is closed
    #              or the goal is unknown
    #   note       the proposal comes from the reaction that proposes for the goal's kind of thing,
    #              else the proposal is attend; the list also replaces Proposals
    #   warning    it prints one pursuing line to the console, and it raises an error when the Means
    #              has no every :Thing clause
    #   see        GoalSatisfied, Proposals, Relate
    #@ aka  THE REAL PURSUIT: compile the goal's Means into an stzGraphGoal (a wanted graph state), measure the GAP on the live world graph, and turn each gap instance into a proposal through the matching Whenever/Propose reaction (or a bare :attend proposal when no reaction declares the way).
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

    # TRUE if the world graph already meets the goal.
    #
    #   pcGoal     the goal's name
    #   returns    1 or 0; 0 for an unknown goal
    #   warning    it raises an error when the Means has no every :Thing clause
    #   see        Pursue, Goal
    def GoalSatisfied(pcGoal)
        for i = 1 to len(@aGoals)
            if @aGoals[i][1] = pcGoal
                oWanted = new stzGraphGoal(pcGoal)
                oWanted.FromMeans(@aGoals[i][2])
                return oWanted.SatisfiedOn(@oGraph)
            ok
        next
        return 0

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

    # Declares where the world is kept, a kind or a list of kinds such as GraphDB, and opens a brace to name its paths.
    #
    #   pBody      a kind or a list of kinds of body
    #   returns    the world itself, so calls chain
    #   note       inside the brace, assign Graph, Files and Keep, which are read when the brace
    #              closes
    #   see        Body, Save, Explain
    #@ aka  == BODY (embodiment) ==================================================== SetBody() returns This; the brace assigns the body-cursor attributes (Graph_/Files/Keep_ -- note: the DSL keywords Graph and Keep collide with the Graph() accessor and the Keep(thing) flow verb, so the ATTRIBUTES carry a trailing underscore and BraceEnd reads whichever was written).
    def SetBody(pBody)
        This._FlushCursors()
        @aKinds = pBody
        if NOT isList(pBody)  @aKinds = [ pBody ]  ok
        @aBody = [ @aKinds, "", "", "" ]
        @bBodyPending = 1
        Graph = ""
        Files = ""
        Keep  = ""
        return This

    def BodyQ()
        if len(@aBody) = 0  return ""  ok
        _oB_ = new stzAppBody(@aBody[1])
        _oB_.Graph = @aBody[2]
        _oB_.Files = @aBody[3]
        _oB_.Keep  = @aBody[4]
        return _oB_

    # Returns the body as plain data.
    #
    #   returns    a hash list with the keys label, graph, files and keep; an empty list when no
    #              body was set
    #   see        SetBody, Save
    #@ aka  the body as DATA (the Q form above returns the object)
    def Body()
        if len(@aBody) = 0  return []  ok
        return [ :label = @aBody[1], :graph = @aBody[2], :files = @aBody[3], :keep = @aBody[4] ]

    # Writes the world graph to its graph file when the body includes GraphDB, and does nothing otherwise.
    #
    #   returns    the world itself, so calls chain
    #   note       with no body it writes nothing
    #   warning    a path defaults to .stzapp/world.stzgraf in the current folder, which is created
    #              if needed
    #   see        SetBody, Body
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
        if len(@aBody) = 0  return 0  ok
        for i = 1 to len(@aBody[1])
            if @aBody[1][i] = pKind  return 1  ok
        next
        return 0

    def _EnsureParentDir(pcPath)
        nSlash = 0
        for i = 1 to len(pcPath)
            if pcPath[i] = "/"  nSlash = i  ok
        next
        if nSlash > 1
            StzMakeDir(StzLeft(pcPath, nSlash - 1))
        ok

    # Declares a screen, and makes it the one that the To verbs, Shows and Acts describe.
    #
    #   pcName     the screen's name
    #   returns    nothing; use AddScreenQ to chain
    #   note       its intent is understand until a To verb says otherwise
    #   see        ToDiscover, Shows, Acts, ScreenNames
    #@ aka  == EMERGENTS (met from without) =========================================
    def AddScreen(pcName)
        This._FlushCursors()
        @aScreens + [ pcName, "understand", "", [], [] ]
        @nCurScreen = len(@aScreens)

        def AddScreenQ(pcName)
            This.AddScreen(pcName)
            return This

    # Sets the screen just added to the intent discover, about a thing.
    #
    #   pcThing    the thing the screen is about
    #   returns    the world itself, so calls chain
    #   see        ToUnderstand, ToFocus, ToSelect, ToAct
    def ToDiscover(pcThing)
        return This._ScreenIntent("discover", pcThing)
    # Sets the screen just added to the intent understand, about a thing.
    #
    #   pcThing    the thing the screen is about
    #   returns    the world itself, so calls chain
    #   see        ToDiscover, ToFocus
    def ToUnderstand(pcThing)
        return This._ScreenIntent("understand", pcThing)
    # Sets the screen just added to the intent focus, about a thing.
    #
    #   pcThing    the thing the screen is about
    #   returns    the world itself, so calls chain
    #   see        ToDiscover, ToSelect
    def ToFocus(pcThing)
        return This._ScreenIntent("focus", pcThing)
    # Sets the screen just added to the intent select, about a thing.
    #
    #   pcThing    the thing the screen is about
    #   returns    the world itself, so calls chain
    #   see        ToFocus, ToAct
    def ToSelect(pcThing)
        return This._ScreenIntent("select", pcThing)
    # Sets the screen just added to the intent act, about a thing.
    #
    #   pcThing    the thing the screen is about
    #   returns    the world itself, so calls chain
    #   see        ToSelect, Acts
    def ToAct(pcThing)
        return This._ScreenIntent("act", pcThing)

    def _ScreenIntent(pcIntent, pcThing)
        if @nCurScreen > 0
            @aScreens[@nCurScreen][2] = pcIntent
            @aScreens[@nCurScreen][3] = pcThing
        ok
        return This

    # Sets what the screen just added shows.
    #
    #   paParts    a list of part names
    #   returns    the world itself, so calls chain
    #   note       it replaces any parts set before
    #   see        AddScreen, Acts
    def Shows(paParts)
        if @nCurScreen > 0  @aScreens[@nCurScreen][4] = paParts  ok
        return This

    # Adds an action of the screen just added, tied to a flow.
    #
    #   pcAction   the action's name
    #   pcFlow     the flow it triggers
    #   returns    the world itself, so calls chain
    #   see        Shows, AddFlow
    def Acts(pcAction, pcFlow)
        if @nCurScreen > 0  @aScreens[@nCurScreen][5] + [ pcAction, pcFlow ]  ok
        return This

    # Declares a knob that a person may tune, and makes it the one that Bounds and Options describe.
    #
    #   pcKnob     the knob's name
    #   returns    nothing; use AddRefinementQ to chain
    #   see        Bounds, Options, Explain
    def AddRefinement(pcKnob)
        This._FlushCursors()
        @aRefinements + [ pcKnob, "", "", [] ]
        @nCurRefinement = len(@aRefinements)

        def AddRefinementQ(pcKnob)
            This.AddRefinement(pcKnob)
            return This

    # Sets the lowest and highest value of the knob just added.
    #
    #   pLow       the lowest value
    #   pHigh      the highest value
    #   returns    the world itself, so calls chain
    #   note       the values are stored as text and Explain narrates them as bounds [1..99]
    #   see        AddRefinement, Options
    def Bounds(pLow, pHigh)
        if @nCurRefinement > 0
            @aRefinements[@nCurRefinement][2] = "" + pLow
            @aRefinements[@nCurRefinement][3] = "" + pHigh
        ok
        return This

    # Sets the list of choices of the knob just added.
    #
    #   paOpts     a list of the allowed values
    #   returns    the world itself, so calls chain
    #   note       Explain shows the options only when no bounds were set
    #   see        AddRefinement, Bounds
    def Options(paOpts)
        if @nCurRefinement > 0  @aRefinements[@nCurRefinement][4] = paOpts  ok
        return This

    # Returns the surfaces on which the world appears, as declared by AddReaches.
    #
    #   returns    a list of surface names
    #   note       a surface added as a single text or symbol is stored wrongly today, see
    #              AddReaches
    #   see        AddReaches, Things
    #@ aka  THE DECLARATIONS, AS DATA. Anything outside (stzPlatform harvesting a world, a generator, a doc tool) asks through these -- it never reaches into the @attributes. AddReaches([...]) DECLARES the surfaces; Surfaces() reports them.
    def Surfaces()
        return @aReaches

    # Returns the declared things with their fields.
    #
    #   returns    a list of lists, each with the thing's name and its list of field names
    #   see        AddThing, Has
    #@ aka  [ [ thingName, [fields] ], ... ]
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

    # Returns the names of the declared screens in order.
    #
    #   returns    a list of texts
    #   see        AddScreen
    def ScreenNames()
        _ac_ = []
        _n_ = len(@aScreens)
        for _i_ = 1 to _n_
            _ac_ + @aScreens[_i_][1]
        next
        return _ac_

    # Declares the surfaces, such as web, desktop or mobile, on which the world appears.
    #
    #   paSurfaces   a list of surface names
    #   returns      nothing; use AddReachesQ to chain
    #   note         the list is added to the surfaces already declared
    #   warning      a single text or symbol is stored as [ [ ] ] today, so give a list: Surfaces
    #                then holds an unusable entry and both Explain and a platform's Generate raise
    #                an error
    #   see          Surfaces, AddReachesQ
    def AddReaches(paSurfaces)
        if NOT isList(paSurfaces)  paSurfaces = [ paSurfaces ]  ok
        for i = 1 to len(paSurfaces)
            @aReaches + paSurfaces[i]
        next

    #== CURSOR FLUSHING ======================================================
    # Attribute-style braces (Want/LivesIn) write cursor ATTRIBUTES;
    # Ring's BraceEnd hook fires when any brace on the app closes, so
    # the flush is idempotent and cursor-guarded. _FlushCursors() also
    # runs at the start of every builder verb, so a missing brace-end
    # (or plain method chaining) never loses a pending record.

        def AddReachesQ(paSurfaces)
            This.AddReaches(paSurfaces)
            return This

    # Writes the pending goal and body assignments of a brace into their records.
    #
    #   returns    nothing
    #   note       it is called for you when a brace closes, and every builder verb does the same
    #              first
    #   see        AddGoal, SetBody
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
            @bBodyPending = 0
        ok

    # Turns the world on, runs a first Pulse and prints a one-line summary of its things, flows, reactions, goals and proposals.
    #
    #   returns    the world itself, so calls chain
    #   warning    it prints to the console
    #   see        Pulse, IsLive, Proposals
    #@ aka  == ANIMATION ============================================================
    def Live()
        This._FlushCursors()
        @oReactive = new stzReactiveSystem()
        @bLive = 1
        This.Pulse()
        ? "[" + @cName + "] is live -- " + len(@aThings) + " thing(s), " +
          len(@aFlows) + " flow(s), " + len(@aReactions) + " reaction(s), " +
          len(@aGoals) + " goal(s); " + len(@aProposals) + " proposal(s)"
        return This

    # TRUE if Live was called.
    #
    #   returns    1 or 0
    #   see        Live
    def IsLive()
        return @bLive

    # Fires every reaction against the graph, adding one proposal for each instance that lacks the relation the reaction proposes.
    #
    #   returns    a number, how many proposals were added
    #   note       it is idempotent: a standing proposal is not repeated, and one clears on the next
    #              pulse once the instance gets the relation
    #   see        React, Proposals, Relate
    #@ aka  PULSE: evaluate every reaction against the live world. A reaction 'Whenever :Thing ... Propose :Other' fires for each INSTANCE of Thing that lacks an <other>-labeled relation -- producing one proposal per gap (the same structural gap the goal machinery measures). Idempotent: a proposal already standing is not duplicated, and once the world Relate()s the instance the proposal clears on the next pul
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

    # Returns the proposals now standing.
    #
    #   returns    a list of lists such as propose Visit for bilal
    #   see        Pulse, Pursue
    def Proposals()
        return @aProposals

    # Fires the reactions for one instance only, as Pulse does for all.
    #
    #   pcInstance   the instance's name
    #   returns      a number, how many proposals were added
    #   note         it first drops the proposals that the graph now satisfies
    #   see          Pulse, Proposals
    #@ aka  React to an EVENT on one instance: pulse just that instance's reactions. Returns proposals added.
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
                return 1
            ok
        next
        return 0

    def _InstanceHasRelation(pcInstance, pcRelation)
        cI = StzLower("" + pcInstance)
        # NOT cR: that name IS the CR carriage-return constant.
        cRel = StzLower("" + pcRelation)
        aE = @oGraph.Edges()
        for i = 1 to len(aE)
            if aE[i][:from] = cI and StzLower("" + aE[i][:label]) = cRel
                return 1
            ok
        next
        return 0

    def _ProposalStands(pcThing, pcInstance)
        for i = 1 to len(@aProposals)
            if @aProposals[i][2] = pcThing and @aProposals[i][4] = pcInstance
                return 1
            ok
        next
        return 0

    def _PruneSatisfiedProposals()
        aKept = []
        for i = 1 to len(@aProposals)
            if NOT This._InstanceHasRelation(@aProposals[i][4], @aProposals[i][2])
                aKept + @aProposals[i]
            ok
        next
        @aProposals = aKept

    # Prints the world in plain words: its things, relations, flows, reactions, goals, screens, knobs and reaches.
    #
    #   returns    the world itself, so calls chain
    #   note       it raises an error when a surface was added as a single text, see AddReaches
    #   warning    it prints to the console
    #   see        Show, Things
    #@ aka  == PRESENCE (emergent) -- make the world visible ========================
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

    # Prints one thing with its fields, truths and relations.
    #
    #   pcThing    the name of a declared thing
    #   returns    the world itself, so calls chain
    #   note       an unknown name prints a no such thing line instead of failing
    #   warning    it prints to the console
    #   see        Explain, Things
    def Show(pcThing)
        _n_ = This._ThingIndex(pcThing)
        if _n_ = 0  ? "(no such thing: " + pcThing + ")"  return This ok
        ? @aThings[_n_][1] + " (" + This._Join(@aThings[_n_][2], ", ") + ")"
        for _j_ = 1 to len(@aThings[_n_][3])
            ? "  true when " + @aThings[_n_][3][_j_][1] + " " + @aThings[_n_][3][_j_][2]
        next
        for _j_ = 1 to len(@aThings[_n_][4])
            ? "  " + @aThings[_n_][4][_j_][1] + " " + @aThings[_n_][4][_j_][2]
        next
        return This

    #== narration (formats are CANONICAL -- narration docs rule) =============

    def _NarrateFlow(n)
        # NOT cR: that name IS the CR carriage-return constant.
        cReq = ""
        if len(@aFlows[n][4]) > 0  cReq = " require " + This._Join(@aFlows[n][4], ", ")  ok
        cE = ""
        if len(@aFlows[n][5]) > 0  cE = " then keep " + @aFlows[n][3]  ok
        return "when " + @aFlows[n][1] + " " + @aFlows[n][2] + " " + @aFlows[n][3] + cReq + cE

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
        if len(@aKnows) > 0  return 1  ok
        for i = 1 to len(@aThings)
            if len(@aThings[i][4]) > 0  return 1  ok
        next
        return 0

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
    # Keep is the third thing SetBody's brace collects (Graph / Files / Keep).
    # It was gathered into the body and then surfaced by nothing -- not here, not
    # in Body(), not in BodyQ() -- so a world that said "Keep = :everything" had
    # no way to be asked what it keeps.
    Keep  = ""
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
            if @aKinds[i] = pKind  return 1  ok
        next
        return 0
    def Narrate()
        return "lives in " + This.Label()
