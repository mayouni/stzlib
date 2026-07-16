# Narrative
# --------
# stzApp — a living world of meaning.  SLICE D: BODY (embodiment).
# A world of pure meaning is ephemeral; a body is where it endures. Here the world
# declares WHERE it lives — a dual body: the graph as its living substance, files as
# its readable face — and remembers itself across runs. (Body = where it RESIDES;
# not to be confused with Reach = where it APPEARS.)
#
# See: base/app/stzApp.ring · doc/design/STZAPP_BODY_DESIGN.md

load "../../stzBase.ring"

pr()

oApp = new stzApp("SonibankVisits")
oApp {
    # ── BEING ──
    AddThing(:Client) { Has([ :code, :name, :city ]) }
    AddThing(:Visit)  { Of(:Client)  Has([ :agent, :date, :subject ]) }

    # ── BECOMING · behavior ──
    AddReaction(:Client).Unseen(90, :Days) { Propose(:Visit) }

    # ── BODY — where the world endures ──
    SetBody([ :GraphDB, :Files ]) {
        Graph = ".stzapp/world.stzgraf"     # the substance (system of record)
        Files = "./"                         # the readable face (things/, life/, ...)
        Keep  = :everything
    }
}

oApp.Explain()
#--> WORLD SonibankVisits   lives in: graphdb + files
#      BEING
#        client (code, name, city)
#        visit (agent, date, subject)
#      RELATIONS
#        visit of client
#      BECOMING
#        whenever client unseen 90 days -> propose visit

# Persist the world's substance (native .stzgraf + .stzrulz) and reproject files.
oApp.Save()
#    → oApp.Graph().SaveToStzGraf(".stzapp/world.stzgraf")
#    → oApp.Graph().SaveToStzRulz(".stzapp/truths.stzrulz")
#    → reproject the readable file-face

? oApp.BodyQ().Label()
#--> graphdb + files

# A world with NO declared body still lives — in memory — it just won't endure:
oScratch = new stzApp("Scratch")
oScratch { AddThing(:Note) { Has([ :text ]) } }
oScratch.Explain()
#--> WORLD Scratch   lives in: memory (not persisted)
#      BEING
#        note (text)

pf()
