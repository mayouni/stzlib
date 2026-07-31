load "../../stzBase.ring"

? "== block 1 =="
oSet = StzDefaultDetectionSet()
oSet.Show()

? "== block 2 =="
# a real run: the seams fill the ledger, nobody scripts anything
StzOpenSecurityLedger(512)
oLed = StzSecurityLedgerQ()

oAuth = new stzAuth()
oAuth.Register("victim", "correct-horse")
for i = 1 to 5
	oAuth.Login("victim", "guess-" + i)
next

oStore = new stzSecretStore("project")
oSec = new stzSecret("stripe-live")
oSec.FromLiteralQ("sk_live_NEVER_SEEN")
oStore.Register(oSec)
try
	oStore.Reveal("stripe-live", LLMActor("victim"))
catch
done

? "the ledger holds " + oLed.Count() + " event(s)"

? "== block 3 =="
aFindings = oSet.CheckAgainst(oLed)
for i = 1 to len(aFindings)
	? "  [" + aFindings[i][:severity] + "] " + aFindings[i][:where] + " -- " + aFindings[i][:message]
next

? "== block 4 =="
oRep = new stzRuleReport("nightly-ci")
oRep.Ingest(aFindings)
? "IsSound() = " + oRep.IsSound()
? oRep.Explain()[1]

StzCloseSecurityLedger()
