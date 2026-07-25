load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 7 of the service-virtualization plane, and the one that makes the other six
# matter: the registry stops being something you remember to check and becomes part
# of the delivery.
#
# Three joins, each answering a different question:
#
#   stzDelivery   -- WHAT WILL SHIPPING COST ME? Every external dependency, its
#     current binding and the credential production will demand, rehearsed BEFORE
#     anything is built. And at the door, Deploy(:Production) REFUSES a surface
#     that still resolves to a fake.
#   stzSecurityPosture -- IS THIS PROJECT SOUND? The same gate that refuses a
#     sandboxed actor holding 'effectful' now refuses a sandbox bound in
#     production. Shipping a fake payment gateway is a security fact, not just an
#     unfinished one.
#   stzServiceRuleSet -- WHICH PART OF MY SOLUTION DEPENDS ON A FAKE? The graph
#     question, which neither of the above can ask.
#
# THE INVARIANT IS IMPLEMENTED ONCE. The registry owns it; delivery and posture
# surface it. Two copies of a rule is how the copies drift apart.

Scenario("the external surface, rehearsed before anything is built")
	oReg = new stzServiceRegistry("shop")
	oReg.DeclareMany([ :payments, :database, :cache ])
	oReg.BindSandbox(:payments, new stzPaymentsSandbox())
	oReg.BindLocal(:database, StzSqliteDataSourceQ(CurrentDir() + "/_p7test.db"))
	oReg.BindLocal(:cache, StzMemoryBlobStoreQ())

	oDel = new stzDelivery("shop")
	oDel.AddBackend("api", "linux")
	oDel.AddApp("web", "browser")
	oDel.UseServicesQ(oReg)
	oDel.NeedsServiceInQ("api", [ :payments, :database ])
	oDel.NeedsServiceInQ("web", [ :cache ])

	Then("the delivery knows its external surface", oDel.NumberOfExternalDependencies(), 3)
	aD = oDel.ExternalDependencies()
	Then("each dependency names its posture", aD[1][:posture], "sandbox")
	Then("...and which parts depend on it", aD[1][:parts][1], "api")
	Then("a service two parts do not share is attributed to one", len(aD[3][:parts]), 1)
	Then("...the right one", aD[3][:parts][1], "web")
	# so "what does shipping require of me?" is answerable from the model alone,
	# before a byte is compiled.
EndScenario()

Scenario("the PRE-FLIGHT: ask the production question without declaring production")
	oReg = new stzServiceRegistry("shop")
	oReg.DeclareQ(:payments)
	oReg.BindSandbox(:payments, new stzPaymentsSandbox())
	oDel = new stzDelivery("shop")
	oDel.AddBackend("api", "linux")
	oDel.UseServicesQ(oReg)

	Then("the phase is still development", oReg.Phase(), "development")
	Then("...so the registry itself reports nothing", len(oReg.Findings()), 0)
	# correct for the registry: sandbox-in-production is about PRODUCTION.

	Then("but the delivery can still ask what shipping WOULD say",
	     oDel.ServicesAreProductionReady(), FALSE)
	Then("...naming the reason", StzFindFirst("sandbox-in-production", oDel.WhyServicesNotReady()) > 0, TRUE)
	Then("and the phase was RESTORED afterwards -- asking is not declaring",
	     oReg.Phase(), "development")
	# rehearse, then commit: the plane's own habit, applied to its own gate.
EndScenario()

Scenario("THE GATE: a production deploy refuses a surface that is still a fake")
	oReg = new stzServiceRegistry("shop")
	oReg.DeclareMany([ :payments, :cache ])
	oReg.BindSandbox(:payments, new stzPaymentsSandbox())
	oReg.BindLocal(:cache, StzMemoryBlobStoreQ())

	oDel = new stzDelivery("shop")
	oDel.AddBackend("api", "linux")
	oDel.UseServicesQ(oReg)
	oDel.NeedsServiceInQ("api", [ :payments, :cache ])
	oDel.DeployTo(StzDeploymentSiteQ("host1"), "api")

	When("a FULLY ENTITLED actor asks to deploy to production")
	oDel.SetActor( HumanActor("dana") )
	oDep = oDel.Deploy(:Production)

	Then("the deployment did not RUN AT ALL", oDep.WasRun(), FALSE)
	Then("...so nothing was committed", oDep.WasCommitted(), FALSE)
	# refused even though the actor may commit: this is not an authority question.
	# An entitled human deploying a fake payment gateway is still deploying a fake.

	aErr = oDel.Log().EntriesOfLevel(:error)
	Then("the refusal is logged", len(aErr) > 0, TRUE)
	Then("...as a refusal", StzFindFirst("REFUSED", aErr[1][:message]) > 0, TRUE)
	Then("...and every reason is named, not just the first", len(aErr), 3)
	Then("including the fake gateway", StzFindFirst("sandbox-in-production", aErr[2][:message]) > 0, TRUE)
	Then("...and the store that empties on restart",
	     StzFindFirst("ephemeral-in-production", aErr[3][:message]) > 0, TRUE)
	# "flip it to real before shipping" was a thing to remember. It is now a door.
