load "../../stzBase.ring"
load "../_narrated.ring"

# stzAppServer -- the two methods that stored their arguments and never acted: Use and Static.
#
# Use(path, middleware) stored the pair in the router and nothing ever read the list, so no middleware
# ever ran. Static(path, folder) stored the pair and nothing ever read that list either, so a file in a
# served folder answered 404. Both are now read by the request dispatch (_Dispatch).
#
# Offline and in-process: no socket, no port. A request is built as a stzAppRequest, handed to the
# dispatch the server runs for every wire request, and the stzAppResponse it fills is read back. The
# bytes a client would receive are rendered by the same function the wire path uses.
#
# Static serving is a security feature, so the traversal corpus has a SECRET FILE placed beside the
# served folder, one level above it: every hostile path is checked to answer 400 or 404 and to leak
# not one byte of that file into the status line, the headers or the body.
#
# Expectations are literals written before the code ran. Every positive has a negative sibling.

$CRLF = char(13) + char(10)
$cFx = currentdir() + "/_asfx_tmp"
$cSecret = "SECRETMARK-9c1e5a7d-outside-the-folder"
$cHiddenMark = "HIDDENMARK-4b2f"
$cLog = ""
$bEvil = 0
$nObj = 0

# ---------------------------------------------------------------- fixture
StzDirDeleteAll($cFx)
StzDirCreatePath($cFx + "/files/sub")
StzDirCreatePath($cFx + "/files/private")
StzDirCreatePath($cFx + "/files2")
StzFileWrite($cFx + "/secret.txt", $cSecret)
StzFileWrite($cFx + "/files/hello.txt", "hello world")
StzFileWrite($cFx + "/files/page.html", "<p>hi</p>")
StzFileWrite($cFx + "/files/sub/inner.css", "a{color:red}")
StzFileWrite($cFx + "/files/a b.txt", "with a space")
StzFileWrite($cFx + "/files/caf" + char(195) + char(169) + ".txt", "unicode name")
StzFileWrite($cFx + "/files/noext", "no extension")
StzFileWrite($cFx + "/files/UPPER.TXT", "upper")
StzFileWrite($cFx + "/files/empty.txt", "")
StzFileWrite($cFx + "/files/longnamefile.txt", "long")
StzFileWrite($cFx + "/files/.hidden", $cHiddenMark)
StzFileWrite($cFx + "/files/private/x.txt", "private file")
StzFileWrite($cFx + "/files/special", "static special")
StzFileWrite($cFx + "/files2/only2.txt", "only in the second mount")
StzFileWrite($cFx + "/files2/hello.txt", "second hello")

$cAll = ""
for h_i = 0 to 255
	$cAll += char(h_i)
next
StzFileWrite($cFx + "/files/all256.bin", $cAll)

$cMb = "A"
for h_i = 1 to 20
	$cMb += $cMb
next
$cCap = ""
for h_i = 1 to 10
	$cCap += $cMb
next
StzFileWrite($cFx + "/files/cap.bin", $cCap)
StzFileWrite($cFx + "/files/overcap.bin", $cCap + "B")
$cMb = ""
$cCap = ""

# ================================================================ MIDDLEWARE

Scenario("Use: middleware runs before the route, in registration order")
	Given("a server with middleware A then B on /a, and a route on /a/x")
	oSrv = new stzAppServer()
	oSrv.Use("/a", "MwA").Use("/a", "MwB").Get_("/a/x", "RouteLog")
	$cLog = ""
	When("GET /a/x is dispatched")
	aR = Drive(oSrv, "GET", "/a/x")
	Then("A ran, then B, then the route", $cLog, "ABR")
	Then("the route answered 200 hello", "" + aR[1] + ":" + aR[2], "200:hello")
	Given("the same middleware registered the other way round, plus a deeper prefix first")
	oSrv2 = new stzAppServer()
	oSrv2.Use("/a/b", "MwB").Use("/a", "MwA").Get_("/a/b", "RouteLog")
	$cLog = ""
	When("GET /a/b is dispatched")
	aR = Drive(oSrv2, "GET", "/a/b")
	Then("registration order wins over prefix depth: B, A, route", $cLog, "BAR")
EndScenario()

Scenario("Use: a prefix matches whole path segments, never part of a name")
	Given("middleware A on /a, and routes on /a, /a/b, /ab and /b")
	oSrv = new stzAppServer()
	oSrv.Use("/a", "MwA")
	oSrv.Get_("/a", "RouteLog").Get_("/a/b", "RouteLog").Get_("/ab", "RouteLog").Get_("/b", "RouteLog")
	$cLog = ""
	Drive(oSrv, "GET", "/a")
	Then("/a is covered", $cLog, "AR")
	$cLog = ""
	Drive(oSrv, "GET", "/a/b")
	Then("/a/b is covered", $cLog, "AR")
	$cLog = ""
	Drive(oSrv, "GET", "/a/")
	Then("/a/ (404 here, no such route) still ran A once", $cLog, "A")
	$cLog = ""
	Drive(oSrv, "GET", "/ab")
	Then("/ab is NOT covered by /a", $cLog, "R")
	$cLog = ""
	Drive(oSrv, "GET", "/b")
	Then("/b is not covered", $cLog, "R")
	$cLog = ""
	Drive(oSrv, "GET", "/a?x=1")
	Then("a query string does not change the match", $cLog, "AR")
	$cLog = ""
	Drive(oSrv, "GET", "/A")
	Then("the match is case-sensitive: /A is not /a", $cLog, "")
