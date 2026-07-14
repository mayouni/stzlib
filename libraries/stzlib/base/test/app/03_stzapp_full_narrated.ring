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
    Thing(:Account) { Has([ :number, :chapter, :balance ])  IsTrue(:balance, '@ >= 0') }
    Thing(:Client)  { Has([ :code, :name, :city ])  Owns(:Account) }
    Thing(:Visit)   { Of(:Client)  Has([ :agent, :date, :subject ]) }
    Knows(:Account, :belongsTo, :Client)

    # ─── LIFE · behavior ───
    When(:agent, :records, :Visit) { Require(:subject)  Then( Keep(:Visit) ) }
    Whenever(:Client).Unseen(90, :Days) { Propose(:Visit) }

    # ─── LIFE · purpose ───
    Want(:EveryClientSeenThisQuarter) {
        Means      = "every :Client Has(:visit) Since(:quarterStart)"
        Within     = :thisQuarter
        ReachedBy  = :planning
        Respecting = [ :AccountsAreViewOnly ]
    }

    # ─── BODY ───
    LivesIn([ :GraphDB, :Files ]) { Graph = ".stzapp/world.stzgraf"  Files = "./" }
}

# ─── MET FROM WITHOUT (emergents) ───
oApp.Screen(:ClientFile) {
    ToUnderstand(:Client)
    Shows([ :identity, :accounts, :visits ])
    Acts(:NewVisit, :RecordVisit)
}
oApp.Refine(:balance).Bounds(0, 1000000)
oApp.Reaches([ :mobile, :desktop, :web ])

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
#--> [SonibankVisits] is live -- 3 thing(s), 1 flow(s), 1 reaction(s), 1 goal(s)

pf()
