load "../../stzBase.ring"
load "../_narrated.ring"

# ENGINE PUBLIC-KEY SIGNATURE VERIFICATION (RS256 / ES256).
#
# The one primitive the whole external-identity story turns on. OAuth / OIDC
# (a provider's JWT id-token, signed by a key published in its JWKS), SSO, and
# passkeys / WebAuthn all reduce to the same question: "is this signature valid
# for this message under this PUBLIC key?" The auth plan deferred all of them on
# exactly this, and it is now in the engine (Zig std: ECDSA P-256 and
# RSASSA-PKCS1-v1_5, both with SHA-256).
#
# VERIFICATION ONLY -- Softanza never holds a private signing key here.
#
# Everything crosses as BASE64URL (ASCII), never raw bytes: the Ring<->engine
# boundary validates UTF-8 and would mangle a raw key or signature. That is also
# precisely the wire format -- a JWS signature and every JWKS field (n, e, x, y)
# are base64url -- so nothing needs converting on either side.
#
#   StzEngineCryptoVerifyEs256(cSigningInput, cSigB64, cXB64, cYB64) -> 1 / 0 / -1
#   StzEngineCryptoVerifyRs256(cSigningInput, cSigB64, cNB64, cEB64) -> 1 / 0 / -1
#   StzEngineCryptoB64UrlDecode(cB64)                                -> the bytes
#
# 1 = valid, 0 = invalid, -1 = malformed input. The vectors below were signed by
# OpenSSL 3.5 -- a real, independent signer, not a fixture we made up.

# ---- ES256 (ECDSA P-256 + SHA-256) -- an OpenSSL-signed JWS -------------
$cEsMsg = "eyJhbGciOiJFUzI1NiJ9.eyJzdWIiOiJkYW5hIiwiaXNzIjoic29mdGFuemEifQ"
$cEsSig = "iPuEkgC3Fj-U6UnrG_Iaapk203dCa6xr0L0e5CfkacUVBrN6lSHSZBO70qI-VmAIJkbEi4guG40bOm3_-sOOsg"
$cEsX   = "Fuy532v_Q2jW82IZFXUZByCKHCHqExgJcRC75ZX7zus"
$cEsY   = "inrBEmyylWkf8GUu-RV0OBAyEKQIuz8QkqKhoSdTluI"

# ---- RS256 (RSASSA-PKCS1-v1_5 + SHA-256), 2048-bit ---------------------
$cRsMsg = "eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJkYW5hIiwiaXNzIjoic29mdGFuemEifQ"
$cRsN   = "8s7R1YHtcMoRL3r6kV7gRHluosq_Z6I5Pf-zbBODgkCkSKDcML4JPGgimkEmI_rVc2S03KMD57X6Iicj09rDZzSxSRv1Mowuwh0z_m2Hr8VIUuERHyLYl8CNjuu02GNpfKURC0iGWj50iYVT9WU0LOG8CVuZJlxZMZ-VHE2BDKH1Oua6QbnMxe2eDSn-3G0ozXwdbK9xZ4EoNGpJ7x3_izBwevCjuwQ6o2j7Rrffwyw8jX-0UW17OodV91nL8gDopBGexwdrgdFveHJqkm58PG9C54PzlO3HZxjRvM3q9vXR52Q7Pmy4zNP7E-eLkkoxAhpZsY44fnGCaTLBNH-ONQ"
$cRsE   = "AQAB"
$cRsSig = "Yx4wqGMqTP2Oi2ahEdw-avE2vcdPUMo53fhwG7BmJxQQTQ6-FUAmUFzXfD_h9k2_2StN2ARDdkJE3QoBZBxQO-f4AJVJ4GDpbfin1ASRize2GIHD7ml6szq71y8lcm5vSZuBlt46qkzsVfgIE7iO8wkMiswcFOZFSYIQfHmJhEpnK_zPGpp95zCKFJayHAMu6bM1UuUntcYoIqsSr4YpwBR0nno6gvyGU7DzKVqZvq37miZZHLtIRolW7rNj7jVcKt_MLgEDasmrNjgGW39XmPsmeqUO8M1MVUYTgsWW_-wHXaCgxztFhqxyonEuRUII6-laG3X3nde-u382w0jFww"

