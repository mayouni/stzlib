load "../../stzBase.ring"
load "../_narrated.ring"

# stzHttpPort -- phase 3 of the service-virtualization plane, and the plan calls it
# the highest-leverage category for a simple reason: almost every third-party
# dependency is an HTTP request and a response. Payments, shipping quotes,
# geocoding, CRM, weather, an LLM endpoint. So instead of a bespoke double per
# vendor, this is ONE double for the shape they share -- which makes the later
# categories configuration rather than new code.
#
# An HTTP port is "any object with Request(method, url, body)" returning
# [ :status, :body ]. Both sides ship: stzHttpSandbox (offline, deterministic) and
# stzReactorHttpClient (the real thing, over the reactor's curl-backed client).
#
# TWO SANDBOX MODES, because tests want different things:
#   SCRIPTED -- rules you write, so you can DRIVE behaviour. Make the gateway
#     decline. Make the API rate-limit you. You cannot ask a real vendor to fail
#     on demand, which is exactly why the negative path usually goes untested.
#   REPLAY -- what the real service actually said, kept and replayed. Call it once,
#     keep the answer forever. This generalises what stzLLMFunction's answer cache
#     already does for prompts.

Scenario("scripted: rules you write, first match winning")
	oSb = new stzHttpSandbox()
	oSb.ScriptQ("GET", "https://api.rates/v1", 200, '{"usd":1.09}')
	oSb.ScriptQ("GET", "https://api.rates/*", 404, "not found")
	Then("two rules are held", oSb.NumberOfScripts(), 2)

	aR = oSb.GetFrom("https://api.rates/v1")
	Then("the exact rule answers", aR[:status], 200)
	Then("...with its body", aR[:body], '{"usd":1.09}')
	Then("...marked as scripted", aR[:from], :scripted)

	Then("a later PREFIX rule catches everything else", oSb.GetFrom("https://api.rates/v9")[:status], 404)
	# order is meaningful: the general rule goes last.

	When("a contains-pattern is used (stars at both ends)")
	oSb.ScriptQ("POST", "*/charge*", 402, '{"error":"card declined"}')
	aD = oSb.PostTo("https://pay.example/v1/charge/99", "amount=500")
	Then("it matches mid-URL", aD[:status], 402)
	Then("...and this is a failure NO real vendor will produce on request",
	     StzFindFirst("declined", aD[:body]) > 0, TRUE)

	Then("the method is part of the match", oSb.WasCalled("POST", "https://pay.example/v1/charge/99"), TRUE)
EndScenario()

Scenario("STRICT by default -- a miss must not look like an answer")
	oSb = new stzHttpSandbox()
	oSb.ScriptQ("GET", "https://known", 200, "ok")
	Then("it is strict out of the box", oSb.IsStrict(), TRUE)

	bRaised = FALSE
	try
		oSb.GetFrom("https://forgotten.example")
	catch
		bRaised = TRUE
	done
	Then("an unscripted request RAISES", bRaised, TRUE)
	# a double that silently answers "" for something you forgot produces a test
	# that passes for the WRONG REASON -- the worst outcome available.

	When("strictness is turned off deliberately")
	oSb.SetStrictQ(FALSE)
	aM = oSb.GetFrom("https://forgotten.example")
	Then("a miss is reported as a miss", aM[:from], :miss)
	Then("...with a status that cannot be mistaken for success", aM[:status], 501)
EndScenario()

