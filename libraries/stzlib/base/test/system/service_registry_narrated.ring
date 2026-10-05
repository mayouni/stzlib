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

	Given("the same surface while the phase is still DEVELOPMENT")
	oReg.SetPhaseQ(:development)
	Then("the registry reports nothing yet, correctly", len(oReg.Findings()), 0)
	Then("but MayGoLive still refuses", oReg.MayGoLive(oHuman, oStore), FALSE)
	Then("...for the same reason",
	     StzFindFirst("sandbox-in-production", oReg.WhyNotLive(oHuman, oStore)) > 0, TRUE)
	Then("and asking did not change the phase", oReg.Phase(), "development")
	# "may I go LIVE?" IS the production question, so it is asked in the production
	# frame whatever the current phase -- otherwise it answered YES with a fake
	# bound, simply because the phase-dependent invariants had not fired yet. This
	# scenario used to set production first, so the honest answer and the
	# convenient one agreed and the gap stayed hidden.
	Then("FindingsForProduction is the same question, asked directly",
	     len(oReg.FindingsForProduction()), 1)
	Then("...and it also leaves the phase alone", oReg.Phase(), "development")
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

Scenario("a FOURTH posture: the genuine hub protocol over virtual money (conformance)")
	# The BCEAO's sandbox is neither a fake nor the real thing: it speaks the REAL protocol,
	# with real OAuth credentials, over VIRTUAL money and simulated participants. A conformance
	# run is exactly what a platform does BEFORE going live, so it is expected in development --
	# and it is exactly what must never be bound when the platform ships.
	oStore = new stzSecretStore("acme")
	oStore.Register( (new stzApiKey("pispi-sandbox-client")).FromLiteralQ(StzEngineCryptoRandomHex(8)) )
	oReg = new stzServiceRegistry("diko")
	oReg.BindConformance(:payments, new stzString("pispi-sandbox-adapter"), "pispi-sandbox-client")
	Then("the posture is its own word", oReg.PostureOf(:payments), :conformance)
	Then("...it is not a sandbox", oReg.IsSandboxed(:payments), FALSE)
	Then("...and it is listed apart", @@(oReg.ConformanceServices()), @@([ "payments" ]))
	Then("...a conformance binding says whose credential it uses", oReg.SecretNameOf(:payments), "pispi-sandbox-client")
	Then("in development it is expected: the surface is sound", oReg.IsSoundVia(oStore), TRUE)
	Then("...with nothing to report", len(oReg.FindingsVia(oStore)), 0)

	oReg.SetPhase(:production)
	Then("in production it is an ERROR", oReg.IsSoundVia(oStore), FALSE)
	aF = oReg.FindingsVia(oStore)
	Then("...named conformance-in-production", aF[1][:invariant], "conformance-in-production")
	Then("...an error, like sandbox-in-production", aF[1][:severity], :error)
	Then("...pointing at the service", aF[1][:where], "diko/payments")
	Then("...and saying why virtual money must not ship", StzFindFirst("virtual money", aF[1][:message]) > 0, TRUE)
	oHuman = HumanActor("dana")
	Then("so no actor may take it live", oReg.MayGoLive(oHuman, oStore), FALSE)
	Then("...and it says why", StzFindFirst("conformance-in-production", oReg.WhyNotLive(oHuman, oStore)) > 0, TRUE)

	oDev = new stzServiceRegistry("diko-dev")
	oDev.BindConformance(:payments, new stzString("pispi-sandbox-adapter"), "pispi-sandbox-client")
	Then("asked from development, going live is already refused", oDev.MayGoLive(oHuman, oStore), FALSE)
	Then("...and the phase is left alone", oDev.Phase(), "development")
	Then("FindingsForProduction names it without changing the phase", len(oDev.FindingsForProductionVia(oStore)), 1)

	When("an object declares itself a conformance adapter, no word from the caller")
	oSelf = new stzRegistryConformanceDouble()
	oReg2 = new stzServiceRegistry("self")
	oReg2.Bind(:payments, oSelf)
	Then("the registry reads the posture off the object", oReg2.PostureOf(:payments), :conformance)

	When("the Softanza twin is bound")
	oTwin = new stzServiceRegistry("twin")
	oTwin.Bind(:payments, StzPaymentsPortQ(StzPiSpiSandboxQ()))
	Then("a port over the twin is a SANDBOX", oTwin.PostureOf(:payments), :sandbox)
	aTw = oTwin.SetPhaseQ(:production).Findings()
	Then("...and production refuses it", aTw[1][:invariant], "sandbox-in-production")
EndScenario()

Scenario("a conformance adapter needs its credential too, and a descriptor with no value is not one")
	oReg = new stzServiceRegistry("diko")
	oStore = new stzSecretStore("acme")
	oReg.BindConformance(:payments, new stzString("pispi-sandbox-adapter"), "pispi-sandbox-client")
	Then("a credential the store does not hold is an ERROR even for conformance", oReg.IsSoundVia(oStore), FALSE)
	aF1 = oReg.FindingsVia(oStore)
	Then("...the same invariant as a live adapter", aF1[1][:invariant], "live-without-secret")

	oStore.Register( StzPispiSecretQ("sandbox", "client") )
	Then("a descriptor registered but never given a value does not count", oReg.IsSoundVia(oStore), FALSE)
	aF2 = oReg.FindingsVia(oStore)
	Then("...and the message says it has no value", StzFindFirst("no value", aF2[1][:message]) > 0, TRUE)

	oSet = StzPispiSecretQ("sandbox", "client")
	oSet.FromLiteral(StzEngineCryptoRandomHex(8))
	oStore.Register(oSet)
	Then("with a value it is sound", oReg.IsSoundVia(oStore), TRUE)
