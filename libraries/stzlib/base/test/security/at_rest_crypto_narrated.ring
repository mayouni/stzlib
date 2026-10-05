load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-AT-REST-01 -- threat-model risk R3: passwords get a memory-hard
# hash, and data at rest gets authenticated encryption.
#
# Passwords were PBKDF2 only: CPU-hard, so a GPU runs guesses in parallel.
# They are now Argon2id (OWASP's minimum: 19 MiB, 2 passes, 1 lane) in the
# standard PHC form, and an old PBKDF2 hash upgrades itself on the next
# successful login -- the only moment the plaintext is in hand.
#
# Nothing could be sealed at rest. The engine now has XChaCha20-Poly1305
# (StzSeal / StzOpen), and a secret store can be written as one sealed
# file keyed by a secret of its own -- literal values sealed, env / file /
# vault secrets saved as pointers only.

$cStore = "_tmp_sealed_store.stzsecrets"
$oHuman = HumanActor("oncall")
$oLlm = LLMActor("assistant")

# =====================================================================
#  PASSWORDS (the first scenario runs against the old code too)
# =====================================================================

Scenario("a new password is stored as Argon2id")
	oAuth = new stzAuth()
	oAuth.Register("ada", "correct horse battery staple")
	cH = oAuth.@oStore.UserHash("ada")
	# before: "salt:hash", PBKDF2
	Then("the stored hash is Argon2id with OWASP's parameters",
		StzLeft(cH, 31), "$argon2id$v=19$m=19456,t=2,p=1$")
	Then("the right password logs in", oAuth.Login("ada", "correct horse battery staple") != "", 1)
	Then("a wrong one does not", oAuth.Login("ada", "correct horse battery"), "")
EndScenario()

Scenario("an old PBKDF2 hash still works, and upgrades itself on login")
	oAuth = new stzAuth()
	oAuth.Register("bob", "placeholder")
	oAuth.@oStore.PutUser("bob", StzHashSecret("old-password"))
	cBefore = oAuth.@oStore.UserHash("bob")
	Given("a user whose hash was stored before Argon2id: " + StzLeft(cBefore, 12) + "...")
	Then("a WRONG password neither logs in", oAuth.Login("bob", "guess"), "")
	Then("...nor touches the stored hash", oAuth.@oStore.UserHash("bob"), cBefore)
	Then("the right password logs in", oAuth.Login("bob", "old-password") != "", 1)
	Then("and the stored hash is now Argon2id", StzLeft(oAuth.@oStore.UserHash("bob"), 10), "$argon2id$")
	Then("which still verifies the same password", oAuth.Authenticate("bob", "old-password"), 1)
EndScenario()

Scenario("the same password hashes differently each time (salted)")
	c1 = StzHashPassword("same")
	c2 = StzHashPassword("same")
	Then("two hashes differ", c1 != c2, 1)
	Then("both verify", StzVerifyPassword("same", c1) and StzVerifyPassword("same", c2), 1)
	Then("a PBKDF2-shaped hash is flagged for rehash", StzPasswordNeedsRehash(StzHashSecret("x")), 1)
	Then("an Argon2id one is not", StzPasswordNeedsRehash(c1), 0)
	nT0 = StzEngineWatchTimestampMs()
	for i = 1 to 5  StzHashPassword("cost probe " + i)  next
	nMs = (StzEngineWatchTimestampMs() - nT0) / 5
	? "    Argon2id cost on this machine: " + nMs + " ms per hash"
	Then("a hash costs well under a second", nMs < 1000, 1)
EndScenario()

# =====================================================================
#  SEAL / OPEN
# =====================================================================

Scenario("sealed data opens only with the right key and the right label")
	cKey = StzNewSealKey()
	cPlain = "line one" + char(9) + "tab" + char(10) + "line two -- " + "caf" + char(195) + char(169)
	cBlob = StzSeal(cKey, cPlain, "store:billing")
	Then("the key is 64 hex characters", len(cKey), 64)
	Then("the blob does not contain the plaintext", StzFindFirst("line one", cBlob), 0)
	Then("it opens back byte for byte", StzOpen(cKey, cBlob, "store:billing") = cPlain, 1)
	Then("sealing twice gives two different blobs (a fresh nonce)",
		StzSeal(cKey, cPlain, "store:billing") != cBlob, 1)
	Then("a WRONG key is refused", OpenRaises(StzNewSealKey(), cBlob, "store:billing"), 1)
	Then("another label is refused", OpenRaises(cKey, cBlob, "store:payroll"), 1)
	cBad = StzLeft(cBlob, 60) + FlipHex(cBlob[61]) + StzMidToEnd(cBlob, 62)
	Then("one altered character is refused", OpenRaises(cKey, cBad, "store:billing"), 1)