EndScenario()

Scenario("...and it opens once the surface is real")
	oReg = new stzServiceRegistry("shop")
	oReg.DeclareMany([ :payments, :database ])
	oReg.BindLive(:payments, new stzHttpSandbox(), "stripe_key")
	oReg.BindLocal(:database, StzSqliteDataSourceQ(CurrentDir() + "/_p7test.db"))

	oDel = new stzDelivery("shop")
	oDel.AddBackend("api", "linux")
	oDel.UseServicesQ(oReg)
	oDel.NeedsServiceInQ("api", [ :payments, :database ])
	oDel.DeployTo(StzDeploymentSiteQ("host1"), "api")

	Then("the pre-flight now passes", oDel.ServicesAreProductionReady(), TRUE)
	Then("...with nothing to explain", oDel.WhyServicesNotReady(), "")
	# a live binding names its secret and a FILE-backed sqlite persists, so both
	# error invariants fall silent. Note what is NOT required: the secret's VALUE.
	# The registry holds the name; the store holds the secret.

	When("an actor that may NOT commit asks to deploy")
	oDel.SetActor( LLMActor("assistant") )
	oDep = oDel.Deploy(:Production)
	Then("the SERVICE gate passed this time -- no error was logged",
	     len(oDel.Log().EntriesOfLevel(:error)), 0)
	Then("...yet nothing was committed", oDep.WasCommitted(), FALSE)

	aW = oDel.Log().EntriesOfLevel(:warn)
	Then("...and the reason given is the ACTOR, not the services",
	     StzFindFirst("no effectful actor", aW[len(aW)][:message]) > 0, TRUE)
	# TWO INDEPENDENT GATES, and the log distinguishes them: refused for the
	# surface says "flip the sandboxes to real bindings first"; refused for the
	# actor says "no effectful actor". An LLM actor can drive the whole production
	# deploy and change nothing.
EndScenario()

Scenario("the registry is ONE registry, however many copies Ring makes")
	oReg = new stzServiceRegistry("shop")
	oReg.DeclareQ(:payments)
	oReg.BindLive(:payments, new stzHttpSandbox(), "stripe_key")

	oDel = new stzDelivery("shop")
	oDel.AddBackend("api", "linux")
	oDel.UseServicesQ(oReg)
	Then("the attached surface is sound", oDel.ServicesAreProductionReady(), TRUE)

	When("a FAKE is bound afterwards, on the caller's own handle")
	oReg.BindSandbox(:payments, new stzPaymentsSandbox())
	Then("the delivery SEES it", oDel.ServicesAreProductionReady(), FALSE)
	Then("...through its own accessor too", oDel.ServicesQ().PostureOf(:payments), :sandbox)
	# This is the reason stzServiceRegistry keeps its state in a table keyed by id
	# rather than in attributes. `=` and attribute-stores COPY in Ring, so the
	# delivery used to hold a SNAPSHOT: a fake bound after attaching stayed
	# invisible and the gate would have PASSED an unsound surface. A gate that
	# fails OPEN is worse than no gate at all. Every copy is now the registry --
	# the same cure the plane's sandboxes already used, finally applied to the
	# thing that judges them.

	When("the change is made through the delivery instead")
	oDel.ServicesQ().BindLiveQ(:payments, new stzHttpSandbox(), "stripe_key")
	Then("the caller's own handle sees THAT", oReg.PostureOf(:payments), :live)
	Then("...and the gate opens again", oDel.ServicesAreProductionReady(), TRUE)
EndScenario()

Scenario("the plan reads the outside world alongside the capabilities")
	oReg = new stzServiceRegistry("shop")
	oReg.DeclareMany([ :payments, :cache ])
	oReg.BindSandbox(:payments, new stzPaymentsSandbox())
	oReg.BindLive(:cache, new stzHttpSandbox(), "redis_url")

	oDel = new stzDelivery("shop")
	oDel.AddBackend("api", "linux")
	oDel.NeedsIn("api", [ :PivotTable ])
	oDel.UseServicesQ(oReg)
	oDel.NeedsServiceInQ("api", [ :payments, :cache ])

	oPlan = oDel.Plan()
	Then("the plan carries the surface", oPlan.NumberOfExternalDependencies(), 2)
	Then("it lists what is still a fake", oPlan.SandboxedDependencies()[1], "payments")
	Then("...and the credentials production will require, BY NAME",
	     oPlan.ProductionCredentials()[1], "redis_url")
	# names, never values -- the plan is a document you can read aloud.

	aL = oPlan.Explain()
	bFound = FALSE
	bWarn = FALSE
	nLen = len(aL)
	for i = 1 to nLen
		if StzFindFirst("External dependencies", aL[i]) > 0  bFound = TRUE ok
		if StzFindFirst("will REFUSE until these are real", aL[i]) > 0  bWarn = TRUE ok
	next
	Then("Explain() shows the dependency section", bFound, TRUE)
	Then("...and says plainly what will happen at the door", bWarn, TRUE)
