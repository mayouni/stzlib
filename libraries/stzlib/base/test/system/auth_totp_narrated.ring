load "../../stzBase.ring"
load "../_narrated.ring"

# stzAuth phase 3 -- TOTP two-factor authentication (auth plan).
#
# Phase 1 made stzAuth durable and closed the enumeration + brute-force holes;
# phase 2 hardened sessions. Phase 3 adds a real authenticator-app SECOND FACTOR:
# RFC 6238 TOTP, computed by the engine (StzEngineCryptoTotp -- HMAC + truncation
# engine-side, hex key in / digits out). stzTotp owns the base32 secret and the
# otpauth:// provisioning URI; stzAuth owns the per-user enrollment, the enforced
# login flow, and one-time recovery codes. Everything is deterministic here (an
# explicit 'now'), so the codes are reproducible.

$cDb = WorkingDirectory() + "/_authtest_totp.db"
NOW  = 1700000000

Scenario("the TOTP primitive is RFC 6238-correct and tolerates clock drift")
	# RFC 6238 App.B seed "12345678901234567890" -> base32; at t=59 the 6-digit
	# code is 287082 (the last 6 digits of the published 8-digit vector 94287082).
	oT = StzTotpFromSecretQ("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
	Then("the known vector reproduces exactly", oT.CodeAt(59), "287082")
	Then("...it verifies at that instant", oT.VerifyAt("287082", 59), TRUE)
	Then("...still valid 29s later (same 30s step)", oT.VerifyAt("287082", 59 + 29), TRUE)
	Then("...and one step earlier (skew tolerance)", oT.VerifyAt("287082", 59 + 30), TRUE)
	Then("...rejected three steps out", oT.VerifyAt("287082", 59 + 95), FALSE)
	Then("...a wrong code is rejected", oT.VerifyAt("000000", 59), FALSE)

	When("a provisioning URI is built for an authenticator app")
	cUri = oT.ProvisioningUri("alice@corp", "Softanza")
	Then("it is an otpauth TOTP URI", StzFindFirst("otpauth://totp/", cUri), 1)
	Then("...carrying the base32 secret", StzFindFirstCS("secret=GEZDGNBVGY3TQOJQ", cUri, TRUE) > 0, TRUE)
	Then("...the issuer", StzFindFirstCS("issuer=Softanza", cUri, TRUE) > 0, TRUE)
	Then("...and the SHA1 algorithm (app default)", StzFindFirstCS("algorithm=SHA1", cUri, TRUE) > 0, TRUE)
EndScenario()

Scenario("enrollment is two-step: a mis-scan never locks the user out")
	oAuth = new stzAuth()
	oAuth.Register("dana", "pw")

	When("2FA enrollment begins")
	enr = oAuth.EnableTotp("dana", "Softanza")
	Then("a secret and a QR URI are returned", len(enr[:secret]) > 0 and StzFindFirst("otpauth://", enr[:uri]) = 1, TRUE)
	Then("...but nothing is enforced yet (still pending)", oAuth.RequiresTwoFactor("dana"), FALSE)
	Then("...so a plain password Login still works", oAuth.LoginAt("dana", "pw", NOW) != "", TRUE)

	When("the user proves a first code from their app")
	oDev  = StzTotpFromSecretQ(enr[:secret])       # stand-in for the phone app
	codes = oAuth.ConfirmTotpAt("dana", oDev.CodeAt(NOW), NOW)
	Then("enrollment is confirmed and 10 recovery codes are handed back", len(codes), 10)
	Then("...2FA is now required for this user", oAuth.RequiresTwoFactor("dana"), TRUE)

	When("confirming with a WRONG code (a fresh enrollee)")
	oAuth.Register("erin", "pw")
	oAuth.EnableTotp("erin", "Softanza")
	Then("confirmation fails (returns no codes)", len(oAuth.ConfirmTotpAt("erin", "000000", NOW)), 0)
	Then("...and 2FA stays off", oAuth.RequiresTwoFactor("erin"), FALSE)
EndScenario()

Scenario("once 2FA is on, password alone is refused -- the second factor is the door")
	oAuth = new stzAuth()
	oAuth.Register("dana", "pw")
	oDev = StzTotpFromSecretQ( oAuth.EnableTotp("dana", "Softanza")[:secret] )
	oAuth.ConfirmTotpAt("dana", oDev.CodeAt(NOW), NOW)

	Then("a plain Login is now REFUSED (2FA enforced)", oAuth.LoginAt("dana", "pw", NOW), "")

	When("logging in with password AND the app code")
	tok = oAuth.LoginTwoFactorAt("dana", "pw", oDev.CodeAt(NOW), NOW)
	Then("a session opens", tok != "", TRUE)
	Then("...mapped to the right user", oAuth.UserOfSessionAt(tok, NOW), "dana")

	Then("a wrong CODE is refused", oAuth.LoginTwoFactorAt("dana", "pw", "000000", NOW), "")
	Then("a wrong PASSWORD is refused (even with a good code)", oAuth.LoginTwoFactorAt("dana", "bad", oDev.CodeAt(NOW), NOW), "")
EndScenario()

Scenario("recovery codes are single-use")
	oAuth = new stzAuth()
	oAuth.Register("dana", "pw")
	oDev  = StzTotpFromSecretQ( oAuth.EnableTotp("dana", "Softanza")[:secret] )
	codes = oAuth.ConfirmTotpAt("dana", oDev.CodeAt(NOW), NOW)

	Then("ten codes remain", oAuth.RecoveryCodesRemaining("dana"), 10)

	When("a recovery code is used to log in (phone lost)")
	Then("it opens a session", oAuth.LoginTwoFactorAt("dana", "pw", codes[1], NOW) != "", TRUE)
	Then("...one code is consumed", oAuth.RecoveryCodesRemaining("dana"), 9)
	Then("...the SAME code cannot be reused", oAuth.LoginTwoFactorAt("dana", "pw", codes[1], NOW), "")
	Then("...but a different one still works", oAuth.LoginTwoFactorAt("dana", "pw", codes[2], NOW) != "", TRUE)

	When("recovery codes are regenerated")
	fresh = oAuth.RegenerateRecoveryCodes("dana")
	Then("a full new set is issued", len(fresh), 10)
	Then("...and an OLD code no longer works", oAuth.LoginTwoFactorAt("dana", "pw", codes[3], NOW), "")
EndScenario()

Scenario("disabling 2FA restores the single-factor path")
	oAuth = new stzAuth()
	oAuth.Register("dana", "pw")
	oDev = StzTotpFromSecretQ( oAuth.EnableTotp("dana", "Softanza")[:secret] )
	oAuth.ConfirmTotpAt("dana", oDev.CodeAt(NOW), NOW)

	When("2FA is turned off")
	oAuth.DisableTotp("dana")
	Then("it is no longer required", oAuth.RequiresTwoFactor("dana"), FALSE)
	Then("...and a plain Login works again", oAuth.LoginAt("dana", "pw", NOW) != "", TRUE)
	Then("...no recovery codes linger", oAuth.RecoveryCodesRemaining("dana"), 0)
EndScenario()

Scenario("2FA state is durable (survives across stzAuth instances on one database)")
	if isString($cDb) and fexists($cDb)  remove($cDb)  ok
	oA1 = new stzAuth()
	oA1.SetStore(StzAuthDbStoreQ($cDb))
	oA1.Register("dbuser", "pw")
	oDev  = StzTotpFromSecretQ( oA1.EnableTotp("dbuser", "Softanza")[:secret] )
	codes = oA1.ConfirmTotpAt("dbuser", oDev.CodeAt(NOW), NOW)

	When("a separate stzAuth opens the same database")
	oA2 = new stzAuth()
	oA2.SetStore(StzAuthDbStoreQ($cDb))
	Then("it sees 2FA is required", oA2.RequiresTwoFactor("dbuser"), TRUE)
	Then("...refuses a plain Login", oA2.LoginAt("dbuser", "pw", NOW), "")
	Then("...accepts the app code", oA2.LoginTwoFactorAt("dbuser", "pw", oDev.CodeAt(NOW), NOW) != "", TRUE)
	Then("...and sees all ten recovery codes", oA2.RecoveryCodesRemaining("dbuser"), 10)

	When("a recovery code is consumed through the second instance")
	oA2.LoginTwoFactorAt("dbuser", "pw", codes[1], NOW)
	oA3 = new stzAuth()
	oA3.SetStore(StzAuthDbStoreQ($cDb))
	Then("the consumption persisted (nine remain)", oA3.RecoveryCodesRemaining("dbuser"), 9)
	if isString($cDb) and fexists($cDb)  remove($cDb)  ok
EndScenario()

Scenario("a user without 2FA is completely unaffected")
	oAuth = new stzAuth()
	oAuth.Register("bob", "pw")
	Then("RequiresTwoFactor is false", oAuth.RequiresTwoFactor("bob"), FALSE)
	Then("...plain Login works", oAuth.LoginAt("bob", "pw", NOW) != "", TRUE)
	Then("...and LoginTwoFactor works too (the code is ignored)", oAuth.LoginTwoFactorAt("bob", "pw", "", NOW) != "", TRUE)
EndScenario()

Summary()
