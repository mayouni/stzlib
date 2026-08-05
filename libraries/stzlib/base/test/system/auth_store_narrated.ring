load "../../stzBase.ring"
load "../_narrated.ring"

# stzAuth phase 1 -- durable persistence + hardening (auth plan).
#
# stzAuth was a clean but in-memory, single-factor core. Phase 1 turns it into
# the spine of industrial-strength auth, closing the two worst holes and adding
# durability -- each lesson mapped to a pattern Softanza already owns:
#   L1 -- persist through an ADAPTER (stzAuthStore): in-memory default (today's
#         behaviour) or a stzDatabase-backed store (durable). The vault-resolver
#         seam, applied to identity.
#   L3 -- TIMING-SAFE Authenticate (no username-enumeration oracle) and
#         brute-force LOCKOUT.
# Backward-compatible: every method the secret guard exercised still works.

$cDb = WorkingDirectory() + "/_authtest_p1.db"

Scenario("backward-compat: the default in-memory store behaves as before")
	oAuth = new stzAuth()
	oAuth.Register("mansour", "s3cr3t!")
	oAuth.Register("sara", "pw")
	Then("two users registered", oAuth.NumberOfUsers(), 2)
	Then("the correct password authenticates", oAuth.Authenticate("mansour", "s3cr3t!"), TRUE)
	Then("...a wrong password is rejected", oAuth.Authenticate("mansour", "nope"), FALSE)
	Then("...an unknown user is rejected", oAuth.Authenticate("ghost", "x"), FALSE)
	cTok = oAuth.Login("mansour", "s3cr3t!")
	Then("Login opens a 64-char opaque session", len(cTok) = 64 and oAuth.IsValidSession(cTok), TRUE)
	Then("...mapping back to its user", oAuth.UserOfSession(cTok), "mansour")
	Then("...the session is still a stzToken", oAuth.SessionToken(cTok).Kind(), "token")
	oAuth.Logout(cTok)
	Then("Logout ends it", oAuth.IsValidSession(cTok), FALSE)
	Then("ChangePassword needs the current one", oAuth.ChangePassword("mansour", "x", "n"), FALSE)
	Then("...and succeeds when presented", oAuth.ChangePassword("mansour", "s3cr3t!", "newpw"), TRUE)
EndScenario()

Scenario("L3: unknown-user rejection is timing-equalized (behaviour side)")
	Given("a store with one real user")
	oAuth = new stzAuth()
	oAuth.Register("real", "pw")
	# the timing property (unknown-user costs the same PBKDF2 as a wrong password,
	# so it is not an enumeration oracle) is measured separately; here we pin the
	# behaviour it must preserve.
	Then("a wrong password for a REAL user is rejected", oAuth.Authenticate("real", "bad"), FALSE)
	Then("...an UNKNOWN user is rejected the same way", oAuth.Authenticate("ghost", "bad"), FALSE)
	Then("...the right password still passes", oAuth.Authenticate("real", "pw"), TRUE)
EndScenario()

