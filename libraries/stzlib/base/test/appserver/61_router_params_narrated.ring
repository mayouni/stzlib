load "../../stzBase.ring"
load "../_narrated.ring"

# R7 finish -- the app-server router grows PATH PARAMS and WILDCARDS.
# Exact routes still win first; :name captures a segment; a trailing *
# captures the rest. Params are bound onto the request (Param(name)).
# Handlers are named global funcs reading prerendered state (Ring
# lambdas cannot capture) -- here they echo the bound params so the
# offline client can assert them.

$CRLF = char(13) + char(10)

$oSrv = new stzAppServer()
$oSrv.Get_("/user/:id", "RouteUser")
$oSrv.Get_("/files/:a/:b", "RouteTwo")
$oSrv.Get_("/static/*", "RouteStar")
$oSrv.Get_("/user/me", "RouteExact")     # exact must beat /user/:id
$oSrv.Start(0, "127.0.0.1")
$oClient = new stzReactor()

Scenario("a single path param is captured")
	When("GET /user/42")
	Then("the handler saw id=42", GetPath("/user/42"), "user:42")
EndScenario()

Scenario("an exact route beats the param route")
	When("GET /user/me")
	Then("the exact handler answered", GetPath("/user/me"), "exact-me")
EndScenario()

Scenario("multiple params are captured in order")
	When("GET /files/report/2026")
	Then("both params bound", GetPath("/files/report/2026"), "a=report;b=2026")
EndScenario()

Scenario("a trailing wildcard captures the rest of the path")
	When("GET /static/css/app.css")
	Then("the wildcard captured the tail", GetPath("/static/css/app.css"), "star:css/app.css")
EndScenario()

Scenario("a non-matching path is an honest 404")
	When("GET /nope/here")
	cBody = GetRaw("/nope/here")
	Then("the client got a 404", StzFindFirst(cBody, "404 Not Found") > 0, TRUE)
EndScenario()

Scenario("teardown")
	$oClient.Destroy()
	$oSrv.Stop()
	Then("stopped cleanly", TRUE, TRUE)
EndScenario()

Summary()


# -- helpers (after all top-level code; Ring hoists func defs) --------

func RouteUser(oReq, oResp)
	oResp.Text("user:" + oReq.Param("id"))

func RouteExact(oReq, oResp)
	oResp.Text("exact-me")

func RouteTwo(oReq, oResp)
	oResp.Text("a=" + oReq.Param("a") + ";b=" + oReq.Param("b"))

func RouteStar(oReq, oResp)
	oResp.Text("star:" + oReq.Param("*"))

# issue GET cPath, serve one event, return the response BODY (after the
# blank line); GetRaw returns the whole response.
func GetRaw(cPath)
	cReq = "GET " + cPath + " HTTP/1.1" + $CRLF + "Host: local" + $CRLF +
	       "Connection: close" + $CRLF + $CRLF
	nJob = $oClient.SubmitTcp("127.0.0.1", $oSrv.Port(), cReq)
	$oSrv.ServeOne(3000)
	return $oClient.AwaitTcp(nJob, 5000)

func GetPath(cPath)
	cRaw = GetRaw(cPath)
	nHe = StzFindFirst(cRaw, $CRLF + $CRLF)
	if nHe = 0  return ""  ok
	return StzMidToEnd(cRaw, nHe + 4)
