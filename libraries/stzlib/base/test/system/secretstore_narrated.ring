# stzSecretStore -- the central place a project governs its secrets.
#
# Secrets stop being scattered inline objects: they are REGISTERED once in one
# store, enumerable and self-redacting; every reveal goes through ONE governed
# door (the same effectful-actor gate a stzSecret enforces) and is AUDITED, so
# misuse is visible rather than silent. A deployment site then references a
# secret BY the store rather than holding an inline key.
#
# Ring traps avoided: no oR/nL locals; main before the first func; no inline
# new X().M(); StzFindFirst (scalar) not StzFind; try/catch/done for raises.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

oHuman = HumanActor("ops")       # effectful, trusted   -> may reveal
oLLM   = LLMActor("planner")     # inference-only        -> may NOT reveal

# a project's credential surface, registered ONCE in the store.
oStore = new stzSecretStore("restolean")
oKey = new stzDeployKey("deploy-key")
oKey.FromLiteralQ("ssh-ed25519-AAAAlive")
oStore.Register(oKey)
oApiKey = new stzApiKey("stripe")
oApiKey.FromEnvQ("STRIPE_KEY")
oStore.Register(oApiKey)
oDbPass = new stzPassword("db")
oDbPass.FromLiteralQ("hunter2")
oStore.Register(oDbPass)

? "-- Scene 1: the store CENTRALISES a project's secrets --"
chk("three secrets registered in one place", oStore.NumberOfSecrets() = 3)
chk("...the whole credential surface is enumerable by name", StzFindFirst("deploy-key", oStore.Names()) > 0 and StzFindFirst("stripe", oStore.Names()) > 0)
chk("...Has() answers for a known + an unknown secret", oStore.Has("stripe") and NOT oStore.Has("ghost"))

? ""
? "-- Scene 2: every secret is REDACTED in the store (no value ever shows) --"
chk("DescriptorOf() is the redacted descriptor, not the key", StzFindFirst("<secret 'stripe'", oStore.DescriptorOf("stripe")) > 0)
chk("...the stored value never appears in the descriptor", StzFindFirst("ssh-ed25519", oStore.DescriptorOf("deploy-key")) = 0)
chk("holding the secret object does not reveal it", isObject(oStore.Secret("deploy-key")) and StzFindFirst("ssh-ed25519", oStore.Secret("deploy-key").Descriptor()) = 0)

? ""
? "-- Scene 3: the reveal is GOVERNED and AUDITED -- ONE door --"
chk("an effectful actor reveals through the store", oStore.Reveal("deploy-key", oHuman) = "ssh-ed25519-AAAAlive")
bRefused = FALSE
try
	oStore.Reveal("deploy-key", oLLM)
catch
	bRefused = TRUE
done
chk("...an LLM actor is REFUSED (raises), no value leaks", bRefused)
bGhost = FALSE
try
	oStore.Reveal("ghost", oHuman)
catch
	bGhost = TRUE
done
chk("revealing an unknown secret raises (and is not logged as an access)", bGhost)
chk("the access log recorded BOTH real attempts (granted + refused)", oStore.NumberOfAccesses() = 2)
chk("...one was refused -- misuse is visible, not silent", oStore.RefusedAccesses() = 1)
aLog = oStore.AccessLog()
chk("...the log names the actor, the secret, and the outcome", aLog[1][2] = "ops" and aLog[1][3] = "deploy-key" and aLog[1][4] = "granted")
chk("...the refused entry is attributed to the LLM actor", aLog[2][2] = "planner" and aLog[2][4] = "refused")

? ""
? "-- Scene 4: rotation and revocation --"
oNewKey = new stzDeployKey("deploy-key")
oNewKey.FromLiteralQ("ssh-ed25519-ROTATED")
oStore.RotateQ(oNewKey)
chk("rotation replaces the value under the same name (count unchanged)", oStore.NumberOfSecrets() = 3)
chk("...the store now reveals the rotated key", oStore.Reveal("deploy-key", oHuman) = "ssh-ed25519-ROTATED")
oStore.Revoke("stripe")
chk("revoke removes a secret", NOT oStore.Has("stripe") and oStore.NumberOfSecrets() = 2)

? ""
? "-- Scene 5: a deployment site references a secret BY the store (one registry) --"
oSite = new stzDeploymentSite("prod-api")
oSite.SetKindQ(:Server)
oSite.SetAuthRefQ(oStore.Secret("deploy-key"))
chk("the site holds the store's secret, not an inline key", oSite.HasAuthSecret())
chk("...its config serialises the redacted descriptor", StzFindFirst("<secret 'deploy-key'", oSite.ConfigJson()) > 0)
chk("...the rotated key value is nowhere in the config", StzFindFirst("ssh-ed25519-ROTATED", oSite.ConfigJson()) = 0)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
