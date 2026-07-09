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
# VALIDATION STATUS (runs under Ring): Slice A (Being) is GREEN -- things, fields,
# truths, and relations all persist and print. The nested-brace idiom is preserved
# by having Thing() return This (the app): so Has/IsTrue/Owns/Of are the app's own
# methods operating on a "current thing" cursor over plain app-held lists -- which
# sidesteps Ring's value-copy semantics (objects copy when stored in lists/attrs) and
# a SetNodeProperty round-trip bug in stzGraph. The B..E builders below still use the
# sub-builder shape and need the same cursor/method conversion to persist their brace
# data (goals/body attribute-style -> a hashlist form). Ring gotchas found in validation:
#   reserved names Load/Import/Put/Set/Get; var oR == keyword 'or' (case-insensitive);
#   top-level code before class defs; new X(){} fails but method(){} braces work; R31.
# NB hardening: prefer ring_len()/engine helpers in class scope; Unicode-safe stringify.
# -----------------------------------------------------------------------------

func StzApp(pcName)
    return new stzApp(pcName)

class stzApp from stzObject

    cName        = ""
    oGraph       = NULL           # the world's domain graph (node registry)   (Being)
    aThings      = []            # [ [ name, [fields], [ [field,expr] ], [ [rel,to] ] ], ... ]
    aKnows       = []            # [ [ from, relation, to ], ... ]   (free relations)
    nCur         = 0             # cursor: index of the thing being declared
    aFlows       = []            # (Life - behavior)   -- sub-builder shape (see note above)
    aReactions   = []
    aGoals       = []            # (Life - purpose)
    oBody        = NULL           # (Body)
    aScreens     = []            # (Intent)
    aRefinements = []            # (Refinement)
    aReaches     = []            # (Reach)
    oReactive    = NULL

    def init(pcName)
        cName        = pcName
        oGraph       = new stzGraph(pcName)
        aThings      = []
        aKnows       = []
        nCur         = 0
        aFlows       = []
        aReactions   = []
        aGoals       = []
        aScreens     = []
        aRefinements = []
        aReaches     = []

    #== Identity & substance =================================================

    def Name()
        return cName

    def Graph()
        return oGraph

    #== DOMAIN (Being) =======================================================
    # Thing() returns This, so the block  Thing(:X) { Has(...) Owns(:Y) }  runs the
    # app's OWN Has/Owns on the current-thing cursor -> real, persistent, R31-safe.

    def Thing(pcName)
        n = This._ThingIndex(pcName)
        if n = 0
            if NOT oGraph.NodeExists(pcName)
                oGraph.AddNode(pcName)
            ok
            aThings + [ pcName, [], [], [] ]
            n = len(aThings)
        ok
        nCur = n
        return This

    def Has(paFields)                       # fields of the current thing
        if nCur > 0  aThings[nCur][2] = paFields  ok
        return This

    def IsTrue(pcField, pcExpr)             # a truth of the current thing (two-arg -- real Ring)
        if nCur > 0  aThings[nCur][3] + [ pcField, pcExpr ]  ok
        return This

    def Owns(pcThing)                       # a relation of the current thing
        if nCur > 0  aThings[nCur][4] + [ "owns", pcThing ]  ok
        return This

    def Of(pcThing)
        if nCur > 0  aThings[nCur][4] + [ "of", pcThing ]  ok
        return This

    def Knows(pcFrom, pcRelation, pcTo)     # a free relation between two things
        aKnows + [ pcFrom, pcRelation, pcTo ]
        return This

    #== LIFE - BEHAVIOR (Becoming) ===========================================

    def When(pcActor, pcVerb, pcThing)
        oF = new stzAppFlow(pcActor, pcVerb, pcThing, This)
        aFlows + oF
        return oF

    def Whenever(pcThing)
        oRe = new stzAppReaction(pcThing, This)
        aReactions + oRe
        return oRe

    #== LIFE - PURPOSE (Becoming) ============================================

    def Want(pcGoal)
        oG = new stzAppGoal(pcGoal, This)
        aGoals + oG
        return oG

    def Goal(pcGoal)
        for i = 1 to len(aGoals)
            if aGoals[i].Name() = pcGoal  return aGoals[i]  ok
        next
        return NULL

    def Pursue(pcGoal)
        oG = This.Goal(pcGoal)
        if oG = NULL  return []  ok
        oPlanner = new stzGraphPlanner(oGraph)
        oPlanner.Using(oG.Profile())
        aProposals = oG.Gap()
        ? "pursuing " + pcGoal + " via " + oG.ReachedBy + " -- " + len(aProposals) + " proposal(s)"
        return aProposals

    #== BODY (embodiment) ====================================================

    def LivesIn(pBody)
        aKinds = pBody
        if NOT isList(pBody)  aKinds = [ pBody ]  ok
        oBody = new stzAppBody(aKinds, This)
        return oBody

    def Body()
        return oBody

    def Save()
        if oBody != NULL  oBody.Save()  ok
        return This

    #== EMERGENTS (met from without) =========================================

    def Screen(pcName)
        oS = new stzAppScreen(pcName, This)
        aScreens + oS
        return oS

    def Refine(pcKnob)
        oRe = new stzAppRefinement(pcKnob, This)
        aRefinements + oRe
        return oRe

    def Reaches(paSurfaces)
        if NOT isList(paSurfaces)  paSurfaces = [ paSurfaces ]  ok
        for i = 1 to len(paSurfaces)
            aReaches + paSurfaces[i]
        next
        return This

    #== ANIMATION ============================================================

    def Live()
        oReactive = new stzReactiveSystem()
        ? "[" + cName + "] is live -- " + len(aThings) + " thing(s), " +
          len(aFlows) + " flow(s), " + len(aReactions) + " reaction(s), " +
          len(aGoals) + " goal(s)"
        return This

    #== PRESENCE (emergent) -- make the world visible ========================

    def Explain()
        ? "WORLD " + cName + "   lives in: " + This._BodyLabel()
        ? "  BEING"
        for i = 1 to len(aThings)
            cLine = "    " + aThings[i][1]
            if len(aThings[i][2]) > 0
                cLine += " (" + This._Join(aThings[i][2], ", ") + ")"
            ok
            ? cLine
            for j = 1 to len(aThings[i][3])
                ? "        true when " + aThings[i][3][j][1] + " " + aThings[i][3][j][2]
            next
        next
        if This._HasAnyRelation()
            ? "  RELATIONS"
            for i = 1 to len(aThings)
                for j = 1 to len(aThings[i][4])
                    ? "    " + aThings[i][1] + " " + aThings[i][4][j][1] + " " + aThings[i][4][j][2]
                next
            next
            for i = 1 to len(aKnows)
                ? "    " + aKnows[i][1] + " " + aKnows[i][2] + " " + aKnows[i][3]
            next
        ok
        if len(aFlows) > 0 or len(aReactions) > 0 or len(aGoals) > 0
            ? "  BECOMING"
            for i = 1 to len(aFlows)      ? "    " + aFlows[i].Narrate()      next
            for i = 1 to len(aReactions)  ? "    " + aReactions[i].Narrate()  next
            for i = 1 to len(aGoals)      ? "    " + aGoals[i].Narrate()      next
        ok
        if len(aScreens) > 0 or len(aRefinements) > 0 or len(aReaches) > 0
            ? "  MET FROM WITHOUT"
            for i = 1 to len(aScreens)      ? "    " + aScreens[i].Narrate()      next
            for i = 1 to len(aRefinements)  ? "    " + aRefinements[i].Narrate()  next
            if len(aReaches) > 0  ? "    reaches " + This._Join(aReaches, ", ")  ok
        ok
        return This

    def Show(pcThing)
        n = This._ThingIndex(pcThing)
        if n = 0  ? "(no such thing: " + pcThing + ")"  return This ok
        ? aThings[n][1] + " (" + This._Join(aThings[n][2], ", ") + ")"
        for j = 1 to len(aThings[n][3])
            ? "  true when " + aThings[n][3][j][1] + " " + aThings[n][3][j][2]
        next
        for j = 1 to len(aThings[n][4])
            ? "  " + aThings[n][4][j][1] + " " + aThings[n][4][j][2]
        next
        return This

    #== internals ============================================================

    def _ThingIndex(pcThing)
        for i = 1 to len(aThings)
            if aThings[i][1] = pcThing  return i  ok
        next
        return 0

    def _HasAnyRelation()
        if len(aKnows) > 0  return TRUE  ok
        for i = 1 to len(aThings)
            if len(aThings[i][4]) > 0  return TRUE  ok
        next
        return FALSE

    def _GapFor(oGoal)
        return []

    def _BodyLabel()
        if oBody = NULL  return "memory (not persisted)"  ok
        return oBody.Label()

    def _Join(paList, cSep)
        cRes = ""
        for i = 1 to len(paList)
            cRes += "" + paList[i]
            if i < len(paList)  cRes += cSep  ok
        next
        return cRes