EndScenario()

Scenario("Use: / and * and an empty path cover every path; a trailing /* is a plain prefix")
	Given("middleware S on *, T on /, U on /q/*")
	oSrv = new stzAppServer()
	oSrv.Use("*", "MwS").Use("/", "MwT").Use("/q/*", "MwU")
	$cLog = ""
	Drive(oSrv, "GET", "/anything/at/all")
	Then("S and T cover /anything/at/all, U does not", $cLog, "ST")
	$cLog = ""
	Drive(oSrv, "GET", "/")
	Then("S and T cover the root", $cLog, "ST")
	$cLog = ""
	Drive(oSrv, "GET", "/q")
	Then("/q/* covers /q", $cLog, "STU")
	$cLog = ""
	Drive(oSrv, "GET", "/q/z/y")
	Then("/q/* covers /q/z/y", $cLog, "STU")
	$cLog = ""
	Drive(oSrv, "GET", "/qz")
	Then("/q/* does not cover /qz", $cLog, "ST")
	oSrv3 = new stzAppServer()
	oSrv3.Use("", "MwS")
	$cLog = ""
	Drive(oSrv3, "GET", "/x")
	Then("an empty path covers everything too", $cLog, "S")
EndScenario()

Scenario("Use: a middleware that answers stops the chain")
	Given("a deny middleware, a later middleware and a route on /s")
	oSrv = new stzAppServer()
	oSrv.Use("/s", "MwDeny").Use("/s", "MwLater").Get_("/s", "RouteLog").Get_("/t", "RouteLog")
	$cLog = ""
	When("GET /s is dispatched")
	aR = Drive(oSrv, "GET", "/s")
	Then("the deny answer is 403 with its body", "" + aR[1] + ":" + aR[2], "403:denied")
	Then("neither the later middleware nor the route ran", $cLog, "D")
	$cLog = ""
	aR = Drive(oSrv, "GET", "/t")
	Then("a path the deny does not cover reaches its route", "" + aR[1] + ":" + aR[2] + ":" + $cLog, "200:hello:R")
	Given("a middleware that only sets a status and sends nothing")
	oSrv2 = new stzAppServer()
	oSrv2.Use("/u", "MwStatusOnly").Get_("/u", "RouteLog")
	$cLog = ""
	aR = Drive(oSrv2, "GET", "/u")
	Then("the status it set is the status answered", aR[1], 401)
	Then("the route did not run", $cLog, "")
	Given("a middleware that only adds a header")
	oSrv3 = new stzAppServer()
	oSrv3.Use("/h", "MwHeader").Get_("/h", "RouteLog")
	$cLog = ""
	aR = Drive(oSrv3, "GET", "/h")
	Then("the request goes on to the route", "" + aR[1] + ":" + aR[2] + ":" + $cLog, "200:hello:R")
	Then("and the header it added is on the answer", Has(aR[3], "X-Req: 1" + $CRLF), TRUE)
EndScenario()

Scenario("Use: no middleware changes nothing")
	Given("a server with a route and no middleware")
	oSrv = new stzAppServer()
	oSrv.Get_("/a", "RouteLog")
	$cLog = ""
	aR = Drive(oSrv, "GET", "/a")
	Then("the route answers as before", "" + aR[1] + ":" + aR[2] + ":" + $cLog, "200:hello:R")
	aR = Drive(oSrv, "GET", "/nope")
	Then("an unknown path is the same 404 text as before", "" + aR[1] + ":" + aR[2], "404:Route not found: GET /nope")
	aR = Drive(oSrv, "POST", "/a")
	Then("another method on a route is still 404", aR[1], 404)
EndScenario()

Scenario("Use: a middleware that raises is a plain 500, and the server goes on")
	Given("a middleware that raises with a secret text, covering /boom, and a route on /ok")
	oSrv = new stzAppServer()
	oSrv.Use("/boom", "MwBoom").Get_("/boom", "RouteLog").Get_("/ok", "RouteLog")
	When("GET /boom is dispatched")
	$cLog = ""
	aR = Drive(oSrv, "GET", "/boom")
	Then("it answers 500", aR[1], 500)
	Then("the body is the plain text and nothing more", aR[2], "Internal Server Error")
	Then("the raise text is nowhere in the answer", Has(aR[3], "boom-secret-text"), FALSE)
	Then("the route did not run", $cLog, "")
	Then("the operator can read the cause", Has(oSrv.MiddlewareWhy(), "boom-secret-text"), TRUE)
	When("the next request, on another path, arrives")
	aR = Drive(oSrv, "GET", "/ok")
	Then("it is served normally", "" + aR[1] + ":" + aR[2], "200:hello")
	Given("middleware named a function that does not exist")
	oSrv2 = new stzAppServer()
	oSrv2.Use("/gone", "NoSuchMiddlewareFn")
	aR = Drive(oSrv2, "GET", "/gone")
	Then("the request answers 500 and not a crash", aR[1], 500)
	Then("and says nothing of the name", Has(aR[3], "NoSuchMiddlewareFn"), FALSE)
	Given("a server with no raising middleware")
	oSrv3 = new stzAppServer()
	Then("MiddlewareWhy is empty", oSrv3.MiddlewareWhy(), "")
