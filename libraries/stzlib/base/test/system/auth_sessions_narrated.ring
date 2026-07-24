load "../../stzBase.ring"
load "../_narrated.ring"

# stzAuth phase 2 -- session hardening (auth plan).
#
# Phase 1 made stzAuth durable and closed the enumeration + brute-force holes.
# Phase 2 hardens SESSIONS: per-session metadata (created / ip / user-agent) so a
# user can see and manage their devices; revoke one device or rotate a session
# on privilege change (fixation defense); and an optional idle timeout alongside
# the absolute one. All backward-compatible -- Login is unchanged; LoginWith adds
# the device context.

$cDb = WorkingDirectory() + "/_authtest_p2.db"

Scenario("a session carries device metadata, and a user can list their devices")
	oAuth = new stzAuth()
	oAuth.Register("dana", "pw")
	t1 = oAuth.LoginWith("dana", "pw", "10.0.0.1", "Firefox/Linux")
	t2 = oAuth.LoginWith("dana", "pw", "10.0.0.2", "Safari/iOS")

	aDev = oAuth.SessionsOf("dana")
	Then("both devices are listed", len(aDev), 2)
	Then("...each carrying its ip", aDev[1][:ip] = "10.0.0.1" or aDev[2][:ip] = "10.0.0.1", TRUE)
	Then("...and its user-agent", aDev[1][:userAgent] = "Firefox/Linux" or aDev[2][:userAgent] = "Firefox/Linux", TRUE)
	Then("SessionInfo returns one session's descriptor", oAuth.SessionInfo(t1)[:ip], "10.0.0.1")
	Then("...with a created stamp", oAuth.SessionInfo(t1)[:created] > 0, TRUE)
	# a plain Login still works, with empty context
	t3 = oAuth.Login("dana", "pw")
	Then("a plain Login still opens a session", oAuth.IsValidSession(t3), TRUE)
	Then("...listed with empty metadata", oAuth.SessionInfo(t3)[:ip], "")
EndScenario()

Scenario("revoke ONE device vs revoke ALL")
	oAuth = new stzAuth()
	oAuth.Register("dana", "pw")
	t1 = oAuth.LoginWith("dana", "pw", "10.0.0.1", "phone")
	t2 = oAuth.LoginWith("dana", "pw", "10.0.0.2", "laptop")
	t3 = oAuth.LoginWith("dana", "pw", "10.0.0.3", "tablet")

	When("one device is revoked")
	oAuth.RevokeSession(t2)
	Then("only that session ends", oAuth.IsValidSession(t2), FALSE)
	Then("...the others stay live", oAuth.IsValidSession(t1) and oAuth.IsValidSession(t3), TRUE)
	Then("...the device list drops to two", len(oAuth.SessionsOf("dana")), 2)

	When("all sessions are revoked")
	oAuth.RevokeAllSessions("dana")
	Then("none remain", len(oAuth.SessionsOf("dana")), 0)
	Then("...but the account survives", oAuth.IsRegistered("dana"), TRUE)
EndScenario()

Scenario("session ROTATION on privilege change (fixation defense)")
	Given("a logged-in session (say, before a 2FA step)")
	oAuth = new stzAuth()
	oAuth.Register("dana", "pw")
	told = oAuth.LoginWith("dana", "pw", "10.0.0.7", "Chrome")

	When("the session is rotated (privilege elevated)")
	tnew = oAuth.RotateSession(told)
	Then("the OLD token is void (cannot be replayed)", oAuth.IsValidSession(told), FALSE)
	Then("...a NEW token is live", oAuth.IsValidSession(tnew), TRUE)
	Then("...it is a fresh token", tnew != told, TRUE)
	Then("...for the same user", oAuth.UserOfSession(tnew), "dana")
	Then("...carrying the same device metadata", oAuth.SessionInfo(tnew)[:ip], "10.0.0.7")

	When("rotating an unknown token")
	Then("it yields no session", oAuth.RotateSession("bogus"), "")
EndScenario()

Scenario("idle timeout -- a session dies from inactivity (opt-in), and slides on use")
	Given("an auth with NO absolute expiry but a 100s idle timeout")
	oAuth = new stzAuth()
	oAuth.SetSessionTTLQ(0)
	oAuth.SetIdleTTLQ(100)
	oAuth.Register("dana", "pw")
	tok = oAuth.LoginWithAt("dana", "pw", "x", "y", 1000)

	Then("valid at t=1099 (99s idle) and it touches last-seen", oAuth.IsValidSessionAt(tok, 1099), TRUE)
	Then("...still valid at 1198 (99s from the 1099 touch -- the window slid)", oAuth.IsValidSessionAt(tok, 1198), TRUE)
	Then("...INVALID at 1198+101 (idle past the last touch)", oAuth.IsValidSessionAt(tok, 1198 + 101), FALSE)
	Then("...PurgeExpiredAt reaps the idle-dead session", oAuth.PurgeExpiredAt(1198 + 101) >= 1, TRUE)

	Given("idle timeout OFF (the default)")
	oAuth2 = new stzAuth()
	oAuth2.SetSessionTTLQ(0)
	oAuth2.Register("d", "pw")
	tk = oAuth2.LoginWithAt("d", "pw", "", "", 1000)
	Then("a session never idles out when the timeout is 0", oAuth2.IsValidSessionAt(tk, 9999999), TRUE)
EndScenario()

Scenario("metadata survives in the DB store (durable device list)")
	if isString($cDb) and fexists($cDb)  remove($cDb)  ok
	oA1 = new stzAuth()
	oA1.SetStore(StzAuthDbStoreQ($cDb))
	oA1.Register("dbuser", "pw")
	oA1.LoginWith("dbuser", "pw", "203.0.113.5", "curl/8")

	When("a separate stzAuth reads the same database")
	oA2 = new stzAuth()
	oA2.SetStore(StzAuthDbStoreQ($cDb))
	aDev = oA2.SessionsOf("dbuser")
	Then("the device is listed with its persisted ip", len(aDev) = 1 and aDev[1][:ip] = "203.0.113.5", TRUE)
	Then("...and user-agent", aDev[1][:userAgent], "curl/8")
	if isString($cDb) and fexists($cDb)  remove($cDb)  ok
EndScenario()

Summary()