# stzAppFlow -- the  When(:actor,:verb,:Thing) { Require - Then }  builder (behavior).
class stzAppFlow from stzObject
    cActor = ""  cVerb = ""  cThing = ""  oApp = NULL
    aRequires = []  aEffects = []
    def init(pcActor, pcVerb, pcThing, poApp)
        cActor = pcActor  cVerb = pcVerb  cThing = pcThing  oApp = poApp
        aRequires = []  aEffects = []
    def Require(pcField)
        aRequires + pcField  return This
    def Keep(pcThing)
        return [ :keep, pcThing ]
    def Then(paEffect)
        aEffects + paEffect  return This
    def Matches(pcA, pcV, pcT)
        return cActor = pcA and cVerb = pcV and cThing = pcT
    def Narrate()
        cR = "" if len(aRequires) > 0  cR = " require " + oApp._Join(aRequires, ", ")  ok
        cE = "" if len(aEffects)  > 0  cE = " then keep " + cThing  ok
        return "when " + cActor + " " + cVerb + " " + cThing + cR + cE
    def Build()
        oWF = new stzWorkflow(cActor + "_" + cVerb + "_" + cThing)
        oWF.AddActor(cActor, cActor, "actor")
        oWF.AddStepXT(cVerb, cVerb + " " + cThing)
        oWF.AssignStepTo(cVerb, cActor)
        return oWF


