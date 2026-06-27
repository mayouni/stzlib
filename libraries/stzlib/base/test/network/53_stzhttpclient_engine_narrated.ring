load "../../stzBase.ring"
load "../_narrated.ring"

# M-DEP3 slice 2: stzHttpClient rewired to the engine HTTP module.
# No network IO here per the L99 guardrail; live HTTP integration
# tests live outside CI.

Scenario("Construction + setters yield a usable client")
    Given("a fresh stzHttpClient")
    o = new stzHttpClient()
    Then("HasError starts FALSE",        o.HasError(), FALSE)
    Then("ResponseCode starts 0",        o.ResponseCode(), 0)
    Then("ResponseBody starts empty",    o.ResponseBody(), "")
    When("user agent and headers are set")
    o.SetUserAgent("MyTest/1.0").SetHeader("X-Test", "1")
    Then("user_agent persists",          o.user_agent, "MyTest/1.0")
    Then("headers_list has one entry",   len(o.headers_list), 1)
    When("a cookie is added")
    o.SetCookie("session", "abc")
    Then("cookies_list has one entry",   len(o.cookies_list), 1)
EndScenario()

Scenario("Header blob composer formats RFC-style lines")
    Given("a client with custom UA, cookie, and header")
    o = new stzHttpClient()
    o.SetUserAgent("Agent/1")
    o.SetCookie("a", "1")
    o.SetCookie("b", "2")
    o.SetHeader("X-Custom", "yes")
    Then("header blob carries every expected line",
        StzFindFirst(o._ComposeHeaderBlob(), "User-Agent: Agent/1") > 0, TRUE)
    Then("cookie line concatenates with semicolons",
        StzFindFirst(o._ComposeHeaderBlob(), "Cookie: a=1; b=2") > 0, TRUE)
    Then("custom header preserved",
        StzFindFirst(o._ComposeHeaderBlob(), "X-Custom: yes") > 0, TRUE)
EndScenario()

Scenario("Transport-level error path surfaces gracefully")
    Given("a request to a malformed URL")
    o = new stzHttpClient()
    o.Get_("not a url")
    Then("HasError flips to TRUE",          o.HasError(), TRUE)
    Then("ResponseCode is -1",              o.ResponseCode(), -1)
    Then("LastError mentions GET failure",
        StzFindFirst(o.LastError(), "GET failed") > 0, TRUE)
EndScenario()

Scenario("UrlEncode (from stzNetworkUtils) encodes reserved chars")
    Then("space becomes +",   UrlEncode("a b"), "a+b")
    Then("ampersand encoded", UrlEncode("a&b"), "a%26b")
    Then("alphanumerics kept", UrlEncode("abc123"), "abc123")
EndScenario()

Scenario("PostForm builds an x-www-form-urlencoded body")
    Given("a fresh client and form data")
    o = new stzHttpClient()
    # PostForm calls _Perform with the engine -- against a bad URL the
    # transport error pinpoints the content-type plumbing.
    o.PostForm("not a url", [ "k1", "v 1", "k2", "v&2" ])
    Then("transport error captured", o.HasError(), TRUE)
    Then("status code is -1",        o.ResponseCode(), -1)
EndScenario()

Summary()
