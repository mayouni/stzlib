# stzSecret + stzAuth -- Softanza's confidential-data + credential story.
#
# A secret is a value you HOLD but never REVEAL in the clear: it redacts itself
# in every output, resolves its value lazily from a source (literal/env/file),
# and reveals the plaintext ONLY to an effectful, non-sandboxed actor. Same rule
# as the deployment crossing: an LLMActor can REFERENCE a secret in a plan it
# rehearses, but can NEVER reveal it (expression free, admission governed).
#
# stzAuth is the stzApp-domain counterpart: it authenticates PEOPLE (salted
# password hashes + opaque sessions), never storing a plaintext password.
#
# Ring traps avoided: no oR/nL locals; main before the first func; no inline
# new X().M(); env object split from its SetVar call; try/catch/done for raises.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

oHuman = HumanActor("ops")     # effectful, trusted   -> may reveal
oLLM   = LLMActor("planner")   # inference-only, sandboxed -> may NOT reveal

? "-- Scene 1: a secret REDACTS itself -- the value never appears in output --"
oLit = new stzSecret("api")
oLit.FromLiteralQ("VERYSECRET")
chk("Descriptor() never carries the value", StzFindFirst("VERYSECRET", oLit.Descriptor()) = 0)
chk("...a :literal source reads 'from literal', not the value", StzFindFirst("from literal", oLit.Descriptor()) > 0)
chk("...its SourceLocator() is the safe '(inline)' marker, never the value", oLit.SourceLocator() = "(inline)")
chk("...it names the secret + its kind, safely", StzFindFirst("'api'", oLit.Descriptor()) > 0 and StzFindFirst("(secret)", oLit.Descriptor()) > 0)
chk("Masked() is a fixed ASCII mask (no glyphs)", oLit.Masked() = "********")
oEnvSec = new stzSecret("deploy-key")
oEnvSec.FromEnvQ("DEPLOY_KEY")
chk("an :env secret shows its SOURCE POINTER (var name), never a value", StzFindFirst("env:DEPLOY_KEY", oEnvSec.Descriptor()) > 0)
chk("SourceLocator() is the safe pointer (the env var name)", oEnvSec.SourceLocator() = "DEPLOY_KEY")

? ""
? "-- Scene 2: the reveal is GOVERNED -- effectful actor yes, LLM refused --"
chk("a secret is revealable by an effectful, trusted actor", oLit.IsRevealableBy(oHuman))
chk("...NOT by an inference-only, sandboxed LLM actor", NOT oLit.IsRevealableBy(oLLM))
chk("HumanActor reveals the plaintext", oLit.Reveal(oHuman) = "VERYSECRET")
bRefused = FALSE
try
	oLit.Reveal(oLLM)
catch
	bRefused = TRUE
done
chk("LLMActor is REFUSED -- Reveal() raises, no plaintext leaks", bRefused)

? ""
? "-- Scene 3: sources -- literal (dev), env, and file all resolve --"
oEnv = StzEnvironmentQ()
oEnv.SetVar("DEPLOY_KEY", "ssh-ed25519-AAAAlive")
chk("an :env secret resolves the live variable (for an effectful actor)", oEnvSec.Reveal(oHuman) = "ssh-ed25519-AAAAlive")
cScratch = WorkingDirectory() + "/_secret_scratch"
StzEngineDirCreatePath(cScratch)
write(cScratch + "/key.pem", "FILE-BACKED-KEY")
oFileSec = new stzSecret("pem")
oFileSec.FromFileQ(cScratch + "/key.pem")
chk("a :file secret resolves the file's contents (trimmed)", oFileSec.Reveal(oHuman) = "FILE-BACKED-KEY")
chk("IsResolvableBy() is governed too (human yes)", oFileSec.IsResolvableBy(oHuman))
chk("...and false for an LLM (never resolves for it)", NOT oFileSec.IsResolvableBy(oLLM))

