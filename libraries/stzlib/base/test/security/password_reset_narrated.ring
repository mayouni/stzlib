load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-PASSWORD-RESET-01 -- threat-model risk R8: a password-reset flow
# that holds the same line as every other door.
#
# The recovery path is where accounts are taken over: a token that can be
# guessed, a link that works twice, a request that tells an attacker which
# emails have accounts, a reset that leaves the intruder's session alive.
# RequestPasswordReset / ResetPassword answer each of those, and a reset can
# never reopen an account containment locked.

NOW = 1700000000
$cDb = "_tmp_reset_auth.db"
CleanDb($cDb)

Scenario("a reset link works once, and ends every session")
	oMail = new stzMailSandbox()
	oAuth = NewAuth(oMail, "")
	cOld = oAuth.LoginAt("dana@corp.com", "old-password", NOW)
	Then("the user is signed in before", oAuth.IsValidSessionAt(cOld, NOW), 1)
	oAuth.RequestPasswordResetAt("dana@corp.com", NOW)
	Then("one mail is captured", oMail.Count(), 1)
	cTok = TokenFrom(oMail.LastBody())
	Then("carrying a 256-bit token", len(cTok), 64)
	Then("the reset succeeds", oAuth.ResetPasswordAt(cTok, "a-new-long-password", NOW + 60), 1)
	Then("the new password logs in", oAuth.LoginAt("dana@corp.com", "a-new-long-password", NOW + 61) != "", 1)
	Then("the old one does not", oAuth.LoginAt("dana@corp.com", "old-password", NOW + 62), "")
	Then("the session opened BEFORE the reset is dead", oAuth.IsValidSessionAt(cOld, NOW + 63), 0)
	Then("the link is one-time", oAuth.ResetPasswordAt(cTok, "another-long-password", NOW + 64), 0)
	Then("the stored hash is Argon2id", StzLeft(oAuth.@oStore.UserHash("dana@corp.com"), 10), "$argon2id$")
EndScenario()

Scenario("the request never tells who has an account")
	oMail = new stzMailSandbox()
	oAuth = NewAuth(oMail, "")
	Then("a known email: answered 1", oAuth.RequestPasswordResetAt("dana@corp.com", NOW), 1)
	Then("an unknown email: answered the SAME", oAuth.RequestPasswordResetAt("nobody@corp.com", NOW), 1)
	Then("...and only the real user got mail", oMail.Count(), 1)
EndScenario()

Scenario("an expired link, a guessed token and a short password are refused")
	oMail = new stzMailSandbox()
	oAuth = NewAuth(oMail, "")
	oAuth.RequestPasswordResetAt("dana@corp.com", NOW)
	cTok = TokenFrom(oMail.LastBody())
	Then("a guessed token does nothing", oAuth.ResetPasswordAt(StzEngineCryptoRandomHex(32), "a-new-long-password", NOW + 60), 0)
	Then("a link used after 30 minutes is refused", oAuth.ResetPasswordAt(cTok, "a-new-long-password", NOW + 1800), 0)
	oAuth.RequestPasswordResetAt("dana@corp.com", NOW + 2000)
	cTok2 = TokenFrom(oMail.LastBody())
	Then("a new password under 8 characters is refused", oAuth.ResetPasswordAt(cTok2, "short", NOW + 2010), 0)
	Then("...and the old password still works", oAuth.LoginAt("dana@corp.com", "old-password", NOW + 2011) != "", 1)
EndScenario()

Scenario("a newer request cancels the older link")
	oMail = new stzMailSandbox()
	oAuth = NewAuth(oMail, "")
	oAuth.RequestPasswordResetAt("dana@corp.com", NOW)
	cFirst = TokenFrom(oMail.LastBody())
	oAuth.RequestPasswordResetAt("dana@corp.com", NOW + 10)
	cSecond = TokenFrom(oMail.LastBody())
	Then("the first link no longer works", oAuth.ResetPasswordAt(cFirst, "a-new-long-password", NOW + 20), 0)
	Then("the newest one does", oAuth.ResetPasswordAt(cSecond, "a-new-long-password", NOW + 21), 1)
EndScenario()

Scenario("a reset cannot reopen an account containment locked")
	oMail = new stzMailSandbox()
	oAuth = NewAuth(oMail, "")
	oAuth.LockAccount("dana@corp.com", "credential stuffing observed")
	oAuth.RequestPasswordResetAt("dana@corp.com", NOW)
	Then("the reset is refused", oAuth.ResetPasswordAt(TokenFrom(oMail.LastBody()), "a-new-long-password", NOW + 60), 0)
	Then("the account is still locked", oAuth.IsAccountLocked("dana@corp.com"), 1)
EndScenario()

Scenario("a lockout from failed attempts IS cleared by a reset (negative sibling)")
	oMail = new stzMailSandbox()
	oAuth = NewAuth(oMail, "")
	for i = 1 to 6  oAuth.LoginAt("dana@corp.com", "wrong-" + i, NOW)  next
	Then("the failures locked the account out", oAuth.IsLockedOutAt("dana@corp.com", NOW + 1), 1)
	oAuth.RequestPasswordResetAt("dana@corp.com", NOW + 2)
	Then("the reset succeeds", oAuth.ResetPasswordAt(TokenFrom(oMail.LastBody()), "a-new-long-password", NOW + 3), 1)
	Then("and the user is back in", oAuth.LoginAt("dana@corp.com", "a-new-long-password", NOW + 4) != "", 1)
EndScenario()

Scenario("the same flow on the durable SQLite store")
	oMail = new stzMailSandbox()
	oAuth = NewAuth(oMail, $cDb)
	oAuth.RequestPasswordResetAt("dana@corp.com", NOW)
	cTok = TokenFrom(oMail.LastBody())
	Then("the reset succeeds", oAuth.ResetPasswordAt(cTok, "a-new-long-password", NOW + 60), 1)
	Then("and is one-time there too", oAuth.ResetPasswordAt(cTok, "a-new-long-password", NOW + 61), 0)
	oAuth.@oStore.DatabaseQ().Close()
EndScenario()

CleanDb($cDb)
Summary()

# -- helpers (after the main code) ------------------------------------

func NewAuth oMail, cDb
	oA = new stzAuth()
	if cDb != ""  oA.SetStore(new stzAuthDbStore(cDb))  ok
	oA.SetMailPort(oMail)
	oA.SetMagicLinkBaseUrl("https://app.example.com/auth")
	oA.Register("dana@corp.com", "old-password")
	return oA

func TokenFrom cBody
	nP = StzFindFirst("reset=", cBody)
	if nP = 0  return ""  ok
	cRest = StzMidToEnd(cBody, nP + 6)
	nNl = StzFindFirst(char(10), cRest)
	if nNl > 0  return StzLeft(cRest, nNl - 1)  ok
	return cRest

func CleanDb cPath
	acSuffix = [ "", "-wal", "-shm", "-journal" ]
	for i = 1 to 4
		if fexists(cPath + acSuffix[i])  remove(cPath + acSuffix[i])  ok
	next