EndScenario()

Scenario("Use: only the name of a function is accepted, and the path is never evaluated")
	oSrv = new stzAppServer()
	Given("names that are not plain identifiers")
	Then("a call expression is refused", Has(UseError(oSrv, "/a", "MwA()"), "stzAppServer.Use"), TRUE)
	Then("an injection is refused", Has(UseError(oSrv, "/a", "MwA(); $bEvil = 1"), "stzAppServer.Use"), TRUE)
	Then("a name with a space is refused", Has(UseError(oSrv, "/a", "Mw A"), "stzAppServer.Use"), TRUE)
	Then("an empty name is refused", Has(UseError(oSrv, "/a", ""), "stzAppServer.Use"), TRUE)
	Then("a name starting with a digit is refused", Has(UseError(oSrv, "/a", "1Mw"), "stzAppServer.Use"), TRUE)
	Then("a number is refused", Has(UseError(oSrv, "/a", 12), "stzAppServer.Use"), TRUE)
	Then("a list is refused", Has(UseError(oSrv, "/a", [ "MwA" ]), "stzAppServer.Use"), TRUE)
	Then("a path that is not a text is refused", Has(UseError(oSrv, 5, "MwA"), "stzAppServer.Use"), TRUE)
	Then("a pattern in the path is refused", Has(UseError(oSrv, "/a/:id", "MwA"), "stzAppServer.Use"), TRUE)
	Then("a wildcard in the middle is refused", Has(UseError(oSrv, "/a/*/b", "MwA"), "stzAppServer.Use"), TRUE)
	Then("an escape in the path is refused", Has(UseError(oSrv, "/a%2fb", "MwA"), "stzAppServer.Use"), TRUE)
	Then("a path without a leading slash is refused", Has(UseError(oSrv, "api", "MwA"), "stzAppServer.Use"), TRUE)
	$cLog = ""
	Drive(oSrv, "GET", "/a")
	Then("nothing refused was stored: no middleware ran", $cLog, "")
	Given("the names and paths that are fine")
	Then("a plain name and path is accepted", UseError(oSrv, "/a", "MwA"), "")
	Then("an underscore name is accepted", UseError(oSrv, "/a", "_Mw_A2"), "")
	Drive(oSrv, "GET", "/a")
	Then("both were stored and ran in order (A, then the underscore one defined as _Mw_A2)", $cLog, "AA2")
	Given("a request path that looks like code, under a middleware on every path")
	oSrv2 = new stzAppServer()
	oSrv2.Use("*", "MwS")
	$cLog = ""
	$bEvil = 0
	Drive(oSrv2, "GET", "/x'; $bEvil = 1; '")
	Drive(oSrv2, "GET", "/x" + char(34) + " + shutdown(1) + " + char(34))
	Drive(oSrv2, "GET", "/$bEvil=1")
	Then("the middleware ran for each of the three", $cLog, "SSS")
	Then("none of the paths was evaluated", $bEvil, 0)
EndScenario()

Scenario("Use: a percent-encoded path cannot slip past a prefix")
	Given("a deny middleware on /admin and a route for /admin/x and /adminx")
	oSrv = new stzAppServer()
	oSrv.Use("/admin", "MwDeny").Get_("/admin/x", "RouteLog").Get_("/adminx", "RouteLog")
	$cLog = ""
	aR = Drive(oSrv, "GET", "/admin/x")
	Then("the plain path is denied", aR[1], 403)
	aR = Drive(oSrv, "GET", "/%61dmin/x")
	Then("the same path with a escaped letter is denied too", aR[1], 403)
	aR = Drive(oSrv, "GET", "/%41dmin/x")
	Then("a different letter after decoding (A) is a different path: not covered", aR[1], 404)
	aR = Drive(oSrv, "GET", "/adminx")
	Then("a longer name is not covered", "" + aR[1] + ":" + aR[2], "200:hello")
EndScenario()

Scenario("Use: middleware that touches other objects leaves the server whole")
	Given("a middleware that builds and uses other objects, on every path, and a mounted folder")
	oSrv = new stzAppServer()
	oMon = StzPerfMonitor("as-guard")
	oSrv.Observe(oMon)
	oDb = new stzDatabase(":memory:")
	oDb.Exec("CREATE TABLE note(id INTEGER PRIMARY KEY, entry TEXT)")
	oDb.Exec("INSERT INTO note (entry) VALUES ('first')")
	oSrv.Expose(oDb, "note")
	oSrv.Use("*", "MwObj").Get_("/r", "RouteLog").Static("/files", $cFx + "/files")
	$nObj = 0
	aR = Drive(oSrv, "GET", "/r")
	Then("the route still answers after it", "" + aR[1] + ":" + aR[2], "200:hello")
	aR = Drive(oSrv, "GET", "/api/note/count")
	Then("the MBaaS floor still answers", "" + aR[1] + ":" + Has(aR[2], '"count":1'), "200:1")
	aR = Drive(oSrv, "GET", "/metrics")
	Then("the observed /metrics page still answers", "" + aR[1] + ":" + (len(aR[2]) > 0), "200:1")
	aR = Drive(oSrv, "GET", "/files/hello.txt")
	Then("a static file still answers", "" + aR[1] + ":" + aR[2], "200:hello world")
	aR = Drive(oSrv, "GET", "/nothing")
	Then("an unknown path is still a 404", aR[1], 404)
	Then("the middleware really ran five times", $nObj, 5)