? ""
? "-- Scene 4: specialisations name the KIND and add one presentation each --"
oKey = new stzApiKey("stripe")
oKey.FromLiteralQ("sk_live_abc")
chk("stzApiKey carries kind 'apikey'", oKey.Kind() = "apikey")
chk("...it presents as a Bearer header (governed)", oKey.AuthorizationHeader(oHuman) = "Bearer sk_live_abc")
oPw = new stzPassword("db")
oPw.FromLiteralQ("hunter2")
chk("stzPassword matches the right candidate", oPw.Matches("hunter2", oHuman))
chk("...and rejects the wrong one", NOT oPw.Matches("nope", oHuman))
cHash = oPw.HashedBy(oHuman)
chk("...HashedBy() is a salted hash (salt:hash), never the plaintext", StzFindFirst(":", cHash) > 0 and StzFindFirst("hunter2", cHash) = 0)
chk("...and the hash verifies against the password", StzVerifySecret("hunter2", cHash))
oDep = new stzDeployKey("prod-deploy")
oDep.FromLiteralQ("-----BEGIN KEY-----")
chk("stzDeployKey carries kind 'deploykey'", oDep.Kind() = "deploykey")
chk("...KeyMaterial() is governed", oDep.KeyMaterial(oHuman) = "-----BEGIN KEY-----")
oTok = new stzToken("sess")
oTok.FromLiteralQ("t0k")
oTok.SetExpiryQ(1000)
chk("stzToken carries kind 'token'", oTok.Kind() = "token")
chk("...not expired before its expiry", NOT oTok.IsExpiredAt(500))
chk("...expired at/after its expiry", oTok.IsExpiredAt(1500))
oPerm = new stzToken("perm")
oPerm.FromLiteralQ("x")
chk("...a 0-expiry token never expires", NOT oPerm.IsExpiredAt(999999))

? ""
? "-- Scene 5: wired into a deployment site -- the key never lands in config --"
oSecret = new stzDeployKey("prod-deploy")
oSecret.FromEnvQ("DEPLOY_KEY")
oSite = new stzDeploymentSite("prod-api")
oSite.SetKindQ(:Server)
oSite.SetEndpointQ("deploy@api:/srv/app")
oSite.SetAuthRefQ(oSecret)
chk("the site holds the secret OBJECT", oSite.HasAuthSecret())
chk("AuthReference() is the redacted descriptor, not the key", StzFindFirst("<secret", oSite.AuthReference()) > 0)
cJson = oSite.ConfigJson()
chk("ConfigJson() serialises the DESCRIPTOR, never the key", StzFindFirst("<secret 'prod-deploy'", cJson) > 0)
chk("...the resolved key value is NOWHERE in the config", StzFindFirst("ssh-ed25519", cJson) = 0)
chk("ResolveAuth() for an effectful actor returns the LIVE key", oSite.ResolveAuth(oHuman) = "ssh-ed25519-AAAAlive")
bSiteRefused = FALSE
try
	oSite.ResolveAuth(oLLM)
catch
	bSiteRefused = TRUE
done
chk("...ResolveAuth() for an LLM actor is REFUSED", bSiteRefused)
oSite2 = new stzDeploymentSite("legacy")
oSite2.SetAuthRefQ("env/OTHER_KEY")
chk("a plain ref STRING still works (back-compat, no object)", NOT oSite2.HasAuthSecret() and oSite2.AuthReference() = "env/OTHER_KEY")
chk("...ResolveAuth on a plain ref returns the ref itself", oSite2.ResolveAuth(oHuman) = "env/OTHER_KEY")

? ""
? "-- Scene 6: stzAuth -- authenticate PEOPLE, store only hashes --"
oAuth = new stzAuth()
oAuth.Register("mansour", "s3cr3t!")
oAuth.Register("sara", "pw")
chk("two users registered", oAuth.NumberOfUsers() = 2)
chk("the correct password authenticates", oAuth.Authenticate("mansour", "s3cr3t!"))
chk("...a wrong password is rejected", NOT oAuth.Authenticate("mansour", "nope"))
chk("...an unknown user is rejected", NOT oAuth.Authenticate("ghost", "x"))
cTok = oAuth.Login("mansour", "s3cr3t!")
chk("Login opens a session -- an opaque 256-bit token", len(cTok) = 64 and oAuth.IsValidSession(cTok))
chk("...the session maps back to its user", oAuth.UserOfSession(cTok) = "mansour")
chk("...a bad login returns no token", oAuth.Login("mansour", "wrong") = "")
oAuth.Logout(cTok)
chk("Logout ends the session", NOT oAuth.IsValidSession(cTok))
chk("ChangePassword requires the current one", NOT oAuth.ChangePassword("mansour", "wrong", "new"))
chk("...and succeeds when it is presented", oAuth.ChangePassword("mansour", "s3cr3t!", "newpw"))
chk("...the new password now authenticates", oAuth.Authenticate("mansour", "newpw"))
chk("...the old one no longer does", NOT oAuth.Authenticate("mansour", "s3cr3t!"))

StzDirDeleteAll(cScratch)

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
