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
    Thing(:Client) { Has([ :code, :name, :city ]) }
    Thing(:Visit)  { Of(:Client)  Has([ :agent, :date, :subject ]) }

    # ── BECOMING · behavior ──
    When(:agent, :records, :Visit) { Require(:subject)  Then( Keep(:Visit) ) }
    Whenever(:Client).Unseen(90, :Days) { Propose(:Visit) }

    # ── BECOMING · purpose — what the world WANTS ──
    Want(:EveryClientSeenThisQuarter) {
        Means      = "every :Client Has(:visit) Since(:quarterStart)"   # the wanted state
        Within     = :thisQuarter
        ReachedBy  = :planning                                          # PI-first
        Respecting = [ :AccountsAreViewOnly ]                            # a truth the plan must keep
    }
}

oApp.Explain()
#--> WORLD SonibankVisits
#      BEING
#        Client (code, name, city)
#        Visit (agent, date, subject)
#      RELATIONS
#        Visit of Client
#      BECOMING
#        when agent records Visit require subject then keep Visit
#        whenever Client unseen 90 Days -> propose Visit
#        wants EveryClientSeenThisQuarter within thisQuarter -> reached by planning

# The goal is a declared wanted STATE (not a script):
? oApp.Goal(:EveryClientSeenThisQuarter).Means
#--> every :Client Has(:visit) Since(:quarterStart)

# Pursue it — the engine finds the way (PI-first). Proposals re-enter behavior.
oApp.Pursue(:EveryClientSeenThisQuarter)
#--> pursuing EveryClientSeenThisQuarter via planning — 0 proposal(s)
#    (0 here: only the schema is declared; Satisfied()/Gap() evaluate on live instance data)

pf()
