# Narrative
# --------
# stzApp — a living world of meaning.  SLICE C: Life · PURPOSE.
# A world that only reacts is a mechanism; a world that WANTS is alive with meaning.
# Here the world is given a goal (a wanted state) and a plan that climbs the PI ladder
# to reach it — the goal declared, the plan found by the engine.
#
# See: base/app/stzApp.ring · doc/design/STZAPP_PURPOSE_DESIGN.md

load "../../stzBase.ring"

pr()

oApp = new stzApp("SonibankVisits")
oApp {
    # ── BEING ──
    AddThing(:Client) { Has([ :code, :name, :city ]) }
    AddThing(:Visit)  { Of(:Client)  Has([ :agent, :date, :subject ]) }

    # ── BECOMING · behavior ──
    AddFlow(:agent, :records, :Visit) { Require(:subject)  Then( Keep(:Visit) ) }
    AddReaction(:Client).Unseen(90, :Days) { Propose(:Visit) }

    # ── BECOMING · purpose — what the world WANTS ──
    AddGoal(:EveryClientSeenThisQuarter) {
        Means      = "every :Client Has(:visit) Since(:quarterStart)"   # the wanted state
        Within     = :thisQuarter
        ReachedBy  = :planning                                          # PI-first
        Respecting = [ :AccountsAreViewOnly ]                            # a truth the plan must keep
    }
}

oApp.Explain()
#--> WORLD SonibankVisits
#      BEING
#        client (code, name, city)
#        visit (agent, date, subject)
#      RELATIONS
#        visit of client
#      BECOMING
#        when agent records visit require subject then keep visit
#        whenever client unseen 90 days -> propose visit
#        wants everyclientseenthisquarter within thisquarter -> reached by planning

# The goal is a declared wanted STATE (not a script):
? oApp.GoalQ(:EveryClientSeenThisQuarter).Means
#--> every :Client Has(:visit) Since(:quarterStart)

# Pursue it — the engine finds the way (PI-first). Proposals re-enter behavior.
oApp.Pursue(:EveryClientSeenThisQuarter)
#--> pursuing everyclientseenthisquarter via planning -- 0 proposal(s)
#    (0 here: only the schema is declared; Satisfied()/Gap() evaluate on live instance data)

pf()