# stzAppReaction -- the  Whenever(:Thing).Unseen(n,:Unit) { Propose(...) }  builder (behavior).
class stzAppReaction from stzObject
    cThing = ""  oApp = NULL
    cCondKind = ""  aCondArgs = []  aEffects = []
    def init(pcThing, poApp)
        cThing = pcThing  oApp = poApp  aCondArgs = []  aEffects = []
    def Unseen(nQty, pUnit)
        cCondKind = :unseen  aCondArgs = [ nQty, pUnit ]  return This
    def Meets(pcExpr)
        cCondKind = :expr  aCondArgs = [ pcExpr ]  return This
    def Propose(pcThing)
        aEffects + [ :propose, pcThing ]  return This
    def Narrate()
        cC = cCondKind if cCondKind = :unseen  cC = "unseen " + aCondArgs[1] + " " + aCondArgs[2]  ok
        cE = "" if len(aEffects) > 0  cE = " -> propose " + aEffects[1][2]  ok
        return "whenever " + cThing + " " + cC + cE
    def RegisterIn(poReactive)
        return This


# stzAppGoal -- the  Want(:Goal) { Means = ...  ReachedBy = ... }  builder (purpose).
class stzAppGoal from stzObject
    cName = ""  oApp = NULL
    Means      = ""
    ReachedBy  = :planning
    Within     = ""
    Respecting = []
    def init(pcName, poApp)
        cName = pcName  oApp = poApp  Respecting = []
    def Name()
        return cName
    def Profile()
        return ReachedBy
    def Satisfied()
        return len(This.Gap()) = 0
    def Gap()
        return oApp._GapFor(This)
    def Narrate()
        cW = "" if Within != ""  cW = " within " + Within  ok
        return "wants " + cName + cW + " -> reached by " + ReachedBy


# stzAppBody -- the  LivesIn(...) { Graph = ...  Files = ... }  builder (embodiment).
class stzAppBody from stzObject
    aKinds = []  oApp = NULL
    Graph = ""
    Files = ""
    Keep  = :everything
    def init(paKinds, poApp)
        aKinds = paKinds  oApp = poApp
    def Label()
        return oApp._Join(aKinds, " + ")
    def HasKind(pKind)
        for i = 1 to len(aKinds)
            if aKinds[i] = pKind  return TRUE  ok
        next
        return FALSE
    def Save()
        if This.HasKind(:GraphDB)
            cG = Graph  if cG = ""  cG = ".stzapp/world.stzgraf"  ok
            oApp.Graph().SaveToStzGraf(cG)
        ok
        return This
    def Restore()
        return This
    def Reproject()
        return This
    def Ingest(pWhat)
        return This
    def Narrate()
        return "lives in " + This.Label()


# stzAppScreen -- the  Screen(:X) { ToUnderstand(:Y)  Shows([...]) }  builder (INTENT).
class stzAppScreen from stzObject
    cName = ""  oApp = NULL
    cIntent = "understand"  cSubject = ""  aShows = []  aActs = []
    def init(pcName, poApp)
        cName = pcName  oApp = poApp  aShows = []  aActs = []
    def ToDiscover(pcThing)    cIntent = "discover"    cSubject = pcThing  return This
    def ToUnderstand(pcThing)  cIntent = "understand"  cSubject = pcThing  return This
    def ToFocus(pcThing)       cIntent = "focus"       cSubject = pcThing  return This
    def ToSelect(pcThing)      cIntent = "select"      cSubject = pcThing  return This
    def ToAct(pcThing)         cIntent = "act"         cSubject = pcThing  return This
    def Shows(paParts)
        aShows = paParts  return This
    def Acts(pcAction, pcFlow)
        aActs + [ pcAction, pcFlow ]  return This
    def Narrate()
        cS = "" if len(aShows) > 0  cS = " shows " + oApp._Join(aShows, ", ")  ok
        return "screen " + cName + ": " + cIntent + " " + cSubject + cS


# stzAppRefinement -- the  Refine(:knob).Bounds(...)  builder (REFINEMENT / PolyCode).
class stzAppRefinement from stzObject
    cKnob = ""  oApp = NULL
    cMin = ""  cMax = ""  aOptions = []
    def init(pcKnob, poApp)
        cKnob = pcKnob  oApp = poApp  aOptions = []
    def Bounds(pLow, pHigh)
        cMin = "" + pLow  cMax = "" + pHigh  return This
    def Options(paOpts)
        aOptions = paOpts  return This
    def Knob()
        return cKnob
    def Narrate()
        if cMin != "" or cMax != ""
            return "refine " + cKnob + " bounds [" + cMin + ".." + cMax + "]"
        ok
        if len(aOptions) > 0
            return "refine " + cKnob + " options " + oApp._Join(aOptions, " | ")
        ok
        return "refine " + cKnob