Scenario("ES256: a genuine OpenSSL signature verifies under its public key")
	Then("the signature is valid", StzEngineCryptoVerifyEs256($cEsMsg, $cEsSig, $cEsX, $cEsY), 1)

	When("the PAYLOAD is tampered with (dana -> evil), keeping the signature")
	cEvil = "eyJhbGciOiJFUzI1NiJ9.eyJzdWIiOiJldmlsIiwiaXNzIjoic29mdGFuemEifQ"
	Then("verification FAILS -- the forgery is caught", StzEngineCryptoVerifyEs256(cEvil, $cEsSig, $cEsX, $cEsY), 0)

	When("the signature itself is altered (first bytes flipped)")
	cBadSig = "AAuEkgC3Fj-U6UnrG_Iaapk203dCa6xr0L0e5CfkacUVBrN6lSHSZBO70qI-VmAIJkbEi4guG40bOm3_-sOOsg"
	Then("verification fails", StzEngineCryptoVerifyEs256($cEsMsg, cBadSig, $cEsX, $cEsY), 0)

	When("a DIFFERENT public key is used")
	cOtherX = "inrBEmyylWkf8GUu-RV0OBAyEKQIuz8QkqKhoSdTluI"
	Then("verification fails (or the point is rejected)", StzEngineCryptoVerifyEs256($cEsMsg, $cEsSig, cOtherX, $cEsY) != 1, TRUE)
EndScenario()

Scenario("RS256: a genuine 2048-bit OpenSSL signature verifies under its JWKS key")
	Then("the signature is valid", StzEngineCryptoVerifyRs256($cRsMsg, $cRsSig, $cRsN, $cRsE), 1)

	When("the payload is tampered with")
	Then("verification FAILS", StzEngineCryptoVerifyRs256("eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJldmlsIn0", $cRsSig, $cRsN, $cRsE), 0)

	When("the same message is checked against the ES256 signature")
	Then("it fails -- a signature is bound to its algorithm and key", StzEngineCryptoVerifyRs256($cRsMsg, $cEsSig, $cRsN, $cRsE), 0)
EndScenario()

Scenario("malformed input is REPORTED (-1), never mistaken for a valid signature")
	Then("a non-base64url signature is malformed", StzEngineCryptoVerifyEs256($cEsMsg, "!!!not-base64!!!", $cEsX, $cEsY), -1)
	Then("a wrongly-sized coordinate is malformed", StzEngineCryptoVerifyEs256($cEsMsg, $cEsSig, "AAAA", "AAAA"), -1)
	Then("an empty signature is never valid", StzEngineCryptoVerifyEs256($cEsMsg, "", $cEsX, $cEsY) != 1, TRUE)
	Then("an empty RSA modulus is never valid", StzEngineCryptoVerifyRs256($cRsMsg, $cRsSig, "", $cRsE) != 1, TRUE)
EndScenario()

Scenario("the JWT shape works end to end: verify, then read the claims")
	# This is precisely what validating an OIDC id-token comes down to: split the
	# token, verify <header>.<payload> against the provider's JWKS key, and only
	# THEN trust the claims inside.
	cToken = $cEsMsg + "." + $cEsSig

	When("the token is split into its three parts")
	aParts = StzSplit(cToken, ".")
	Then("there are three", len(aParts), 3)

	cSigningInput = aParts[1] + "." + aParts[2]
	Then("the signing input verifies against the key", StzEngineCryptoVerifyEs256(cSigningInput, aParts[3], $cEsX, $cEsY), 1)

	When("and only then are the claims decoded")
	cHeader = StzEngineCryptoB64UrlDecode(aParts[1])
	cPayload = StzEngineCryptoB64UrlDecode(aParts[2])
	Then("the header names the algorithm", cHeader, '{"alg":"ES256"}')
	Then("the payload carries the subject", StzFindFirst('"sub":"dana"', cPayload) > 0, TRUE)
	Then("...and the issuer", StzFindFirst('"iss":"softanza"', cPayload) > 0, TRUE)
EndScenario()

Summary()