Scenario("replay: call the real thing once, keep what it said")
	# a stand-in "live" client -- any object with Request(method, url, body) -- so
	# the RECORDING path is testable with no network at all.
	oLive = new stzHttpSandbox()
	oLive.ScriptQ("GET", "https://api.geo/city", 200, '{"city":"Tunis"}')

	oSb = new stzHttpSandbox()
	Then("nothing is recorded yet", oSb.NumberOfRecordings(), 0)

	When("one real call is recorded")
	aRec = oSb.RecordFrom(oLive, "GET", "https://api.geo/city", "")
	Then("the live answer came back", aRec[:body], '{"city":"Tunis"}')
	Then("...and is now held", oSb.NumberOfRecordings(), 1)
	Then("...findable", oSb.HasRecording("GET", "https://api.geo/city", ""), TRUE)

	When("the same request is made again, offline")
	aP = oSb.GetFrom("https://api.geo/city")
	Then("it replays", aP[:from], :replay)
	Then("...identically", aP[:body], '{"city":"Tunis"}')

	Then("a recording is keyed by method+url+BODY, so a different body is a different recording",
	     oSb.HasRecording("POST", "https://api.geo/city", "q=1"), FALSE)
	Then("the key is a stable hash", len(oSb.RequestKey("GET", "https://api.geo/city", "")), 64)

	When("a script is added for a URL that is already recorded")
	oSb.ScriptQ("GET", "https://api.geo/city", 500, "scripted instead")
	Then("the RECORDING still wins", oSb.GetFrom("https://api.geo/city")[:from], :replay)
	# a recording is what the service really said; that beats a rule someone wrote.
EndScenario()

Scenario("the journal: assert on what the code TRIED to do")
	oSb = new stzHttpSandbox()
	oSb.ScriptQ("GET", "*", 200, "ok")

	oSb.GetFrom("https://api.example/a")
	oSb.GetFrom("https://api.example/b")
	oSb.GetFrom("https://api.example/a")

	Then("every request is journalled", oSb.NumberOfCalls(), 3)
	Then("the last one is inspectable", oSb.LastCall()[:url], "https://api.example/a")
	Then("...with its method", oSb.LastCall()[:method], "GET")
	Then("counting per URL catches a retry storm or an N+1", oSb.NumberOfCallsTo("https://api.example/a"), 2)
	Then("...and the one-off is still one", oSb.NumberOfCallsTo("https://api.example/b"), 1)
	Then("a URL never touched says so", oSb.WasCalled("GET", "https://api.example/z"), FALSE)

	When("the journal is cleared between phases of a test")
	oSb.ClearCallsQ()
	Then("it is empty", oSb.NumberOfCalls(), 0)
	Then("...but the scripts remain", oSb.NumberOfScripts(), 1)
EndScenario()

Scenario("through the registry -- including the Ring copy trap")
	oSb = new stzHttpSandbox()
	oSb.ScriptQ("GET", "*", 200, "ok")

	oReg = new stzServiceRegistry("app")
	oReg.Bind(:rates, oSb)
	Then("the registry detects the double from the object", oReg.PostureOf(:rates), :sandbox)

	When("the application uses the service the registry hands back")
	oReg.Service(:rates).GetFrom("https://through-the-registry")
	Then("the ORIGINAL sandbox saw the call", oSb.NumberOfCallsTo("https://through-the-registry"), 1)
	# Ring copies on `=` AND on list insertion, so the registry handed out a COPY.
	# A stateful double must therefore share state across copies -- the port
	# contract's requirement, met here with a handle table as stzMailSandbox does.

	When("the real client is bound alongside it")
	oReg.Bind(:live_http, new stzReactorHttpClient())
	Then("the reactor client is treated as LIVE, having no opinion", oReg.PostureOf(:live_http), :live)

	When("the phase becomes production with the fake still bound")
	oReg.SetPhaseQ(:production)
	Then("it is refused", oReg.IsSound(), FALSE)
	Then("...naming the fake, not the real client", oReg.Findings()[1][:where], "app/rates")
EndScenario()

Scenario("the live adapter exists, and is honest about what it cannot do")
	oCli = new stzReactorHttpClient()
	Then("it has a timeout", oCli.Timeout() > 0, TRUE)
	oCli.SetTimeoutQ(2000)
	Then("...which is settable", oCli.Timeout(), 2000)
	Then("it satisfies the same port shape as the sandbox", isObject(oCli.ReactorQ()), TRUE)
	# The reactor's client returns a BODY and no status line, so this adapter
	# reports 200 on content and 0 on nothing. That is enough to record and replay;
	# a status-aware adapter (headers, redirects, non-2xx bodies) is a richer thing
	# to bind behind the same three arguments -- which is what a port is FOR.
EndScenario()

Summary()