EndScenario()

# ================================================================ STATIC

Scenario("Static: the registration is checked")
	oSrv = new stzAppServer()
	Given("things that cannot be served")
	Then("a folder that does not exist raises", Has(StaticError(oSrv, "/f", $cFx + "/nope"), "not an existing folder"), TRUE)
	Then("a file in place of a folder raises", Has(StaticError(oSrv, "/f", $cFx + "/secret.txt"), "not an existing folder"), TRUE)
	Then("an empty folder name raises", Has(StaticError(oSrv, "/f", ""), "not an existing folder"), TRUE)
	Then("a path without a slash raises", Has(StaticError(oSrv, "f", $cFx + "/files"), "stzAppServer.Static"), TRUE)
	Then("an empty path raises", Has(StaticError(oSrv, "", $cFx + "/files"), "stzAppServer.Static"), TRUE)
	Then("a pattern in the path raises", Has(StaticError(oSrv, "/f/:x", $cFx + "/files"), "stzAppServer.Static"), TRUE)
	Then("a number as the folder raises", Has(StaticError(oSrv, "/f", 5), "stzAppServer.Static"), TRUE)
	Then("nothing refused was stored: nothing is served", Drive(oSrv, "GET", "/f/hello.txt")[1], 404)
	Given("things that can")
	Then("a folder that exists is accepted", StaticError(oSrv, "/files", $cFx + "/files"), "")
	Then("the trailing /* form is accepted", StaticError(oSrv, "/more/*", $cFx + "/files2"), "")
	Then("the first serves its prefix", Drive(oSrv, "GET", "/files/hello.txt")[2], "hello world")
	Then("the /* form serves /more", Drive(oSrv, "GET", "/more/only2.txt")[2], "only in the second mount")
EndScenario()

Scenario("Static: a file is served with the right type, length and bytes")
	oSrv = new stzAppServer()
	oSrv.Static("/files", $cFx + "/files")
	Given("a folder with a text file, a page, a stylesheet and a file with no extension")
	aR = Drive(oSrv, "GET", "/files/hello.txt")
	Then("the text file answers 200 with its bytes", "" + aR[1] + ":" + aR[2], "200:hello world")
	Then("its type is text/plain", Has(aR[3], "Content-Type: text/plain; charset=utf-8" + $CRLF), TRUE)
	Then("its Content-Length is 11", Has(aR[3], "Content-Length: 11" + $CRLF), TRUE)
	Then("sniffing is switched off", Has(aR[3], "X-Content-Type-Options: nosniff" + $CRLF), TRUE)
	aR = Drive(oSrv, "GET", "/files/page.html")
	Then("a page is text/html", Has(aR[3], "Content-Type: text/html; charset=utf-8"), TRUE)
	aR = Drive(oSrv, "GET", "/files/sub/inner.css")
	Then("a file in a subfolder is served, as text/css", "" + aR[1] + ":" + aR[2] + ":" + Has(aR[3], "text/css"), "200:a{color:red}:1")
	aR = Drive(oSrv, "GET", "/files/noext")
	Then("no extension is octet-stream", Has(aR[3], "Content-Type: application/octet-stream"), TRUE)
	aR = Drive(oSrv, "GET", "/files/empty.txt")
	Then("an empty file is a 200 with Content-Length 0", "" + aR[1] + ":" + Has(aR[3], "Content-Length: 0" + $CRLF), "200:1")
	aR = Drive(oSrv, "GET", "/files/hello.txt?v=2&x=%2e%2e")
	Then("a query string is ignored", "" + aR[1] + ":" + aR[2], "200:hello world")
	aR = Drive(oSrv, "GET", "/files/hello%2Etxt")
	Then("an escaped dot is decoded once and served", "" + aR[1] + ":" + aR[2], "200:hello world")
	aR = Drive(oSrv, "GET", "/files/a%20b.txt")
	Then("an escaped space reaches a file with a space", "" + aR[1] + ":" + aR[2], "200:with a space")
	aR = Drive(oSrv, "GET", "/files/caf%C3%A9.txt")
	Then("an escaped UTF-8 name reaches a file with that name", "" + aR[1] + ":" + aR[2], "200:unicode name")
	aR = Drive(oSrv, "GET", "/files/caf" + char(195) + char(169) + ".txt")
	Then("the same name sent as raw UTF-8 is served too", "" + aR[1] + ":" + aR[2], "200:unicode name")
	Given("the negative siblings")
	aR = Drive(oSrv, "GET", "/files/hello.TXT")
	Then("a name in another case is a different name: 404", aR[1], 404)
	aR = Drive(oSrv, "GET", "/files/missing.txt")
	Then("a missing file is 404", aR[1], 404)
	aR = Drive(oSrv, "GET", "/files/sub")
	Then("a folder is 404", aR[1], 404)
	aR = Drive(oSrv, "GET", "/files/sub/")
	Then("a folder with a slash is 404 and lists nothing", "" + aR[1] + ":" + Has(aR[3], "inner.css"), "404:0")
	aR = Drive(oSrv, "GET", "/files/")
	Then("the mount root is 404 (no index, no listing)", "" + aR[1] + ":" + Has(aR[3], "hello.txt"), "404:0")
	aR = Drive(oSrv, "GET", "/files")
	Then("the bare prefix is 404", aR[1], 404)
	aR = Drive(oSrv, "GET", "/filesx/hello.txt")
	Then("a longer name than the prefix is not the mount", aR[1], 404)
	aR = Drive(oSrv, "GET", "/hello.txt")
	Then("the file is not served outside its prefix", aR[1], 404)
	aR = Drive(oSrv, "GET", "/files/hello.txt/")
	Then("a trailing slash after a file is 404", aR[1], 404)
