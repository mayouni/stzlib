load "../../stzBase.ring"
load "../_narrated.ring"

# The Commons KDF closes the plaintext-secret gap. Identity secrets are
# stored as a per-user random SALT + a PBKDF2-HMAC-SHA256 hash (engine
# KDF), never the secret; verification re-derives and compares in
# constant time. Public helpers StzHashSecret/StzVerifySecret/
# StzRandomToken expose the same primitive.

Scenario("the engine KDF matches the standard PBKDF2 test vector")
	Given("PBKDF2-HMAC-SHA256('password','salt',1,32)")
	cDk = StzEngineCryptoPbkdf2("password", "salt", 1, 32)
	Then("it matches the RFC-style vector",
		cDk, "120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b")
EndScenario()

Scenario("hashing is salted, deterministic per-salt, and password-sensitive")
	Given("a hashed secret")
	cStored = StzHashSecretXT("hunter2", 20000)
	Then("it carries a salt and a hash (salt:hash)", StzFindFirst(":", cStored) > 0, TRUE)
	Then("the right secret verifies", StzVerifySecretXT("hunter2", cStored, 20000), TRUE)
	Then("a wrong secret does not", StzVerifySecretXT("hunter3", cStored, 20000), FALSE)

	Given("a second hash of the SAME secret")
	cStored2 = StzHashSecretXT("hunter2", 20000)
	Then("the two stored values differ (random salt)", cStored != cStored2, TRUE)
	Then("yet both verify the same secret", StzVerifySecretXT("hunter2", cStored2, 20000), TRUE)
EndScenario()

Scenario("random tokens are unique")
	cA = StzRandomToken(16)
	cB = StzRandomToken(16)
	Then("a 16-byte token is 32 hex chars", len(cA), 32)
	Then("two tokens differ", cA != cB, TRUE)
EndScenario()

Scenario("the Commons stores NO plaintext secret")
	Given("a platform Commons on in-memory sqlite (low rounds for speed)")
	$oDb = new stzDatabase(":memory:")
	oPlat = StzPlatformQ("secure-envelope")
	oPlat.SetKdfRounds(20000)
	oPlat.OpenCommonsOn($oDb)

	When("an identity registers with a secret")
	Then("registration succeeds", oPlat.RegisterIdentity("mansour", "s3cret!"), TRUE)
	When("we read the raw stored row")
	cRaw = $oDb.Value("SELECT secret FROM stz_identity WHERE user = 'mansour'")
	Then("the plaintext secret is NOT present", StzFindFirst("s3cret!", cRaw), 0)
	Then("what is stored is a salt:hash", StzFindFirst(":", cRaw) > 0, TRUE)

	When("the correct secret opens a session")
	cTok = oPlat.OpenSession("mansour", "s3cret!")
	Then("a token is issued", len(cTok) > 0, TRUE)
	Then("it resolves to the identity", oPlat.SessionUser(cTok), "mansour")
	When("a wrong secret is tried")
	Then("no session is opened", oPlat.OpenSession("mansour", "nope"), "")
	$oDb.Close()
EndScenario()

Scenario("Raising the KDF cost does not lock anybody out")

	# -- WHY THIS SCENE EXISTS --
	#
	# The record used to be "salt:hash" and verification re-derived at the
	# platform's CURRENT @nKdfRounds. So the cost was a property of the machine
	# checking the password rather than of the hash that was made -- and this
	# class's own header invites tuning it ("tunable via SetKdfRounds()").
	#
	# Call SetKdfRounds after anyone has registered and every one of them is
	# refused, with "identity/secret mismatch", which reads exactly like a wrong
	# password. Silent, misleading, and unfixable without re-registering everyone.
	#
	# The scene above could not see it: it sets the rounds BEFORE registering and
	# never changes them, so both sides always agreed.

	Given("an identity registered at 20000 rounds")
	oKdfDb = new stzDatabase(":memory:")
	oKdf = StzPlatformQ("cost-change")
	oKdf.SetKdfRounds(20000)
	oKdf.OpenCommonsOn(oKdfDb)
	Then("registration succeeds", oKdf.RegisterIdentity("ali", "s3cret"), TRUE)
	Then("...and the secret opens a session", len(oKdf.OpenSession("ali", "s3cret")) > 0, TRUE)

	# THE RECORD CARRIES ITS OWN COST. Without this the check below could pass
	# for the wrong reason -- for instance if the rounds were being ignored
	# altogether.
	cKdfRow = oKdfDb.Value("SELECT secret FROM stz_identity WHERE user = 'ali'")
	Then("the stored record begins with the rounds it was made at", StzLeft(cKdfRow, 6), "20000:")
	Then("...and still holds no plaintext", StzFindFirst("s3cret", cKdfRow), 0)

	When("the platform raises its cost to 30000")
	oKdf.SetKdfRounds(30000)

	Then("the identity still logs in", len(oKdf.OpenSession("ali", "s3cret")) > 0, TRUE)

	# THE NEGATIVE SIBLING: the fix must not have turned verification into a
	# formality. A wrong secret is still refused, at either cost.
	Then("...but a wrong secret is still refused", oKdf.OpenSession("ali", "nope"), "")

	When("a NEW identity registers at the raised cost")
	oKdf.RegisterIdentity("bilal", "other")
	cKdfRow2 = oKdfDb.Value("SELECT secret FROM stz_identity WHERE user = 'bilal'")
	Then("its record carries the new cost", StzLeft(cKdfRow2, 6), "30000:")
	Then("...and it logs in beside the old one", len(oKdf.OpenSession("bilal", "other")) > 0, TRUE)
	Then("...while the first still does too", len(oKdf.OpenSession("ali", "s3cret")) > 0, TRUE)

	# A RECORD WRITTEN BEFORE THE ROUNDS WERE STORED is a two-part "salt:hash".
	# It is verified at the platform's current setting -- exactly what used to
	# happen to every record -- so nothing that works today stops working.
	Given("a legacy two-part record, as the old code wrote them")
	oKdf.SetKdfRounds(20000)
	cLegacySalt = StzEngineCryptoRandomHex(16)
	cLegacyHash = StzEngineCryptoPbkdf2("legacypw", cLegacySalt, 20000, 32)
	oKdfDb.Exec("INSERT INTO stz_identity (user, secret) VALUES ('old', '" +
	            cLegacySalt + ":" + cLegacyHash + "')")

	Then("it still opens a session", len(oKdf.OpenSession("old", "legacypw")) > 0, TRUE)
	Then("...and still refuses a wrong secret", oKdf.OpenSession("old", "nope"), "")

	oKdfDb.Close()
EndScenario()

Summary()