EndScenario()

# =====================================================================
#  A SECRET STORE, SEALED AT REST
# =====================================================================

Scenario("a secret store is written sealed, and read back whole")
	oKey = StzSecretQ("master-key").FromLiteralQ(StzNewSealKey())
	oS = StzSecretStoreQ("billing")
	oS.Register(StzApiKeyQ("stripe").FromLiteralQ("sk_test_ABC" + char(9) + "tail"))
	oS.Register(StzApiKeyQ("github").FromEnvQ("GITHUB_TOKEN"))
	oTok = StzTokenQ("session")
	oTok.FromLiteral("tok-123")
	oTok.SetExpiry(2000000000)
	oS.Register(oTok)
	oS.SaveSealedTo($cStore, oKey, $oHuman)
	cFile = read($cStore)
	Then("the file names the store and its format", StzFindFirst("stzsecrets v1", cFile) > 0, 1)
	Then("no literal value is readable in the file", StzFindFirst("sk_test_ABC", cFile), 0)
	Then("nor is the env var's NAME (all of it is sealed)", StzFindFirst("GITHUB_TOKEN", cFile), 0)
	oBack = StzSecretStoreFromSealedFile($cStore, oKey, $oHuman)
	Then("the three secrets came back", oBack.NumberOfSecrets(), 3)
	Then("the literal value is exact (tab included)",
		oBack.Reveal("stripe", $oHuman) = "sk_test_ABC" + char(9) + "tail", 1)
	Then("the env secret came back as a POINTER", oBack.Secret("github").SourceLocator(), "GITHUB_TOKEN")
	Then("the token kept its kind and expiry", oBack.Secret("session").ExpiresAt(), 2000000000)
EndScenario()

Scenario("a wrong key or an altered file opens nothing")
	oWrong = StzSecretQ("other-key").FromLiteralQ(StzNewSealKey())
	bRaised = 0
	try  StzSecretStoreFromSealedFile($cStore, oWrong, $oHuman)  catch  bRaised = 1  done
	Then("a wrong key raises", bRaised, 1)
	acL = StzSplit(read($cStore), char(10))
	write($cStore, acL[1] + char(10) + acL[2] + char(10) + FlipHex(acL[3][1]) + StzMidToEnd(acL[3], 2) + char(10))
	bRaised = 0
	try  StzSecretStoreFromSealedFile($cStore, StzSecretQ("x").FromLiteralQ(StzNewSealKey()), $oHuman)  catch  bRaised = 1  done
	Then("an altered file raises", bRaised, 1)
EndScenario()

Scenario("an LLM can neither seal a store nor open one")
	oKey = StzSecretQ("master-key").FromLiteralQ(StzNewSealKey())
	oS = StzSecretStoreQ("ops")
	oS.Register(StzApiKeyQ("x").FromLiteralQ("value"))
	bRaised = 0
	try  oS.SaveSealedTo($cStore, oKey, $oLlm)  catch  bRaised = 1  done
	Then("sealing is refused (it reads the secrets)", bRaised, 1)
	oS.SaveSealedTo($cStore, oKey, $oHuman)
	bRaised = 0
	try  StzSecretStoreFromSealedFile($cStore, oKey, $oLlm)  catch  bRaised = 1  done
	Then("opening is refused (the key is a secret it may not read)", bRaised, 1)
EndScenario()

if fexists($cStore)  remove($cStore)  ok

Summary()

func OpenRaises cKey, cBlob, cAad
	try
		StzOpen(cKey, cBlob, cAad)
	catch
		return 1
	done
	return 0

func FlipHex c
	if c = "a"  return "b"  ok
	return "a"
