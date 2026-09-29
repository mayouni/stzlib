load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-ROTATE-01 -- threat-model risk R10: a second real responder, and
# plans that span more than one owner.
#
# The response catalogue named :RotateSecret, and nothing could perform it.
# stzSecretStore.RotateToFresh replaces a secret the store owns (a literal:
# a key it issues, a token it signs with) with 32 fresh random bytes, and
# REFUSES a secret that lives elsewhere (env, file, vault), naming where to
# rotate it. stzSecretStoreResponder performs :RotateSecret with it.
#
# A plan may now lock an account AND rotate a secret: stzResponderSet routes
# each verb to the responder that owns it, and a plan holding an action
# nobody owns is refused WHOLE before anything is committed.

$oHuman = HumanActor("oncall")
$oService = HumanActor("secrets-service")
$oLlm = LLMActor("assistant")

Scenario("a secret the store owns is rotated to a fresh value, for real")
	oStore = StzSecretStoreQ("billing")
	oStore.Register(StzApiKeyQ("signing-key").FromLiteralQ("old-signing-value"))
	oResp = StzSecretStoreResponder(oStore, $oService)
	oResp.RotateSecret("signing-key")
	cNew = oStore.Reveal("signing-key", $oHuman)
	Then("the CALLER's store holds a new value (a reference, not a copy)", cNew != "old-signing-value", 1)
	Then("the new value is 32 random bytes as hex", len(cNew), 64)
	Then("the secret kept its kind", oStore.Secret("signing-key").Kind(), "apikey")
	Then("the rotation is in the store's access log", CountOutcome(oStore, "rotated"), 1)
	oResp.RotateSecret("secret:signing-key")
	Then("an incident's 'secret:<name>' form is understood", oStore.Reveal("signing-key", $oHuman) != cNew, 1)
EndScenario()

Scenario("a secret that lives elsewhere is refused, and says where to rotate it")
	oStore = StzSecretStoreQ("billing")
	oStore.Register(StzApiKeyQ("stripe").FromEnvQ("STRIPE_KEY"))
	cMsg = ""
	try  oStore.RotateToFresh("stripe", $oService)  catch  cMsg = cCatchError  done
	Then("it raises", cMsg != "", 1)
	Then("naming the source to rotate it in", StzFindFirst("STRIPE_KEY", cMsg) > 0, 1)
	Then("and the secret still points where it did", oStore.Secret("stripe").SourceLocator(), "STRIPE_KEY")
EndScenario()

Scenario("an LLM service identity cannot rotate anything")
	oStore = StzSecretStoreQ("billing")
	oStore.Register(StzApiKeyQ("signing-key").FromLiteralQ("old"))
	bRaised = 0
	try  oStore.RotateToFresh("signing-key", $oLlm)  catch  bRaised = 1  done
	Then("refused", bRaised, 1)
	Then("the value is untouched", oStore.Reveal("signing-key", $oHuman), "old")
EndScenario()

Scenario("one plan locks an account AND rotates a secret, each by its owner")
	oAuth = new stzAuth()
	oAuth.Register("mallory", "pw")
	oStore = StzSecretStoreQ("billing")
	oStore.Register(StzApiKeyQ("stripe-webhook").FromLiteralQ("whsec_old"))
	oSet = StzResponderSet([ StzAuthResponder(oAuth), StzSecretStoreResponder(oStore, $oService) ])
	oPlan = StzResponsePlan("contain-billing")
	oPlan.Propose(:LockAccount, "mallory", "stolen credentials used against billing")
	oPlan.Propose(:RotateSecret, "stripe-webhook", "the webhook secret was read by the intruder")
	nDone = oPlan.ExecuteOn(oSet, $oHuman)
	Then("both actions were committed", nDone, 2)
	Then("the account is locked", oAuth.IsAccountLocked("mallory"), 1)
	Then("the secret is rotated", oStore.Reveal("stripe-webhook", $oHuman) != "whsec_old", 1)
EndScenario()

Scenario("a plan with an action NOBODY owns is refused whole, before anything happens")
	oAuth = new stzAuth()
	oAuth.Register("mallory", "pw")
	oStore = StzSecretStoreQ("billing")
	oStore.Register(StzApiKeyQ("k").FromLiteralQ("v"))
	oSet = StzResponderSet([ StzAuthResponder(oAuth), StzSecretStoreResponder(oStore, $oService) ])
	oPlan = StzResponsePlan("contain-too-much")
	oPlan.Propose(:LockAccount, "mallory", "x")
	oPlan.Propose(:ShedSource, "10.0.0.9", "x")
	nDone = oPlan.ExecuteOn(oSet, $oHuman)
	Then("nothing was committed", nDone, 0)
	Then("the account the plan would have locked is NOT locked", oAuth.IsAccountLocked("mallory"), 0)
	Then("every action is audited as refused", oPlan.RefusedCount(), 2)
EndScenario()

Scenario("an LLM can propose rotation and cannot commit it")
	oStore = StzSecretStoreQ("billing")
	oStore.Register(StzApiKeyQ("k").FromLiteralQ("v"))
	oPlan = StzResponsePlan("llm-proposal")
	oPlan.Propose(:RotateSecret, "k", "the model thinks it leaked")
	Then("nothing committed", oPlan.ExecuteOn(StzSecretStoreResponder(oStore, $oService), $oLlm), 0)
	Then("the value is untouched", oStore.Reveal("k", $oHuman), "v")
EndScenario()

Summary()

func CountOutcome oStore, cOutcome
	aL = oStore.AccessLog()
	nC = 0
	for i = 1 to len(aL)
		if aL[i][4] = cOutcome  nC++  ok
	next
	return nC