EndScenario()

Scenario("the GRAPH question: which PART of my solution depends on a fake?")
	oReg = new stzServiceRegistry("shop")
	oReg.DeclareMany([ :payments, :cache ])
	oReg.BindSandbox(:payments, new stzPaymentsSandbox())
	oReg.BindLocal(:cache, StzMemoryBlobStoreQ())

	oDel = new stzDelivery("shop")
	oDel.AddBackend("api", "linux")
	oDel.AddApp("web", "browser")
	oDel.UseServicesQ(oReg)
	oDel.NeedsServiceInQ("api", [ :payments, :cache ])
	oDel.NeedsServiceInQ("web", [ :reporting ])
	oDel.DeployTo(StzDeploymentSiteQ("host1"), "api")   # api is destined for a real host

	oG = oDel.AsRuleGraph()
	Then("parts and services live in ONE graph", len(oG.NodesIds()) > 4, TRUE)
	Then("a part bound to a site is marked for production",
	     oG.NodeProperty("part:api", "destination"), "production")
	Then("...and one that is not, is not", oG.NodeProperty("part:web", "destination"), "unbound")

	Then("the phase is STILL development", oReg.Phase(), "development")
	Then("...so the registry reports nothing at all", len(oReg.Findings()), 0)

	aF = StzCheckServiceDelivery(oDel)
	Then("but the rules answer anyway", len(aF), 3)
	Then("naming the PART, not the service", aF[1][:where], "api")
	Then("...for depending on a double", aF[1][:rule], "production-part-uses-sandbox")
	Then("...and for depending on an ephemeral store", aF[2][:rule], "production-part-uses-ephemeral")
	# THE TIMING IS THE POINT. The registry can only answer once you have declared
	# production. These rules read the part's DESTINATION, so they answer while
	# there is still time: "if I shipped this today, would it be fake?"

	Then("a WARNING covers a need the registry never heard of", aF[3][:rule], "part-uses-undeclared-service")
	Then("...on the part that declared it", aF[3][:where], "web")
	Then("...and it is advisory, not blocking", aF[3][:severity], "warning")
	# invisible to the registry: that dependency exists only in the delivery model.
	# 'web' is not destined for a site yet, which is why this one is a warning.
EndScenario()

Scenario("ONE CI gate: the outside world joins the other domains")
	oReg = new stzServiceRegistry("shop")
	oReg.DeclareMany([ :payments, :cache ])
	oReg.BindSandbox(:payments, new stzPaymentsSandbox())
	oReg.BindLocal(:cache, StzMemoryBlobStoreQ())
	oReg.SetPhaseQ(:production)

	oRep = new stzRuleReport("ci")
	oRep.IngestLegacy(oReg.Findings(), "services")
	Then("the registry's findings need no adapter at all", oRep.NumberOfFindings(), 2)
	Then("...normalised to the report's vocabulary", oRep.Findings()[1][:rule], "sandbox-in-production")
	Then("...under their own subject", oRep.Findings()[1][:subject], "services")
	Then("and the gate closes", oRep.IsSound(), FALSE)
	# they were already shaped [ :invariant, :severity, :where, :message ] -- the
	# same shape stzSecurityPosture and the graph rules use. That agreement, made
	# in phase 1, is why this join is one line.

	When("the security posture is asked about the same project")
	oP = new stzSecurityPosture("shop")
	oP.SetServices(oReg)
	Then("it surfaces the service findings too", oP.NumberOfFindings(), 2)
	Then("...including the headline invariant", oP.Findings()[1][:invariant], "sandbox-in-production")
	Then("...so the security verdict is UNSOUND", oP.IsSound(), FALSE)
	Then("and the invariant is a documented one", StzFindFirst("sandbox-in-production",
	     StzSecurityInvariantNames()) > 0, TRUE)
	# DELEGATED, not re-implemented: the posture asks the registry. One
	# implementation, surfaced in three places -- the deploy door, the security
	# audit, and the CI report.

	When("a posture with no service surface is asked")
	oP2 = new stzSecurityPosture("bare")
	Then("it simply has nothing to say about services", oP2.NumberOfFindings(), 0)
EndScenario()

if fexists(CurrentDir() + "/_p7test.db")  remove(CurrentDir() + "/_p7test.db") ok

Summary()
