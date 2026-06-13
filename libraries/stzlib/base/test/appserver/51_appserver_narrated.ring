load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("stzAppRequest exposes the four constructor fields")
    Given("a GET request with one header")
    oReq = new stzAppRequest("GET", "/api/echo", [ [ "Host", "localhost" ] ], "")
    Then("Method() returns the verb",  oReq.Method(), "GET")
    Then("Path() returns the path",    oReq.Path(),   "/api/echo")
    Then("Header() finds Host",        oReq.Header("Host"), "localhost")
    Then("Header() is case-insensitive", oReq.Header("host"), "localhost")
    Then("Header() returns empty on miss", oReq.Header("missing"), "")
EndScenario()

Scenario("ParseQuery splits the query string off the path")
    Given("a path with a two-key query string")
    oReq = new stzAppRequest("GET", "/search?q=hello&page=2", [], "")
    Then("path no longer carries the query", oReq.Path(), "/search")
    Then('Query("q") returns "hello"',       oReq.Query("q"),       "hello")
    Then('Query("page") returns "2"',        oReq.Query("page"),    "2")
    Then("Query(missing) returns empty",     oReq.Query("missing"), "")
EndScenario()

Scenario("stzAppResponse supports fluent chaining and Send")
    Given("a fresh response over a NULL client")
    oResp = new stzAppResponse(NULL)
    When("the caller sets status 201 and a custom header")
    oResp.Status(201, "Created").Header("X-Test", "1")
    Then("the header is recorded", oResp.aHeaders[1][1], "X-Test")
    Then("with its value",         oResp.aHeaders[1][2], "1")

    Given("a fresh response")
    oResp2 = new stzAppResponse(NULL)
    When("Send() is called")
    oResp2.Send("body")
    Then("bSent becomes TRUE", oResp2.bSent, TRUE)
EndScenario()

Scenario("ObjectToJson handles primitives and arrays")
    oResp = new stzAppResponse(NULL)
    Then("strings get quoted",    oResp.ObjectToJson("hi"), '"hi"')
    Then("numbers stringify",     oResp.ObjectToJson(42), "42")
    Then("numeric arrays format", oResp.ObjectToJson([1, 2, 3]), "[1,2,3]")
    Then("kv-pair lists become objects",
        oResp.ObjectToJson([ "k", "v", "n", 1 ]), '{"k":"v","n":1}')
EndScenario()

Summary()
