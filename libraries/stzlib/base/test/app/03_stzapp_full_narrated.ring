# Narrative
# --------
# stzApp — a living world of meaning.  THE FULL CONSTRUCT (Slices A–E).
# One world declared end to end: its BEING (domain), its LIFE (behavior + purpose),
# its BODY (where it endures) — and how it is MET FROM WITHOUT (intent, refinement,
# reach). Three constitutive aspects; four emergents.
#
# See: base/app/stzApp.ring · doc/design/STZAPP_DESIGN.md

load "../../stzBase.ring"

pr()

oApp = new stzApp("SonibankVisits")
oApp {
    # ─── BEING (Domain) ───
    AddThingQ(:Account) { Has([ :number, :chapter, :balance ])  IsTrue(:balance, '@ >= 0') }
    AddThingQ(:Client)  { Has([ :code, :name, :city ])  Owns(:Account) }
    AddThingQ(:Visit)   { Of(:Client)  Has([ :agent, :date, :subject ]) }
    AddRelation(:Account, :belongsTo, :Client)

    # ─── LIFE · behavior ───
    AddFlowQ(:agent, :records, :Visit) { Require(:subject)  Then( Keep(:Visit) ) }
    AddReactionQ(:Client).Unseen(90, :Days) { Propose(:Visit) }

    # ─── LIFE · purpose ───
    AddGoalQ(:EveryClientSeenThisQuarter) {
        Means      = "every :Client Has(:visit) Since(:quarterStart)"
        Within     = :thisQuarter
        ReachedBy  = :planning
        Respecting = [ :AccountsAreViewOnly ]
    }

    # ─── BODY ───
    SetBody([ :GraphDB, :Files ]) { Graph = ".stzapp/world.stzgraf"  Files = "./" }
}

# ─── MET FROM WITHOUT (emergents) ───
oApp.AddScreenQ(:ClientFile) {
    ToUnderstand(:Client)
    Shows([ :identity, :accounts, :visits ])
    Acts(:NewVisit, :RecordVisit)
}
oApp.AddRefinementQ(:balance).Bounds(0, 1000000)
oApp.AddReaches([ :mobile, :desktop, :web ])

oApp.Explain()
#--> WORLD SonibankVisits   lives in: graphdb + files
#      BEING
#        account (number, chapter, balance)
#            true when balance @ >= 0
#        client (code, name, city)
#        visit (agent, date, subject)
#      RELATIONS
#        client owns account
#        visit of client
#        account belongsto client
#      BECOMING
#        when agent records visit require subject then keep visit
#        whenever client unseen 90 days -> propose visit
#        wants everyclientseenthisquarter within thisquarter -> reached by planning
#      MET FROM WITHOUT
#        screen clientfile: understand client shows identity, accounts, visits
#        refine balance bounds [0..1000000]
#        reaches mobile, desktop, web

oApp.Live()
#--> [SonibankVisits] is live -- 3 thing(s), 1 flow(s), 1 reaction(s), 1 goal(s); 0 proposal(s)

pf()
