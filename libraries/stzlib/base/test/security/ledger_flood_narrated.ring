load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-LEDGERFLOOD-01 -- a stranger cannot flush the evidence.
#
# A refusal is written by whoever is REFUSED, and since payments PY3 some of
# them are strangers: anyone who can reach a webhook callback makes the
# signer refuse, one ledger line each. Measured 2026-10-05, before this fix:
# 1,100 forged webhooks took 1.7 s and pushed every earlier event out of the
# 1,024-entry window. The engine now gives each REFUSED kind a budget of
# lines per window; past it, refusals are counted, a marker says so, and a
# summary line carries the count into the chain. Grants are never budgeted.

$cSecret = "a-webhook-secret-of-some-length"

Scenario("a flood of forged webhooks no longer evicts other evidence")
	oLed = StzOpenSecurityLedger(1024)
	StzNoteRefusal("secret.reveal.refused", "intruder", "secret:db", "the real evidence")
	Forge(1100)
	Then("the earlier refusal is still in the window", CountOf(oLed, "secret.reveal.refused", ""), 1)
	Then("the chain is intact", oLed.Verify()[:intact], 1)
	StzCloseSecurityLedger()
EndScenario()

Scenario("nothing is lost silently: a marker, a count and a summary")
	oLed = StzOpenSecurityLedger(1024)
	Forge(1100)
	Then("64 forged refusals are written one by one", CountOf(oLed, "webhook.signature.forged", "hub"), 64)
	Then("the ledger marks that the budget was reached", HasReason(oLed, "budget reached"), 1)
	Then("the rest are counted", oLed.Suppressed(), 1036)
	oLed.FlushRefusalCounts()
	Then("a flush writes the count into the chain", HasReason(oLed, "1036 further refusal(s)"), 1)
	Then("...and the chain is still intact", oLed.Verify()[:intact], 1)
	StzCloseSecurityLedger()
EndScenario()

Scenario("the window rolls and recording resumes")
	oLed = StzOpenSecurityLedger(1024)
	oLed.SetRefusalBudget(3, 50)
	Then("the budget reads back", "" + oLed.RefusalBudget()[:max] + "/" + oLed.RefusalBudget()[:windowMs], "3/50")
	Forge(10)
	StzEngineTimeSleepMs(80)
	Forge(1)
	Then("the next window's first refusal closes the last one with its count", HasReason(oLed, "7 further refusal(s)"), 1)
	Then("...and is itself written", CountOf(oLed, "webhook.signature.forged", "hub"), 4)
	StzCloseSecurityLedger()
EndScenario()

Scenario("detection still sees an attack that spends the budget")
	oLed = StzOpenSecurityLedger(1024)
	oAuth = new stzAuth()
	oAuth.Register("dana@corp.com", "a-long-password")
	for i = 1 to 120  oAuth.Login("dana@corp.com", "wrong-" + i)  next
	oD = StzDetection("credential-stuffing")
	oD.WhenKind("auth.login.failed").PerActor().Repeats(5).Within(60000)
	Then("credential stuffing still fires", len(oD.CheckAgainst(oLed)) > 0, 1)
	StzCloseSecurityLedger()
EndScenario()

Scenario("grants are never budgeted; a zero budget writes everything (negative siblings)")
	oLed = StzOpenSecurityLedger(1024)
	for i = 1 to 200  StzNoteGrant("secret.reveal.granted", "ops", "secret:db")  next
	Then("200 grants, 200 lines", CountOf(oLed, "secret.reveal.granted", ""), 200)
	oLed.SetRefusalBudget(0, 60000)
	Forge(100)
	Then("budget off: 100 forged, 100 lines", CountOf(oLed, "webhook.signature.forged", ""), 100)
	Then("...and nothing counted", oLed.Suppressed(), 0)
	StzCloseSecurityLedger()
EndScenario()

Summary()

# -- helpers (after the main code) ------------------------------------

func Forge n
	oS = new stzRequestSigner("hub")
	oS.AddKey("k1", $cSecret)
	for i = 1 to n
		oS.VerifyWebhook('{"x":' + i + '}', "deadbeef", 1000 + i, 60000)
	next

# entries of a kind, optionally by one actor
func CountOf oLed, cKind, cActor
	aAll = oLed.All()
	n = 0
	for i = 1 to len(aAll)
		if aAll[i][:kind] = cKind and (cActor = "" or aAll[i][:actor] = cActor)  n++  ok
	next
	return n

func HasReason oLed, cText
	aAll = oLed.All()
	for i = 1 to len(aAll)
		if StzFindFirst(cText, aAll[i][:reason]) > 0  return 1  ok
	next
	return 0
