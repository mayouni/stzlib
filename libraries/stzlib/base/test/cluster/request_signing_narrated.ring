load "../../stzBase.ring"
load "../_narrated.ring"

# R8 REQUEST SIGNING -- authenticity + integrity between nodes (resilience/
# security rung #4). Governance decides whether a caller MAY proceed;
# signing proves the request IS from that caller and was not tampered.
# HMAC-SHA256 over a canonical (method, path, body, timestamp, nonce) with a
# per-caller shared secret (engine crypto.zig). A forged/tampered request
# fails the MAC; a stale one fails the freshness window; a replayed one fails
# the nonce check. Deterministic (explicit timestamps/nonces) end to end.

# =====================================================================
#  UNIT: the signer (the real crypto, exhaustive threat cases)
# =====================================================================

Scenario("a genuine request verifies")
	Given("a signer holding web's shared key")
	$oSg = new stzRequestSigner("grid")
	$oSg.AddKey("web", "shared-secret-abc")
	env = $oSg.Sign("web", "GET", "/work?q=x", "", 1000, "n-1")
	Then("the signature is a 64-hex HMAC", len(env[:sig]), 64)
	Then("it verifies within the freshness window",
		$oSg.Verify("web", "GET", "/work?q=x", "", 1000, "n-1", env[:sig], 30000, 1000), TRUE)
EndScenario()

Scenario("tampering with the path or body breaks the signature (integrity)")
	Given("a signed request")
	oSi = new stzRequestSigner("g")
	oSi.AddKey("web", "sekret")
	e = oSi.Sign("web", "GET", "/work?q=hello", "body-1", 2000, "n-2")
	Then("a tampered PATH is rejected",
		oSi.Verify("web", "GET", "/work?q=EVIL", "body-1", 2000, "n-9", e[:sig], 30000, 2000), FALSE)
	Then("a tampered BODY is rejected",
		oSi.Verify("web", "GET", "/work?q=hello", "INJECTED", 2000, "n-8", e[:sig], 30000, 2000), FALSE)
	Then("a tampered METHOD is rejected",
		oSi.Verify("web", "POST", "/work?q=hello", "body-1", 2000, "n-7", e[:sig], 30000, 2000), FALSE)
	Then("the why names a signature mismatch",
		StzFindFirst("signature mismatch", oSi.Why()) = 1, TRUE)
EndScenario()

Scenario("a wrong or unknown key cannot forge (authenticity)")
	Given("two callers with different secrets")
	oSk = new stzRequestSigner("g")
	oSk.AddKey("web", "web-secret")
	oSk.AddKey("gpu", "gpu-secret")
	e = oSk.Sign("web", "GET", "/x", "", 3000, "n-3")
	Then("verifying web's signature under gpu's key fails",
		oSk.Verify("gpu", "GET", "/x", "", 3000, "n-30", e[:sig], 30000, 3000), FALSE)
	Then("a caller with NO registered key is rejected",
		oSk.Verify("ghost", "GET", "/x", "", 3000, "n-31", e[:sig], 30000, 3000), FALSE)
	Then("the why names the unknown key",
		StzFindFirst("unknown key", oSk.Why()) = 1, TRUE)
EndScenario()

Scenario("stale or future-dated requests fail the freshness window")
	Given("a request signed at t=1000, a 30s window")
	oSf = new stzRequestSigner("g")
	oSf.AddKey("web", "s")
	e = oSf.Sign("web", "GET", "/x", "", 1000, "n-4")
	Then("verified far in the future (now=99999) is rejected as stale",
		oSf.Verify("web", "GET", "/x", "", 1000, "n-4", e[:sig], 30000, 99999), FALSE)
	Then("a future-dated timestamp (clock skew ahead) is also rejected",
		oSf.Verify("web", "GET", "/x", "", 500000, "n-40",
			oSf.Sign("web", "GET", "/x", "", 500000, "n-40")[:sig], 30000, 1000), FALSE)
	Then("the why names the freshness window",
		StzFindFirst("freshness window", oSf.Why()) > 0, TRUE)
EndScenario()

Scenario("a captured signature cannot be replayed (nonce)")
	Given("a genuine request verified once")
	oSr = new stzRequestSigner("g")
	oSr.AddKey("web", "s")
	e = oSr.Sign("web", "GET", "/pay", "amount=100", 5000, "n-5")
	Then("the first use verifies",
		oSr.Verify("web", "GET", "/pay", "amount=100", 5000, "n-5", e[:sig], 30000, 5000), TRUE)
	Then("an identical replay (same nonce) is rejected",
		oSr.Verify("web", "GET", "/pay", "amount=100", 5000, "n-5", e[:sig], 30000, 5010), FALSE)
	Then("the why names a replay", StzFindFirst("replay", oSr.Why()) = 1, TRUE)
	Then("a DIFFERENT nonce for the same request verifies (fresh request)",
		oSr.Verify("web", "GET", "/pay", "amount=100", 5000, "n-5b",
			oSr.Sign("web", "GET", "/pay", "amount=100", 5000, "n-5b")[:sig], 30000, 5000), TRUE)
