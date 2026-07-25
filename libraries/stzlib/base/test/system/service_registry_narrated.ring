load "../../stzBase.ring"
load "../_narrated.ring"

# stzServiceRegistry -- phase 1 of the service-virtualization plane.
#
# The plane's promise: code the whole solution against fee-free SANDBOXES, then
# flip to the real services at deploy without touching application code. Three
# doubles already shipped (the mail port, the OIDC sandbox, the passkey sandbox)
# and proved the pattern. What was missing was the SPINE -- the one place a
# solution declares what it depends on.
#
# The registry is to SERVICES what stzSecretStore is to secrets. Application code
# asks for a service by NAME; the PHASE decides which implementation comes back.
# That indirection is the whole trick: the code is byte-identical in emulation and
# in production, which is the only thing that makes "we tested against the
# sandbox" mean anything.
#
# And because the external surface is now ENUMERABLE, it becomes GOVERNABLE.
# Questions that used to be archaeology are queries: what does this touch? is
# anything still bound to a fake? does every live service have a credential, and
# is it in the store rather than inline? Findings() answers them in the same shape
# stzSecurityPosture and the graph rules use, so one CI gate covers all three.

Scenario("declaring the dependency surface, before anything is bound")
	oReg = new stzServiceRegistry("restolean")
	oReg.DeclareMany([ :mail, :payments ])
	Then("the surface is enumerable", @@(oReg.DeclaredServices()), @@([ "mail", "payments" ]))
	Then("nothing is bound yet", oReg.NumberOfBound(), 0)
	Then("...so both are reported unbound", @@(oReg.UnboundServices()), @@([ "mail", "payments" ]))

	Then("a declared-but-unbound service is an ERROR finding", len(oReg.Findings()), 2)
	Then("...named", oReg.Findings()[1][:invariant], "unbound-service")
	Then("...and blocking", oReg.Findings()[1][:severity], :error)
	Then("so the registry is NOT sound", oReg.IsSound(), FALSE)
EndScenario()

Scenario("an unbound service RAISES -- it must never silently no-op")
	oReg = new stzServiceRegistry("restolean")
	oReg.Declare(:payments)
	bRaised = FALSE
	try
		oReg.Service(:payments)
	catch
		bRaised = TRUE
	done
	Then("asking for it raises", bRaised, TRUE)
	# a NULL would fail later, somewhere else, as a null-call with no hint of the
	# real cause -- the failure has to land where the mistake is.
EndScenario()

Scenario("the app asks by NAME, and never learns which implementation it got")
	oReg = new stzServiceRegistry("restolean")
	oReg.Bind(:mail, new stzMailSandbox())
	Then("binding implies the declaration", oReg.IsDeclared(:mail), TRUE)
	Then("...so nothing is outstanding", len(oReg.Findings()), 0)

	When("a double is bound, the registry asks the OBJECT what it is")
	Then("it is recognised as a sandbox", oReg.PostureOf(:mail), :sandbox)
	# via a duck-typed IsSandbox() -- a double declaring itself beats guessing from
	# a class name, and lets a third-party double opt in.

	When("the application uses the service")
	oMail = oReg.Service(:mail)
	oMail.Send("dana@corp.com", "hello", "a body")
	Then("the work happened", oMail.Count(), 1)
	# THE RING TRAP: `=` and list insertion both COPY an object, so the registry
	# handed out a copy. A stateful sandbox must therefore share its state across
	# copies -- a requirement of the PORT CONTRACT, which stzMailSandbox meets with
	# a handle table. Proof:
	Then("the ORIGINAL sees the work done through the copy", oReg.Service(:mail).Count(), 1)

	Then("a service name is one spelling, symbol or string",
	     oReg.Has(:mail) and oReg.Has("mail"), TRUE)
EndScenario()

Scenario("a sandbox in production is a VIOLATION -- the plane's whole point")
	oReg = new stzServiceRegistry("restolean")
	oReg.Bind(:mail, new stzMailSandbox())
	oReg.Bind(:payments, new stzMailSandbox())     # a stand-in double

	Then("the default phase is development", oReg.Phase(), "development")
	oReg.SetPhase(:emulated)
	Then("in emulation, sandboxes are expected and it is sound", oReg.IsSound(), TRUE)

	When("the phase becomes production with fakes still bound")
	oReg.SetPhase(:production)
	Then("it is NOT sound", oReg.IsSound(), FALSE)
	Then("...with one finding per fake", len(oReg.Findings()), 2)
	Then("...named for what is wrong", oReg.Findings()[1][:invariant], "sandbox-in-production")
	Then("...pointing at the service", oReg.Findings()[1][:where], "restolean/mail")
	Then("the 'what is not real yet' list is available directly",
	     @@(oReg.SandboxedServices()), @@([ "mail", "payments" ]))
	# "flip it to real before shipping" is now ENFORCED, not remembered.