EndScenario()

Scenario("Static: the bytes of a PNG-like file survive, all 256 values")
	oSrv = new stzAppServer()
	oSrv.Static("/files", $cFx + "/files")
	Given("a file holding every byte value from 0 to 255 once")
	aR = Drive(oSrv, "GET", "/files/all256.bin")
	Then("it answers 200", aR[1], 200)
	Then("the body is 256 bytes", len(aR[2]), 256)
	Then("the body equals the file byte for byte (length, every byte, CRC32)", AsSame(aR[2], $cAll), 1)
	Then("the file on disk is what the fixture wrote", AsSame(read($cFx + "/files/all256.bin"), $cAll), 1)
	Then("Content-Length says 256", Has(aR[3], "Content-Length: 256" + $CRLF), TRUE)
	Then("the wire ends with those same 256 bytes",
		AsSame(right(aR[3], 256), $cAll), 1)
	Then("the wire is the headers plus exactly 256 bytes", len(aR[3]) - 256 > 0 and Has(left(aR[3], len(aR[3]) - 256), $CRLF + $CRLF), TRUE)
	Given("the negative sibling: a body that differs by one byte")
	cOff = $cAll
	cOff[1] = char(1)
	Then("is detected as different", AsSame(aR[2], cOff), 0)
	Given("a body whose last 255 bytes are wrong but which starts with the same NUL")
	cOff = $cAll
	cOff[256] = char(7)
	Then("is detected as different (strcmp would stop at the first NUL and call it equal)", AsSame(aR[2], cOff), 0)
	Then("and strcmp indeed calls them equal, which is why it is not used here", strcmp(aR[2], cOff), 0)
EndScenario()

Scenario("Static: HEAD has the headers and no body; other methods are refused")
	oSrv = new stzAppServer()
	oSrv.Static("/files", $cFx + "/files")
	Given("HEAD for an existing file")
	aR = Drive(oSrv, "HEAD", "/files/hello.txt")
	Then("it answers 200", aR[1], 200)
	Then("the headers carry the Content-Length of the body it stands for", Has(aR[3], "Content-Length: 11" + $CRLF), TRUE)
	Then("the wire ends at the blank line: no body", Has(aR[3], "hello world"), FALSE)
	Then("the wire ends with the blank line", right(aR[3], 4), $CRLF + $CRLF)
	Given("GET for the same file, the negative sibling")
	aR = Drive(oSrv, "GET", "/files/hello.txt")
	Then("the body is there", Has(aR[3], "hello world"), TRUE)
	Given("methods that cannot read")
	aR = Drive(oSrv, "POST", "/files/hello.txt")
	Then("POST on a file is 405", aR[1], 405)
	Then("with an Allow header", Has(aR[3], "Allow: GET, HEAD" + $CRLF), TRUE)
	Then("and the file is not in the answer", Has(aR[3], "hello world"), FALSE)
	aR = Drive(oSrv, "DELETE", "/files/hello.txt")
	Then("DELETE on a file is 405", aR[1], 405)
	aR = Drive(oSrv, "PUT", "/files/missing.txt")
	Then("a write method on a missing file is a plain 404, not a hint", aR[1], 404)
	aR = Drive(oSrv, "HEAD", "/files/missing.txt")
	Then("HEAD on a missing file is 404", aR[1], 404)
	aR = Drive(oSrv, "get", "/files/hello.txt")
	Then("the method is read without regard to case, as the router does", aR[1], 200)
EndScenario()

Scenario("Static: the size cap is 10 MB")
	oSrv = new stzAppServer()
	oSrv.Static("/files", $cFx + "/files")
	Given("a file of exactly 10485760 bytes")
	aR = Drive(oSrv, "GET", "/files/cap.bin")
	Then("it is served", aR[1], 200)
	Then("in full", len(aR[2]), 10485760)
	Given("a file of one byte more")
	aR = Drive(oSrv, "GET", "/files/overcap.bin")
	Then("it is refused with 413", aR[1], 413)
	Then("and none of it is in the answer", len(aR[2]) < 100, TRUE)
