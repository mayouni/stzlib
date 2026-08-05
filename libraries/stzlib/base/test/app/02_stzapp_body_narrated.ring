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
load "../_narrated.ring"

pr()

oApp = new stzApp("SonibankVisits")
oApp {
    # ── BEING ──
    AddThingQ(:Client) { Has([ :code, :name, :city ]) }
    AddThingQ(:Visit)  { Of(:Client)  Has([ :agent, :date, :subject ]) }

    # ── BECOMING · behavior ──
    AddReactionQ(:Client).Unseen(90, :Days) { Propose(:Visit) }

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
oScratch { AddThingQ(:Note) { Has([ :text ]) } }
oScratch.Explain()
#--> WORLD Scratch   lives in: memory (not persisted)
#      BEING
#        note (text)


Scenario("Everything the body's brace collects comes back out of it")

	# -- WHY THIS SCENE EXISTS --
	#
	# SetBody's brace collects THREE things -- Graph, Files and Keep -- and this
	# example above sets all three. Keep was gathered into the body and then
	# surfaced by nothing: not by Body(), not by BodyQ(), and stzAppBody had no
	# field for it. A world could say "Keep = :everything" and had no way to be
	# asked what it keeps.
	#
	# It survived because this file demonstrated the DSL and asserted none of it.

	Given("a world whose body declares all three")
	oB = new stzApp("BodyProbe")
	oB {
		AddThingQ(:Note) { Has([ :text ]) }
		SetBody([ :GraphDB, :Files ]) {
			Graph = ".stzapp/probe.stzgraf"
			Files = "./face/"
			Keep  = :everything
		}
	}

	When("the body is read back as data")
	aBody = oB.Body()

	Then("the graph path is there", aBody[:graph], ".stzapp/probe.stzgraf")
	Then("...the files path is there", aBody[:files], "./face/")
	Then("...and so is what it keeps", aBody[:keep], "everything")

	When("...and as the value object")
	oBody = oB.BodyQ()
	Then("the object carries the graph", oBody.Graph, ".stzapp/probe.stzgraf")
	Then("...the files", oBody.Files, "./face/")
	Then("...and the keep policy", oBody.Keep, "everything")
	Then("...and still labels its kinds", oBody.Label(), "graphdb + files")

	# THE NEGATIVE SIBLING. Every check above would also pass if the body simply
	# echoed whatever the brace last saw; these say the fields are per-world and
	# that an undeclared one stays empty rather than inheriting a neighbour's.
	Given("a second world that declares only where its graph lives")
	oC = new stzApp("Sparse")
	oC {
		AddThingQ(:Note) { Has([ :text ]) }
		SetBody(:GraphDB) {
			Graph = ".stzapp/other.stzgraf"
		}
	}
	aSparse = oC.Body()
	Then("its graph is its own", aSparse[:graph], ".stzapp/other.stzgraf")
	Then("...its files are empty, not the other world's", aSparse[:files], "")
	Then("...and so is its keep", aSparse[:keep], "")

	# A world with no body at all has nothing to report -- the third state, and
	# the one Explain() calls "memory (not persisted)".
	Given("a world with no body")
	oD = new stzApp("Scratchy")
	oD { AddThingQ(:Note) { Has([ :text ]) } }
	Then("its body is empty", len(oD.Body()), 0)
	Then("...and its body object is NULL", isObject(oD.BodyQ()), FALSE)
EndScenario()

Summary()

pf()
