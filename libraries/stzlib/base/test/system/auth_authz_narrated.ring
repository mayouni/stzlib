load "../../stzBase.ring"
load "../_narrated.ring"

# stzAuth phase 5 -- the authn -> authz BRIDGE.
#
# The payoff of the whole auth story, and where Softanza exceeds a typical auth
# framework. A successful login does not merely mark a user "signed in": it yields
# the ACTOR the governance model already reasons about -- a stzSystemActor carrying
# a capability set (the effectful / sensing / compute / inference lattice) derived
# from the user's ROLES, at a trust posture. And the SAME username is the
# governance actor (stzGovernance.MayProceed) and the org-chart person
# (separation-of-duties). Auth is not a bolt-on; it is the front door to the
# governance model. Deterministic here (an explicit 'now').

$cDb = WorkingDirectory() + "/_authtest_authz.db"
NOW  = 1700000000

Scenario("a login yields the ACTOR the governance model reasons about")
	oAuth = new stzAuth()
	Then("four roles ship by default", len(oAuth.RoleNames()), 4)

	oAuth.Register("dana", "pw")
	oAuth.GrantRole("dana", "admin")
	cTok = oAuth.LoginAt("dana", "pw", NOW)

	oActor = oAuth.ActorOfAt(cTok, NOW)
	Then("the session resolves to an actor", isObject(oActor), TRUE)
	Then("...named for the user", oActor.Name(), "dana")
	Then("...holding admin's capability kinds", oActor.Can("effectful") and oActor.Can("compute") and oActor.Can("sensing"), TRUE)
	Then("...at a trusted posture", oActor.Posture(), "trusted")
	Then("SessionCan answers capability questions on the live session", oAuth.SessionCanAt(cTok, "effectful", NOW), TRUE)
	Then("SessionIsEffectful is true for an admin", oAuth.SessionIsEffectfulAt(cTok, NOW), TRUE)
EndScenario()

Scenario("capabilities are the UNION of a user's roles; posture the most restrictive")
	oAuth = new stzAuth()
	oAuth.Register("mix", "pw")
	oAuth.GrantRole("mix", "viewer")       # sensing / external
	oAuth.GrantRole("mix", "assistant")    # inference / sandboxed

	oActor = oAuth.ActorForUser("mix")
	Then("the actor holds BOTH roles' kinds", oActor.Can("sensing") and oActor.Can("inference"), TRUE)
	Then("...and only those", oActor.NumberOfKinds(), 2)
	Then("...at the most restrictive posture among the roles", oActor.Posture(), "sandboxed")
EndScenario()

Scenario("the load-bearing invariant: an assistant session is authenticated yet EFFECT-LESS")
	oAuth = new stzAuth()
	oAuth.Register("bot", "pw")
	oAuth.GrantRole("bot", "assistant")    # an LLM-backed account: inference only
	cTok = oAuth.LoginAt("bot", "pw", NOW)

	Then("the assistant is genuinely authenticated", oAuth.IsValidSessionAt(cTok, NOW), TRUE)
	Then("...it holds inference", oAuth.SessionCanAt(cTok, "inference", NOW), TRUE)
	Then("...yet it CANNOT cause effects (empty effect set)", oAuth.SessionIsEffectfulAt(cTok, NOW), FALSE)

	Given("a user with NO roles")
	oAuth.Register("plain", "pw")
	cP = oAuth.LoginAt("plain", "pw", NOW)
	Then("it is authenticated but permitted nothing (least privilege)", oAuth.ActorOfAt(cP, NOW).NumberOfKinds(), 0)
	Then("...and sandboxed by default", oAuth.ActorOfAt(cP, NOW).Posture(), "sandboxed")
EndScenario()

Scenario("an invalid session yields no actor")
	oAuth = new stzAuth()
	Then("ActorOf is NULL for a bogus token", oAuth.ActorOfAt("bogus", NOW) = NULL, TRUE)
	Then("...SessionCan is false", oAuth.SessionCanAt("bogus", "sensing", NOW), FALSE)
	Then("...SessionPerson is empty", oAuth.SessionPersonAt("bogus", NOW), "")