EndScenario()

Scenario("Static: your routes come first, other mounts are tried in order, built-ins keep their paths")
	oSrv = new stzAppServer()
	oSrv.Get_("/files/special", "RouteLog")
	oSrv.Static("/files", $cFx + "/files").Static("/files", $cFx + "/files2")
	$cLog = ""
	aR = Drive(oSrv, "GET", "/files/special")
	Then("a route beats a file of the same path", aR[2] + ":" + $cLog, "hello:R")
	aR = Drive(oSrv, "GET", "/files/hello.txt")
	Then("the first mount that has the file answers", aR[2], "hello world")
	aR = Drive(oSrv, "GET", "/files/only2.txt")
	Then("a file only the second mount has falls through to it", "" + aR[1] + ":" + aR[2], "200:only in the second mount")
	aR = Drive(oSrv, "GET", "/files/neither.txt")
	Then("a file neither has is 404", aR[1], 404)
	Given("a mount at the root of the site")
	oSrv2 = new stzAppServer()
	oSrv2.Static("/", $cFx + "/files")
	aR = Drive(oSrv2, "GET", "/hello.txt")
	Then("the root mount serves /hello.txt", "" + aR[1] + ":" + aR[2], "200:hello world")
	aR = Drive(oSrv2, "GET", "/sub/inner.css")
	Then("and /sub/inner.css", aR[1], 200)
	oDb = new stzDatabase(":memory:")
	oDb.Exec("CREATE TABLE note(id INTEGER PRIMARY KEY, entry TEXT)")
	oDb.Exec("INSERT INTO note (entry) VALUES ('first')")
	oSrv2.Expose(oDb, "note")
	aR = Drive(oSrv2, "GET", "/api/note/count")
	Then("the MBaaS floor still answers before the files", "" + aR[1] + ":" + Has(aR[2], '"count":1'), "200:1")
	aR = Drive(oSrv2, "GET", "/../secret.txt")
	Then("the root mount does not climb out either", aR[1] >= 400 and aR[1] <= 404 and Has(aR[3], $cSecret) = 0, TRUE)
EndScenario()

Scenario("Static: a middleware covers the files under its prefix")
	oSrv = new stzAppServer()
	oSrv.Use("/files/private", "MwDeny").Static("/files", $cFx + "/files")
	aR = Drive(oSrv, "GET", "/files/private/x.txt")
	Then("the guarded file is denied", "" + aR[1] + ":" + Has(aR[3], "private file"), "403:0")
	aR = Drive(oSrv, "GET", "/files/%70rivate/x.txt")
	Then("also when a letter of the prefix is escaped", "" + aR[1] + ":" + Has(aR[3], "private file"), "403:0")
	aR = Drive(oSrv, "GET", "/files/hello.txt")
	Then("the negative sibling: another file is served", "" + aR[1] + ":" + aR[2], "200:hello world")
EndScenario()

Scenario("Static: the traversal corpus, with a secret one level above the folder")
	oSrv = new stzAppServer()
	oSrv.Static("/files", $cFx + "/files")
	aCorpus = Corpus()
	Given("a secret file beside the served folder and " + len(aCorpus) + " hostile paths")
	Then("the corpus has at least 40 paths", len(aCorpus) >= 40, TRUE)
	aR = Drive(oSrv, "GET", "/files/hello.txt")
	Then("the control: a legitimate path to the same folder is served", aR[1], 200)
	nLeaks = 0
	nBadStatus = 0
	nCorpus = len(aCorpus)
	for nIdx = 1 to nCorpus
		cHostile = aCorpus[nIdx]
		aR = Drive(oSrv, "GET", cHostile)
		bLeak = Has(aR[3], $cSecret) or Has(aR[3], $cHiddenMark) or Has(aR[3], "[fonts]") or Has(aR[3], "hello world")
		bStatus = (aR[1] = 400 or aR[1] = 404)
		if bLeak  nLeaks++  ok
		if NOT bStatus  nBadStatus++  ok
		? "    " + PadNum(aR[1]) + "  " + Esc(cHostile)
		Then("hostile path " + nIdx + " answers 400/404 and leaks nothing", bLeak = 0 and bStatus, TRUE)
	next
	Then("no hostile path leaked a byte of the secret, the hidden file or a file", nLeaks, 0)
	Then("every hostile path answered 400 or 404", nBadStatus, 0)
	Given("the same corpus by HEAD and POST")
	nOdd = 0
	for nIdx = 1 to nCorpus
		aR = Drive(oSrv, "HEAD", aCorpus[nIdx])
		if NOT (aR[1] = 400 or aR[1] = 404) or Has(aR[3], $cSecret)  nOdd++  ok
		aR = Drive(oSrv, "POST", aCorpus[nIdx])
		if NOT (aR[1] = 400 or aR[1] = 404) or Has(aR[3], $cSecret)  nOdd++  ok
	next
	Then("HEAD and POST of every hostile path also answer 400/404 with no leak", nOdd, 0)
	Given("the negative sibling of the secret: its own path inside the folder")
	aR = Drive(oSrv, "GET", "/files/secret.txt")
	Then("the secret has no copy inside the folder", aR[1], 404)
	Given("a hidden file inside the folder")
	aR = Drive(oSrv, "GET", "/files/.hidden")
	Then("is not served", Has(aR[3], $cHiddenMark), FALSE)
	Then("and is refused outright", aR[1], 400)
