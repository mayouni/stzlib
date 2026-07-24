load "../../stzBase.ring"
load "../_narrated.ring"

# stzAuth phase 4 -- PASSWORDLESS login over the service-virtualization mail port.
#
# Phase 3 added a second factor; phase 4 adds first-factor-free sign-in: a magic
# LINK or an emailed OTP. Both need a way to SEND -- and that is the mail PORT of
# the service-virtualization plane. In dev/tests we bind stzMailSandbox: it
# CAPTURES what would have been sent (never delivers), so we can read the very
# link/code out of an inspectable sink and assert on it. At deploy you bind a real
# SMTP adapter behind the same one-method contract -- the same code, no fees.
#
# The emailed token is 256-bit; only its sha256 is stored (a store leak yields no
# usable link). Flows are enumeration-safe, one-time, expiring, and never bypass a
# confirmed 2FA. All deterministic here (an explicit 'now').

$cDb = WorkingDirectory() + "/_authtest_pwless.db"
NOW  = 1700000000

Scenario("magic link: the sink captures a real, redeemable link")
	oMail = new stzMailSandbox()
	oAuth = new stzAuth()
	oAuth.SetMailPort(oMail)
	oAuth.SetMagicLinkBaseUrl("https://app.example.com/auth")
	oAuth.Register("dana@corp.com", "pw")

	When("a magic link is requested")
	oAuth.RequestMagicLinkAt("dana@corp.com", NOW)
	Then("exactly one mail is captured (nothing is really sent)", oMail.Count(), 1)
	Then("...addressed to the user", oMail.LastTo(), "dana@corp.com")
	Then("...pointing at the app URL", StzFindFirst("https://app.example.com/auth", oMail.LastBody()) > 0, TRUE)

	cTok = TokenFrom(oMail.LastBody())
	Then("...carrying a 256-bit token", len(cTok), 64)

	When("the user clicks the link")
	cSess = oAuth.RedeemMagicLinkAt(cTok, NOW + 60)
	Then("a session opens", cSess != "", TRUE)
	Then("...mapped to the right user", oAuth.UserOfSessionAt(cSess, NOW + 60), "dana@corp.com")
	Then("the link is ONE-TIME (a second click fails)", oAuth.RedeemMagicLinkAt(cTok, NOW + 60), "")
EndScenario()

Scenario("magic link: expiry and enumeration-safety")
	oMail = new stzMailSandbox()
	oAuth = new stzAuth()
	oAuth.SetMailPort(oMail)
	oAuth.Register("dana@corp.com", "pw")

	When("a link is left too long")
	oAuth.RequestMagicLinkAt("dana@corp.com", NOW)
	cTok = TokenFrom(oMail.LastBody())
	Then("it is refused past the 15-minute TTL", oAuth.RedeemMagicLinkAt(cTok, NOW + 901), "")

	When("a link is requested for an UNKNOWN email")
	oMail.ClearQ()
	bRet = oAuth.RequestMagicLinkAt("ghost@nowhere.com", NOW)
	Then("the call looks identical (returns true)", bRet, TRUE)
	Then("...but nothing is sent (no account enumeration)", oMail.Count(), 0)
EndScenario()

Scenario("email OTP: a short code, one-time, brute-force aware")
	oMail = new stzMailSandbox()
	oAuth = new stzAuth()
	oAuth.SetMailPort(oMail)
	oAuth.Register("dana@corp.com", "pw")

	When("an email OTP is requested")
	oAuth.RequestEmailOtpAt("dana@corp.com", NOW)
	cCode = CodeFrom(oMail.LastBody())
	Then("a 6-digit code is captured", len(cCode), 6)

	When("the code is entered")
	cSess = oAuth.VerifyEmailOtpAt("dana@corp.com", cCode, NOW + 30)
	Then("a session opens", cSess != "", TRUE)
	Then("...the code is single-use", oAuth.VerifyEmailOtpAt("dana@corp.com", cCode, NOW + 30), "")

	When("a WRONG code is entered")
	oAuth.RequestEmailOtpAt("dana@corp.com", NOW)
	Then("it is refused", oAuth.VerifyEmailOtpAt("dana@corp.com", "000000", NOW), "")
	Then("...and it counts toward the brute-force lockout", oAuth.FailedAttempts("dana@corp.com") >= 1, TRUE)