EndScenario()

Scenario("going live: the credential must be IN THE STORE, not inline")
	oReg = new stzServiceRegistry("restolean")
	oReg.Bind(:mail, new stzMailSandbox())
	oReg.SetPhase(:production)

	oStore = new stzSecretStore("acme")
	oStore.Register( (new stzApiKey("smtp-key")).FromLiteralQ("sk-live-xxxx") )

	When("the sandbox is replaced by a real adapter, naming its store secret")
	oReg.BindLive(:mail, new stzString("smtp-adapter"), "smtp-key")
	Then("the posture flips", oReg.PostureOf(:mail), :live)
	Then("...the registry holds only the NAME, never the key", oReg.SecretNameOf(:mail), "smtp-key")
	Then("...no fakes remain", len(oReg.SandboxedServices()), 0)
	Then("...and checked against the store, it is sound", oReg.IsSoundVia(oStore), TRUE)

	When("a live adapter names a secret the store does not have")
	oReg.BindLive(:payments, new stzString("stripe-adapter"), "stripe-key")
	Then("that is an ERROR", oReg.IsSoundVia(oStore), FALSE)
	Then("...named", StzFindFirst("live-without-secret", @@(oReg.FindingsVia(oStore))) > 0, TRUE)
	Then("...though it passes when no store is offered to check against", oReg.IsSound(), TRUE)

	When("a live adapter names NO secret at all")
	oOther = new stzServiceRegistry("other")
	oOther.BindLive(:blob, new stzString("s3-adapter"), "")
	Then("it is a WARNING, not a blocker", oOther.Findings()[1][:severity], :warn)
	Then("...named", oOther.Findings()[1][:invariant], "inline-credential")
	Then("...so the registry stays sound", oOther.IsSound(), TRUE)
EndScenario()

Scenario("going live is a GOVERNED crossing, like every other commit in the library")
	oReg = new stzServiceRegistry("restolean")
	oStore = new stzSecretStore("acme")
	oStore.Register( (new stzApiKey("smtp-key")).FromLiteralQ("sk-live-xxxx") )
	oReg.BindLive(:mail, new stzString("smtp-adapter"), "smtp-key")
	oReg.SetPhase(:production)
	Then("the surface itself is sound", oReg.IsSoundVia(oStore), TRUE)

	oHuman = HumanActor("dana")
	oLlm = LLMActor("assistant")
	oGuard = GuardianActor("watcher")

	Then("an effectful, trusted actor may commit it", oReg.MayGoLive(oHuman, oStore), TRUE)
	Then("an LLM actor may NOT", oReg.MayGoLive(oLlm, oStore), FALSE)
	Then("...and it says why", StzFindFirst("not effectful", oReg.WhyNotLive(oLlm, oStore)) > 0, TRUE)
	Then("a non-effectful guardian may not either", oReg.MayGoLive(oGuard, oStore), FALSE)
	Then("no actor at all may not", oReg.MayGoLive(NULL, oStore), FALSE)
	# expression is free; admission is governed. An agent may compose and rehearse
	# the whole integration and still not be the one who makes it real.

	When("the surface is UNSOUND, even the right actor is refused")
	oReg.Bind(:payments, new stzMailSandbox())     # a fake, in production
	Then("it refuses", oReg.MayGoLive(oHuman, oStore), FALSE)
	Then("...naming the reason rather than the actor",
	     StzFindFirst("sandbox-in-production", oReg.WhyNotLive(oHuman, oStore)) > 0, TRUE)
EndScenario()

Scenario("the CI globals, in the shape the other gates already use")
	oReg = new stzServiceRegistry("restolean")
	oReg.Declare(:mail)
	Then("StzServicesAreSound reports the unbound dependency", StzServicesAreSound(oReg), FALSE)
	Then("StzCheckServices returns the findings", len(StzCheckServices(oReg)), 1)

	oReg.Bind(:mail, new stzMailSandbox())
	Then("...and both agree once it is bound", StzServicesAreSound(oReg), TRUE)
	Then("a finding carries the four fields the other gates use",
	     len(oReg.Findings()), 0)

	When("the real doubles already in the library are bound")
	oFull = new stzServiceRegistry("full")
	oFull.Bind(:mail, new stzMailSandbox())
	oFull.Bind(:identity, new stzOidcSandbox("https://idp.local", "app"))
	oFull.Bind(:authenticator, new stzPasskeySandbox("example.com"))
	Then("all three declare themselves sandboxes", len(oFull.SandboxedServices()), 3)
	Then("...so a production phase refuses all three", len(oFull.SetPhaseQ(:production).Findings()), 3)
EndScenario()

Summary()