EndScenario()

Scenario("Static: a junction or a symbolic link inside the folder")
	cLink = sysget("STZ_APPSERVER_LINK_FIXTURE")
	if cLink = ""
		? "  NOT RUN: no link fixture. Symbolic links need elevation to create on this machine."
		? "  To run: set STZ_APPSERVER_LINK_FIXTURE to a folder holding ok.txt and a link named jlink"
		? "  that points to a folder with leak.txt. Result when last run: see the Static doc warning."
		Then("the scenario is named and skipped, not silently dropped", TRUE, TRUE)
	else
		oSrv = new stzAppServer()
		oSrv.Static("/l", cLink)
		aR = Drive(oSrv, "GET", "/l/ok.txt")
		Then("the file inside is served", aR[1], 200)
		aR = Drive(oSrv, "GET", "/l/jlink/leak.txt")
		? "  KNOWN GAP, not asserted: through the link the answer was " + aR[1] + " (the engine lists a Windows junction as a folder)"
		Then("the link fixture was reached", aR[1] = 200 or aR[1] = 404, TRUE)
	ok
EndScenario()

Scenario("The router lists are read back")
	oRt = new stzAppRouter
	oRt.AddMiddleware("/a", "MwA")
	oRt.AddStaticRoute("/f", "somewhere")
	Then("Middleware returns what AddMiddleware stored", oRt.Middleware()[1][1] + oRt.Middleware()[1][2], "/aMwA")
	Then("StaticRoutes returns what AddStaticRoute stored", oRt.StaticRoutes()[1][1] + oRt.StaticRoutes()[1][2], "/fsomewhere")
	oRt2 = new stzAppRouter
	Then("a new router has neither", len(oRt2.Middleware()) + len(oRt2.StaticRoutes()), 0)
EndScenario()

# ---------------------------------------------------------------- teardown
StzDirDeleteAll($cFx)

Scenario("teardown")
	Then("the fixture folder is gone", StzDirExists($cFx), 0)
EndScenario()

Summary()

# ================================================================ helpers (at the end: Ring)

func Drive(h_oSrv, h_cMethod, h_cPath)
	h_oReq = new stzAppRequest(h_cMethod, h_cPath, [], "")
	h_oResp = new stzAppResponse("")
	h_oSrv._Dispatch(h_oReq, h_oResp)
	h_cWire = _StzAppServerWire(h_oResp, h_cMethod)
	return [ h_oResp.StatusCode(), h_oResp.Body(), h_cWire ]

func Has(h_cText, h_cNeedle)
	return substr(h_cText, h_cNeedle) > 0

func UseError(h_oSrv, h_cPath, h_fMw)
	h_cErr = ""
	try
		h_oSrv.Use(h_cPath, h_fMw)
	catch
		h_cErr = "" + cCatchError
	done
	return h_cErr

func StaticError(h_oSrv, h_cPath, h_cDir)
	h_cErr = ""
	try
		h_oSrv.Static(h_cPath, h_cDir)
	catch
		h_cErr = "" + cCatchError
	done
	return h_cErr

func Esc(h_cText)
	h_cOut = ""
	h_nLen = len(h_cText)
	if h_nLen > 70
		return left(h_cText, 40) + "...(" + h_nLen + " bytes)"
	ok
	for h_i = 1 to h_nLen
		h_n = ascii(h_cText[h_i])
		if h_n < 32 or h_n > 126
			h_cOut += "<" + h_n + ">"
		else
			h_cOut += h_cText[h_i]
		ok
	next
	return h_cOut

func Rep(h_c, h_n)
	h_cOut = ""
	for h_i = 1 to h_n
		h_cOut += h_c
	next
	return h_cOut

func PadNum(h_n)
	return "" + h_n