EndScenario()

Scenario("SignNow / VerifyEnvelope round-trip on the real clock")
	Given("a signer and a fresh envelope")
	oSn = new stzRequestSigner("g")
	oSn.AddKey("gpu", "k")
	env = oSn.SignNow("gpu", "POST", "/embed", "payload")
	Then("the envelope carries the four fields",
		len(env[:kid]) > 0 and env[:ts] > 0 and len(env[:nonce]) > 0 and len(env[:sig]) = 64, TRUE)
	Then("it verifies immediately", oSn.VerifyEnvelope("POST", "/embed", "payload", env, 30000), TRUE)
	Then("a tampered envelope target is rejected",
		oSn.VerifyEnvelope("GET", "/embed", "payload", env, 30000), FALSE)
EndScenario()

# =====================================================================
#  FEDERATION: two nodes, a signed call, receiver-side verification
# =====================================================================

Scenario("a federated call is SIGNED when the caller shares a key")
	Given("a governed federation where 'web' shares a key")
	$oFed = new stzComputeFederation("grid-a")
	$oFed.Join("mathhost", "127.0.0.1:65510", [ :math ])
	$oFed.Bond("web", :math)
	$oFed.GovDeclareRisk("use-math", 1).GovGrant("web", "use-math").GovSetAuthority("web", :Delegated)
	$oFed.RegisterKey("web", "grid-shared-secret")
	When("web makes a federated call (transport fails -- no live host, that's fine)")
	$oFed.FederatedCall("web", :math, "/work?q=42", "")
	Then("the outbound request was signed (an envelope is recorded)",
		len($oFed.LastSignature()) > 0, TRUE)
	Then("the envelope names web as the signer", $oFed.LastSignature()[:kid], "web")
	Then("the signature is a 64-hex HMAC", len($oFed.LastSignature()[:sig]), 64)
EndScenario()

Scenario("an unsigned caller (no key) transports without a signature")
	Given("the same federation, but caller 'anon' has no key")
	$oFed.Bond("anon", :math)
	$oFed.GovGrant("anon", "use-math").GovSetAuthority("anon", :Delegated)
	When("anon makes a federated call")
	$oFed.FederatedCall("anon", :math, "/work?q=1", "")
	Then("no signature envelope is produced (opt-in signing)",
		len($oFed.LastSignature()), 0)
	$oFed.Shutdown()
EndScenario()

Scenario("the RECEIVER verifies a signed call and rejects tampering")
	Given("node A signs; node B shares the same key")
	$oA = new stzComputeFederation("node-a")
	$oA.Join("h", "127.0.0.1:65509", [ :math ])
	$oA.Bond("web", :math)
	$oA.GovDeclareRisk("use-math", 1).GovGrant("web", "use-math").GovSetAuthority("web", :Delegated)
	$oA.RegisterKey("web", "AB-shared-secret")
	$oB = new stzComputeFederation("node-b")
	$oB.RegisterKey("web", "AB-shared-secret")   # B shares the key
	$oC = new stzComputeFederation("node-c")     # C does NOT

	When("A issues a signed federated call")
	$oA.FederatedCall("web", :math, "/work?q=42", "")
	env = $oA.LastSignature()
	Then("B accepts the genuine request against its original target",
		$oB.VerifyInboundEnvelope("GET", "/work?q=42", "", env, 30000), TRUE)
	Then("B rejects the same signature on a TAMPERED path",
		$oB.VerifyInboundEnvelope("GET", "/work?q=DRAIN-FUNDS", "", env, 30000), FALSE)
	Then("B rejects a REPLAY of the (now-consumed) genuine request",
		$oB.VerifyInboundEnvelope("GET", "/work?q=42", "", env, 30000), FALSE)
	Then("node C, without the shared key, cannot verify it at all",
		$oC.VerifyInboundEnvelope("GET", "/work?q=42", "", env, 30000), FALSE)

	$oA.Shutdown()  $oB.Shutdown()  $oC.Shutdown()
EndScenario()

Scenario("signing is a SEPARATE gate from governance (defense in depth)")
	Given("a federation where a caller is signed but governance would still gate")
	$oG = new stzComputeFederation("dib")
	$oG.Join("h", "127.0.0.1:65508", [ :neural ])
	$oG.RegisterKey("web", "k")                  # web can sign...
	$oG.Bond("web", :neural)
	$oG.GovDeclareRisk("use-neural", 4)          # ...but the action is critical
	$oG.GovGrant("web", "use-neural").GovSetAuthority("web", :Delegated)  # authority 2 << 4
	When("web (validly signable) calls a critically-governed facet")
	cR = $oG.FederatedCall("web", :neural, "/x", "")
	Then("governance still refuses (signing does not bypass authorization)",
		$oG.CallLastStatus() < 0, TRUE)
	Then("and because it never reached transport, nothing was signed",
		len($oG.LastSignature()), 0)
	$oG.Shutdown()
EndScenario()

Summary()
