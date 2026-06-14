load "../../stzBase.ring"
load "../_narrated.ring"

# HTTP feature-completion: auth / proxy / mTLS / cookies / verify /
# redirect / response-headers -- all now driven through libcurl via the
# per-request options blob. The composition scenario is deterministic
# (no network); the others make live requests (OUTSIDE CI).

Scenario("The options blob reflects the client settings")
    Given("a client configured with auth, proxy, mTLS, verify-off")
    o = new stzHttpClient()
    o.SetAuth("alice", "secret")
    o.SetAuthType("digest")
    o.SetProxy("http://127.0.0.1:8080")
    o.SetClientCert("client.pem", "client.key")
    o.VerifySSL(FALSE)
    o.FollowRedirects(FALSE)
    cBlob = o._ComposeOptionsBlob()
    Then("it carries the credentials", StzFind(cBlob, "userpwd=alice:secret") > 0, TRUE)
    Then("it carries the auth type", StzFind(cBlob, "authtype=digest") > 0, TRUE)
    Then("it carries the proxy", StzFind(cBlob, "proxy=http://127.0.0.1:8080") > 0, TRUE)
    Then("it carries the client cert", StzFind(cBlob, "sslcert=client.pem") > 0, TRUE)
    Then("it disables verification", StzFind(cBlob, "verifyssl=0") > 0, TRUE)
    Then("it disables redirects", StzFind(cBlob, "followredirects=0") > 0, TRUE)
EndScenario()

Scenario("A bearer-token client emits a bearer option")
    Given("a client with a bearer token")
    o2 = new stzHttpClient()
    o2.SetBearer("tok-12345")
    Then("the blob carries the bearer token",
        StzFind(o2._ComposeOptionsBlob(), "bearer=tok-12345") > 0, TRUE)
EndScenario()

Scenario("Response headers are captured")
    Given("a GET to example.com")
    o3 = new stzHttpClient()
    o3.Get_("https://example.com/")
    Then("the request succeeded (200)", o3.ResponseCode(), 200)
    cHdrs = o3.ResponseHeaders()
    Then("response headers are non-empty", len(cHdrs) > 0, TRUE)
    Then("they include a Content-Type header",
        StzFind(lower(cHdrs), "content-type") > 0, TRUE)
EndScenario()

Scenario("Basic auth succeeds with correct credentials")
    Given("postman-echo basic-auth endpoint (user postman / password)")
    o4 = new stzHttpClient()
    o4.SetAuth("postman", "password")
    o4.Get_("https://postman-echo.com/basic-auth")
    Then("authenticated request returns 200", o4.ResponseCode(), 200)
EndScenario()

Scenario("gzip responses are transparently decompressed (vendored zlib)")
    Given("a client that accepts gzip")
    o5 = new stzHttpClient()
    o5.AcceptGzip()
    o5.Get_("https://httpbin.org/gzip")
    Then("the request succeeded (200)", o5.ResponseCode(), 200)
    Then("the body was decompressed to readable JSON",
        StzFind(o5.ResponseBody(), "gzipped") > 0, TRUE)
EndScenario()

Summary()