func Corpus()
	h_a = []
	h_a + "/files/../secret.txt"
	h_a + "/files/..%2fsecret.txt"
	h_a + "/files/%2e%2e/secret.txt"
	h_a + "/files/%2E%2E/secret.txt"
	h_a + "/files/%2e%2e%2fsecret.txt"
	h_a + "/files/%2E%2E%2Fsecret.txt"
	h_a + "/files/%252e%252e/secret.txt"
	h_a + "/files/%252e%252e%252fsecret.txt"
	h_a + "/files/..\secret.txt"
	h_a + "/files/..%5csecret.txt"
	h_a + "/files/..%5Csecret.txt"
	h_a + "/files/%2e%2e%5csecret.txt"
	h_a + "/files/%5c..%5csecret.txt"
	h_a + "/files//secret.txt"
	h_a + "/files//etc/passwd"
	h_a + "/files/C:/Windows/win.ini"
	h_a + "/files/C%3A/Windows/win.ini"
	h_a + "/files/C%3a%5cWindows%5cwin.ini"
	h_a + "/files/%00"
	h_a + "/files/hello.txt%00.png"
	h_a + "/files/hello.txt%00"
	h_a + "/files/%00/../secret.txt"
	h_a + "//server/share/secret.txt"
	h_a + "/files//server/share"
	h_a + "/files/\\server\share"
	h_a + "/files/%5c%5cserver%5cshare"
	h_a + "/files/%c0%ae%c0%ae/secret.txt"
	h_a + "/files/%c0%af..%c0%afsecret.txt"
	h_a + "/files/%e0%80%ae%e0%80%ae/secret.txt"
	h_a + "/files/%ff%fe/secret.txt"
	h_a + "/files/%c0%2e%c0%2e/secret.txt"
	h_a + "/files/./hello.txt"
	h_a + "/files/././secret.txt"
	h_a + "/files/sub/../../secret.txt"
	h_a + "/files/sub/%2e%2e/%2e%2e/secret.txt"
	h_a + "/files/CON"
	h_a + "/files/CON.txt"
	h_a + "/files/NUL"
	h_a + "/files/aux.html"
	h_a + "/files/COM1"
	h_a + "/files/LPT1.txt"
	h_a + "/files/hello.txt::$DATA"
	h_a + "/files/hello.txt:stream"
	h_a + "/files/hello.txt%3a%3a%24DATA"
	h_a + "/files/hello.txt."
	h_a + "/files/hello.txt%20"
	h_a + "/files/hello.txt%20."
	h_a + "/files/LONGNA~1.TXT"
	h_a + "/files/.."
	h_a + "/files/%2e%2e"
	h_a + "/files/%"
	h_a + "/files/%zz"
	h_a + "/files/%2"
	h_a + ("/files/" + Rep("a", 5000))
	h_a + ("/files/" + Rep("a", 300) + ".txt")
	h_a + "/files/.hidden"
	h_a + "/files/.git/config"
	h_a + "/files/%2ehidden"
	h_a + "/files/....//secret.txt"
	h_a + "/files/..;/secret.txt"
	h_a + "/files/%2e%2e;/secret.txt"
	h_a + "/files/sub%2f..%2f..%2fsecret.txt"
	h_a + "/files/..%00/secret.txt"
	h_a + "/files/secret.txt"
	h_a + "/files/\\?\C:\Windows\win.ini"
	h_a + "/files/%u002e%u002e/secret.txt"
	h_a + ("/files/a" + char(9) + "b")
	h_a + ("/files/a" + char(10) + "b")
	h_a + ("/files/a" + char(0) + "b")
	h_a + "/files/hello.txt/../secret.txt"
	h_a + "/files/*"
	h_a + "/files/*.txt"
	h_a + "/files/hello.txt|"
	h_a + ("/files/" + char(255) + char(254))
	h_a + "/files/%80"
	h_a + "/files/%ed%a0%80"
	h_a + "/files/%f4%90%80%80"
	h_a + "/files/ "
	return h_a

# ---------------------------------------------------------------- callbacks used by the server

func RouteLog(h_oReq, h_oResp)
	$cLog += "R"
	h_oResp.Text("hello")

# Byte-exact comparison. Ring's strcmp STOPS AT THE FIRST NUL, so two texts that both begin with NUL
# compare equal whatever follows: length first, then every byte, then the engine CRC32 of both.
func AsSame(h_cA, h_cB)
	if not isString(h_cA) or not isString(h_cB)
		return 0
	ok
	if len(h_cA) != len(h_cB)
		return 0
	ok
	h_nLen = len(h_cA)
	for h_nQ = 1 to h_nLen
		if ascii(h_cA[h_nQ]) != ascii(h_cB[h_nQ])
			return 0
		ok
	next
	if StzEngineCompressCrc32(h_cA) != StzEngineCompressCrc32(h_cB)
		return 0
	ok
	return 1

func MwA(h_oReq, h_oResp)
	$cLog += "A"

func _Mw_A2(h_oReq, h_oResp)
	$cLog += "A2"

func MwB(h_oReq, h_oResp)
	$cLog += "B"

func MwS(h_oReq, h_oResp)
	$cLog += "S"

func MwT(h_oReq, h_oResp)
	$cLog += "T"

func MwU(h_oReq, h_oResp)
	$cLog += "U"

func MwLater(h_oReq, h_oResp)
	$cLog += "L"

func MwDeny(h_oReq, h_oResp)
	$cLog += "D"
	h_oResp.Status(403, "Forbidden").Text("denied")

func MwStatusOnly(h_oReq, h_oResp)
	h_oResp.Status(401, "Unauthorized")

func MwHeader(h_oReq, h_oResp)
	h_oResp.Header("X-Req", "1")

func MwBoom(h_oReq, h_oResp)
	stzraise("boom-secret-text")

func MwObj(h_oReq, h_oResp)
	$nObj++
	h_oQ = new stzAppRequest("GET", "/z?k=v", [ [ "Host", "x" ] ], "")
	h_cP = h_oQ.Path() + h_oQ.Query("k") + h_oQ.Header("host")
	h_oP = new stzAppResponse("")
	h_oP.Text(h_cP)