EndScenario()

Scenario("the SAME identity flows into the governance engine")
	oAuth = new stzAuth()
	oAuth.Register("dana", "pw")
	oAuth.GrantRole("dana", "admin")
	cTok = oAuth.LoginAt("dana", "pw", NOW)

	Given("a governance model that permits dana to delete accounts")
	oGov = new stzGovernance("acme")
	oGov.DeclareRisk("delete-account", 2)
	oGov.GrantPermission("dana", "delete-account")   # keyed by the SAME username
	oGov.SetAuthority("dana", "delegated")

	Then("SessionPerson is the governance actor name", oAuth.SessionPersonAt(cTok, NOW), "dana")
	Then("a live session + a governed permission proceeds", oAuth.SessionMayProceedAt(cTok, "delete-account", oGov, NOW), TRUE)
	Then("...an ungoverned action is refused", oAuth.SessionMayProceedAt(cTok, "wire-funds", oGov, NOW), FALSE)
	Then("...and an invalid session NEVER proceeds, whatever governance says", oAuth.SessionMayProceedAt("bogus", "delete-account", oGov, NOW), FALSE)
EndScenario()

Scenario("the authenticated user IS the org-chart person (separation-of-duties reasons about them)")
	oAuth = new stzAuth()
	oAuth.Register("dana", "pw")
	oAuth.GrantRole("dana", "member")
	cTok = oAuth.LoginAt("dana", "pw", NOW)

	Given("an org chart")
	oOrg = new stzOrgChart("acme")
	oOrg.AddPositionXT("approver", "Invoice Approver")

	When("the AUTHENTICATED identity is placed into the chart")
	oOrg.AddPersonXT(oAuth.SessionPersonAt(cTok, NOW), "Dana")
	oOrg.AssignPerson(oAuth.SessionPersonAt(cTok, NOW), "approver")
	Then("the org-chart person is the same string as the session's identity", oOrg.Person("dana")[:id], "dana")
	Then("...occupying the position", oOrg.Person("dana")[:position], "approver")
	# the existing org rules (separation-of-duties, no-cyclic-reporting) now reason
	# about this authenticated user with no glue -- the identity is the join.
EndScenario()

Scenario("roles are durable, and revoking one re-shapes the actor")
	if isString($cDb) and fexists($cDb)  remove($cDb)  ok
	oA1 = new stzAuth()
	oA1.SetStore(StzAuthDbStoreQ($cDb))
	oA1.Register("dana", "pw")
	oA1.GrantRole("dana", "admin")

	When("a separate stzAuth reads the same database")
	oA2 = new stzAuth()
	oA2.SetStore(StzAuthDbStoreQ($cDb))
	cTok = oA2.LoginAt("dana", "pw", NOW)
	Then("the grant persisted -- the actor is effectful", oA2.SessionIsEffectfulAt(cTok, NOW), TRUE)

	When("the admin role is revoked")
	oA2.RevokeRole("dana", "admin")
	Then("the SAME session is no longer effectful (authz is live)", oA2.SessionIsEffectfulAt(cTok, NOW), FALSE)
	if isString($cDb) and fexists($cDb)  remove($cDb)  ok
EndScenario()

Scenario("custom roles, and unregister clears grants")
	oAuth = new stzAuth()
	oAuth.DefineRole("auditor", [ "sensing", "compute" ], "external")
	Then("the custom role is defined", oAuth.HasRoleDefined("auditor"), TRUE)

	oAuth.Register("carol", "pw")
	oAuth.GrantRole("carol", "auditor")
	oActor = oAuth.ActorForUser("carol")
	Then("its actor carries the defined kinds", oActor.Can("sensing") and oActor.Can("compute"), TRUE)
	Then("...at the defined posture", oActor.Posture(), "external")
	Then("...and is not effectful", oActor.IsEffectful(), FALSE)

	When("the account is removed")
	oAuth.Unregister("carol")
	Then("its role grants are gone", len(oAuth.RolesOf("carol")), 0)
EndScenario()

Summary()