EndScenario()

Scenario("live-without-certificate: a live payment without its mTLS identity is refused BEFORE the first call")
	# The hub refuses a call that does not present a client certificate from the BCEAO's CA, and
	# the certificate expires. The registry refuses the BINDING, at IsSound(), exactly where
	# live-without-secret already refuses a missing API key: in any phase, from the store alone.
	nNow = StzEngineTimeNowMs() / 1000
	oStore = new stzSecretStore("acme")
	oClient = StzPispiSecretQ("bia", "client")
	oClient.FromLiteral(StzEngineCryptoRandomHex(8))
	oStore.Register(oClient)
	oReg = new stzServiceRegistry("diko")
	oReg.BindLive(:payments, new stzRegistryLiveNeedingCertificate(), "pispi-bia-client")

	Then("a live adapter that declares it needs a certificate, and the store has none: ERROR", oReg.IsSoundVia(oStore), FALSE)
	aF = oReg.FindingsVia(oStore)
	Then("...named live-without-certificate", aF[1][:invariant], "live-without-certificate")
	Then("...an error", aF[1][:severity], :error)
	Then("...naming the certificate it looked for", StzFindFirst("pispi-bia-mtls-cert", aF[1][:message]) > 0, TRUE)
	Then("...in a DEVELOPMENT phase too: the phase is not what decides", oReg.Phase(), "development")
	Then("...though no store offered means nothing to check against", oReg.IsSound(), TRUE)

	oStore.Register( StzPispiSecretQ("bia", "mtls-cert") )
	Then("a certificate descriptor with no value is not a certificate", oReg.IsSoundVia(oStore), FALSE)
	aF = oReg.FindingsVia(oStore)
	Then("...and says so", StzFindFirst("no value", aF[1][:message]) > 0, TRUE)

	oOld = StzPispiSecretQ("bia", "mtls-cert")
	oOld.FromLiteral("CERT-" + StzEngineCryptoRandomHex(4))
	oOld.SetExpiry(1000000000)
	oStore.Register(oOld)
	Then("a certificate past its date is an ERROR", oReg.IsSoundVia(oStore), FALSE)
	aF = oReg.FindingsVia(oStore)
	Then("...and says expired", StzFindFirst("expired", aF[1][:message]) > 0, TRUE)

	oGood = StzPispiSecretQ("bia", "mtls-cert")
	oGood.FromLiteral("CERT-" + StzEngineCryptoRandomHex(4))
	oGood.SetExpiry(nNow + 365 * 86400)
	oStore.Register(oGood)
	Then("a valid certificate makes it sound", oReg.IsSoundVia(oStore), TRUE)
	Then("...with nothing left to report", len(oReg.FindingsVia(oStore)), 0)

	oForever = StzPispiSecretQ("bia", "mtls-cert")
	oForever.FromLiteral("CERT-" + StzEngineCryptoRandomHex(4))
	oStore.Register(oForever)
	Then("a certificate that carries no expiry is accepted: the store cannot say it lapsed", oReg.IsSoundVia(oStore), TRUE)

	When("the adapter cannot declare it, the binding can")
	oReg2 = new stzServiceRegistry("diko2")
	oReg2.BindLiveWithCertificate(:payments, new stzString("some-adapter"), "pispi-bia-client", "pispi-other-mtls-cert")
	Then("the binding remembers the certificate's name", oReg2.CertificateNameOf(:payments), "pispi-other-mtls-cert")
	Then("...and refuses it absent", oReg2.IsSoundVia(oStore), FALSE)
	aF3 = oReg2.FindingsVia(oStore)
	Then("...naming that certificate", StzFindFirst("pispi-other-mtls-cert", aF3[1][:message]) > 0, TRUE)

	When("a live adapter needs no certificate")
	oReg3 = new stzServiceRegistry("diko3")
	oReg3.BindLive(:mail, new stzString("smtp-adapter"), "pispi-bia-client")
	Then("nothing about certificates is asked of it", oReg3.IsSoundVia(oStore), TRUE)

	aNames = StzSecurityInvariantNames()
	Then("both new invariants are documented ones",
	     StzFindFirst("conformance-in-production", @@(aNames)) > 0 and
	     StzFindFirst("live-without-certificate", @@(aNames)) > 0, TRUE)
EndScenario()

Summary()

# a double that declares itself a conformance adapter
class stzRegistryConformanceDouble
	def init()
		return
	def IsConformance()
		return 1

# a live adapter that says it needs an mTLS client certificate, and where it lives
class stzRegistryLiveNeedingCertificate
	def init()
		return
	def RequiresCertificate()
		return 1
	def CertificateSecretName()
		return "pispi-bia-mtls-cert"