EndScenario()

Scenario("a passwordless-only account has no usable password")
	oMail = new stzMailSandbox()
	oAuth = new stzAuth()
	oAuth.SetMailPort(oMail)
	oAuth.RegisterPasswordless("newbie@corp.com")

	Then("a password Login can never succeed", oAuth.LoginAt("newbie@corp.com", "", NOW), "")
	Then("...nor with any guessed password", oAuth.LoginAt("newbie@corp.com", "guess", NOW), "")

	When("they use a magic link instead")
	oAuth.RequestMagicLinkAt("newbie@corp.com", NOW)
	cTok = TokenFrom(oMail.LastBody())
	Then("it signs them in", oAuth.RedeemMagicLinkAt(cTok, NOW) != "", TRUE)
EndScenario()

Scenario("passwordless never bypasses a confirmed second factor")
	oMail = new stzMailSandbox()
	oAuth = new stzAuth()
	oAuth.SetMailPort(oMail)
	oAuth.Register("sec@corp.com", "pw")
	oDev = StzTotpFromSecretQ( oAuth.EnableTotp("sec@corp.com", "App")[:secret] )
	oAuth.ConfirmTotpAt("sec@corp.com", oDev.CodeAt(NOW), NOW)

	When("a 2FA user requests a magic link")
	oAuth.RequestMagicLinkAt("sec@corp.com", NOW)
	cTok = TokenFrom(oMail.LastBody())
	Then("redeeming it is REFUSED (2FA must still be satisfied)", oAuth.RedeemMagicLinkAt(cTok, NOW), "")

	When("the same user requests an email OTP")
	oMail.ClearQ()
	oAuth.RequestEmailOtpAt("sec@corp.com", NOW)
	cCode = CodeFrom(oMail.LastBody())
	Then("verifying it is also refused", oAuth.VerifyEmailOtpAt("sec@corp.com", cCode, NOW), "")
EndScenario()

Scenario("a passwordless request without a bound mail port raises")
	oAuth = new stzAuth()
	oAuth.Register("x", "pw")
	bRaised = FALSE
	try
		oAuth.RequestMagicLink("x")
	catch
		bRaised = TRUE
	done
	Then("it refuses to silently no-op", bRaised, TRUE)
EndScenario()

Scenario("passwordless challenges are durable across stzAuth instances")
	if isString($cDb) and fexists($cDb)  remove($cDb)  ok
	oMail = new stzMailSandbox()
	oA1 = new stzAuth()
	oA1.SetStore(StzAuthDbStoreQ($cDb))
	oA1.SetMailPort(oMail)
	oA1.Register("dana@corp.com", "pw")
	oA1.RequestMagicLinkAt("dana@corp.com", NOW)
	cTok = TokenFrom(oMail.LastBody())

	When("a SEPARATE stzAuth on the same database redeems the link")
	oA2 = new stzAuth()
	oA2.SetStore(StzAuthDbStoreQ($cDb))
	cSess = oA2.RedeemMagicLinkAt(cTok, NOW + 60)
	Then("the challenge persisted -- it opens a session", cSess != "", TRUE)
	Then("...and stays one-time across instances", oA1.RedeemMagicLinkAt(cTok, NOW + 60), "")
	if isString($cDb) and fexists($cDb)  remove($cDb)  ok
EndScenario()

Summary()


func TokenFrom cBody
	nP = StzFindFirst("token=", cBody)
	if nP = 0  return ""  ok
	cRest = StzMidToEnd(cBody, nP + 6)
	nNl = StzFindFirst(nl, cRest)
	if nNl > 0  return StzLeft(cRest, nNl - 1) ok
	return cRest

func CodeFrom cBody
	nP = StzFindFirst("code is: ", cBody)
	if nP = 0  return ""  ok
	cRest = StzMidToEnd(cBody, nP + 9)
	nNl = StzFindFirst(nl, cRest)
	if nNl > 0  return StzLeft(cRest, nNl - 1) ok
	return cRest
