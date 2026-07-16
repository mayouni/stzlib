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
	Then("it carries a salt and a hash (salt:hash)", StzFindFirst(cStored, ":") > 0, TRUE)
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
	oPlat.WithKdfRounds(20000)
	oPlat.CommonsOn($oDb)

	When("an identity registers with a secret")
	Then("registration succeeds", oPlat.RegisterIdentity("mansour", "s3cret!"), TRUE)
	When("we read the raw stored row")
	cRaw = $oDb.Value("SELECT secret FROM stz_identity WHERE user = 'mansour'")
	Then("the plaintext secret is NOT present", StzFindFirst(cRaw, "s3cret!"), 0)
	Then("what is stored is a salt:hash", StzFindFirst(cRaw, ":") > 0, TRUE)

	When("the correct secret opens a session")
	cTok = oPlat.OpenSession("mansour", "s3cret!")
	Then("a token is issued", len(cTok) > 0, TRUE)
	Then("it resolves to the identity", oPlat.SessionUser(cTok), "mansour")
	When("a wrong secret is tried")
	Then("no session is opened", oPlat.OpenSession("mansour", "nope"), "")
	$oDb.Close()
EndScenario()

Summary()
