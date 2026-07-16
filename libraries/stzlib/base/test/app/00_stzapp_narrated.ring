# Narrative
# --------
# stzApp -- a living world of meaning.  SLICE A: BEING (Domain).  [VALIDATED / GREEN]
# A world's things, what is TRUE of them, and how they RELATE -- declared in the
# near-natural block idiom, then made visible. Runs under Ring today.
#
# Idiom note: AddThing() returns the app, so the block  AddThing(:X) { Has(...) Owns(:Y) }
# runs the app's own Has/Owns on a "current thing" cursor (Ring-correct; no sub-builder
# copy, no R31). Names display lowercased (stzGraph lowercases node ids); use string
# ids like "Account" instead of :Account if case must be preserved.
#
# See: base/app/stzApp.ring · doc/design/STZAPP_DESIGN.md

load "../../stzBase.ring"

pr()

oApp = new stzApp("SonibankVisits")
oApp {
    AddThing(:Account) { Has([ :number, :chapter, :balance ])  IsTrue(:balance, "@ >= 0") }
    AddThing(:Client)  { Has([ :code, :name, :city ])  Owns(:Account) }
    AddThing(:Visit)   { Of(:Client)  Has([ :agent, :date, :subject ]) }
    AddRelation(:Account, :belongsTo, :Client)
}

oApp.Explain()
#--> WORLD SonibankVisits   lives in: memory (not persisted)
#      BEING
#        account (number, chapter, balance)
#            true when balance @ >= 0
#        client (code, name, city)
#        visit (agent, date, subject)
#      RELATIONS
#        client owns account
#        visit of client
#        account belongsto client

? "nodes: " + oApp.GraphQ().NodesCount()      #--> nodes: 3

oApp.Live()   #--> [SonibankVisits] is live -- 3 thing(s), 0 flow(s), 0 reaction(s), 0 goal(s); 0 proposal(s)

pf()