Scenario("L3: brute-force lockout")
	Given("an auth with a 3-attempt limit and a 900s lockout")
	oAuth = new stzAuth()
	oAuth.SetMaxAttemptsQ(3)
	oAuth.SetLockoutSecondsQ(900)
	oAuth.Register("victim", "goodpw")

	When("three wrong logins arrive at t=1000")
	oAuth.LoginAt("victim", "x", 1000)
	oAuth.LoginAt("victim", "x", 1000)
	r3 = oAuth.LoginAt("victim", "x", 1000)
	Then("the failures are counted", oAuth.FailedAttempts("victim"), 3)
	Then("...the account is locked", oAuth.IsLockedOutAt("victim", 1000), TRUE)
	Then("...even the CORRECT password is refused while locked", oAuth.LoginAt("victim", "goodpw", 1000), "")

	When("the lockout window passes (t=1000+900)")
	Then("the correct password works again", oAuth.LoginAt("victim", "goodpw", 1900) != "", TRUE)

	# -- AND THE WINDOW IS THE ONE THAT WAS ASKED FOR --
	#
	# The scene above sets the lockout to 900 seconds, which is also the DEFAULT.
	# So every check in it passes whether SetLockoutSecondsQ() is honoured or does
	# nothing at all -- the one control that decides how long a brute-forcer is
	# held out had no assertion that could fail.
	#
	# This one uses a window that cannot be confused with the default, and pins
	# BOTH sides of the boundary: still locked at the last second inside it, free
	# at the first second past it.

	Given("a second account with a SIXTY second lockout")
	oShort = new stzAuth()
	oShort.SetMaxAttemptsQ(2)
	oShort.SetLockoutSecondsQ(60)
	oShort.Register("bilal", "goodpw")

	When("two wrong logins arrive at t=1000")
	oShort.LoginAt("bilal", "x", 1000)
	oShort.LoginAt("bilal", "x", 1000)

	Then("the account is locked", oShort.IsLockedOutAt("bilal", 1000), TRUE)
	Then("...still locked at the last second of the window", oShort.IsLockedOutAt("bilal", 1059), TRUE)
	Then("...free at the first second past it", oShort.IsLockedOutAt("bilal", 1060), FALSE)
	Then("...and the correct password is taken again", oShort.LoginAt("bilal", "goodpw", 1060) != "", TRUE)

	# THE NEGATIVE SIBLING: the same failures under the DEFAULT window are still
	# locked out at t=1060. Without this the checks above would also pass if the
	# lockout ignored its setting and expired on some shorter fixed schedule.
	Given("a third account left on the default window")
	oDef = new stzAuth()
	oDef.SetMaxAttemptsQ(2)
	oDef.Register("chaima", "goodpw")
	oDef.LoginAt("chaima", "x", 1000)
	oDef.LoginAt("chaima", "x", 1000)

	Then("it is STILL locked where the 60s account was free", oDef.IsLockedOutAt("chaima", 1060), TRUE)
	Then("...and only frees at its own, longer window", oDef.IsLockedOutAt("chaima", 1900), FALSE)
	Then("...and success cleared the failure counter", oAuth.FailedAttempts("victim"), 0)

	Given("a fresh victim")
	oAuth.Register("bob", "bobpw")
	When("two fails then a success (below the limit)")
	oAuth.LoginAt("bob", "x", 2000)
	oAuth.LoginAt("bob", "x", 2000)
	Then("a correct login succeeds and is never locked", oAuth.LoginAt("bob", "bobpw", 2000) != "", TRUE)
	Then("...counter reset", oAuth.FailedAttempts("bob"), 0)
EndScenario()

Scenario("revoke every session for a user without deleting the account")
	oAuth = new stzAuth()
	oAuth.Register("dana", "pw")
	t1 = oAuth.Login("dana", "pw")
	t2 = oAuth.Login("dana", "pw")
	Then("two live sessions", oAuth.NumberOfSessions(), 2)
	oAuth.RevokeAllSessions("dana")
	Then("both are gone", oAuth.IsValidSession(t1) = FALSE and oAuth.IsValidSession(t2) = FALSE, TRUE)
	Then("...but the account remains", oAuth.IsRegistered("dana"), TRUE)
	Then("...and she can log in again", oAuth.Login("dana", "pw") != "", TRUE)
EndScenario()

Scenario("L1: a DB-backed store makes users and sessions DURABLE")
	Given("an stzAuth pointed at a fresh sqlite file")
	if isString($cDb) and fexists($cDb)  remove($cDb)  ok
	oA1 = new stzAuth()
	oA1.SetStore(StzAuthDbStoreQ($cDb))
	oA1.Register("dbuser", "dbpw")
	tok = oA1.Login("dbuser", "dbpw")
	Then("the login is valid", oA1.IsValidSession(tok), TRUE)

	When("a SEPARATE stzAuth opens the SAME database file")
	oA2 = new stzAuth()
	oA2.SetStore(StzAuthDbStoreQ($cDb))
	Then("it sees the persisted user", oA2.IsRegistered("dbuser"), TRUE)
	Then("...and the persisted session (durable across instances)", oA2.IsValidSession(tok), TRUE)
	Then("...authentication works against the stored hash", oA2.Authenticate("dbuser", "dbpw"), TRUE)

	When("expiry is exercised over the DB store")
	oA2.SetSessionTTLQ(3600)
	sess = oA2.LoginAt("dbuser", "dbpw", 5000)
	Then("valid before expiry", oA2.IsValidSessionAt(sess, 5000 + 3599), TRUE)
	Then("...invalid after (dies on the clock, from sqlite)", oA2.IsValidSessionAt(sess, 5000 + 3601), FALSE)
	Then("...PurgeExpiredAt prunes it from the database", oA2.PurgeExpiredAt(5000 + 3601) >= 1, TRUE)
	if isString($cDb) and fexists($cDb)  remove($cDb)  ok
EndScenario()

Summary()
