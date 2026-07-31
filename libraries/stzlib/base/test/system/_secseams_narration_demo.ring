load "../../stzBase.ring"

? "== block 1 =="
StzOpenSecurityLedger(512)
oLed = StzSecurityLedgerQ()

# an attacker probing the signed-request gateway
oSigner = new stzRequestSigner("gateway")
oSigner.AddKey("billing", "shared-secret")
nNow = StzEngineTimeNowMs()
oSigner.Verify("ghost", "GET", "/pay", "", nNow, "n1", "deadbeef", 30000, nNow)
oSigner.Verify("billing", "GET", "/pay", "", nNow, "n2", "0000forged0000", 30000, nNow)
aGood = oSigner.Sign("billing", "GET", "/pay", "", nNow, "n3")
oSigner.Verify("billing", "GET", "/pay", "", nNow, "n3", aGood[:sig], 30000, nNow)
oSigner.Verify("billing", "GET", "/pay", "", nNow, "n3", aGood[:sig], 30000, nNow)

# ...meanwhile, someone guesses at the login door
oAuth = new stzAuth()
oAuth.Register("admin", "correct-horse")
for i = 1 to 3
	oAuth.Login("admin", "wrong-guess")
next

# ...and a sandboxed agent reaches for a production secret
oStore = new stzSecretStore("project")
oSec = new stzSecret("stripe-live")
oSec.FromLiteralQ("sk_live_NEVER_IN_AN_EVENT")
oStore.Register(oSec)
try
	oStore.Reveal("stripe-live", LLMActor("advisor"))
catch
done

oLed.Show()

? "== block 2 =="
? "refusals        : " + len(oLed.Refusals())
? "about that key  : " + len(oLed.OfActor("billing"))
? "chain           : " + oLed.Verify()[:message]
? "secret value leaked anywhere? " + (StzFindFirst("sk_live", oLed.Explain()[1]) > 0)

StzCloseSecurityLedger()
