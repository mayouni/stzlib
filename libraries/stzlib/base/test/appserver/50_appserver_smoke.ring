load "../../stzBase.ring"

pr()

# stzAppRequest: simple construction + accessors
oReq = new stzAppRequest("GET", "/api/echo", [ [ "Host", "localhost" ] ], "")
? oReq.Method() = "GET"
? oReq.Path() = "/api/echo"
? oReq.Header("Host") = "localhost"
? oReq.Header("host") = "localhost"             # case-insensitive
? oReq.Header("missing") = ""

# ParseQuery: query string split off path and parsed
oReq2 = new stzAppRequest("GET", "/search?q=hello&page=2", [], "")
? oReq2.Path() = "/search"
? oReq2.Query("q") = "hello"
? oReq2.Query("page") = "2"
? oReq2.Query("missing") = ""

# stzAppResponse: status + headers + payload (no actual send)
oResp = new stzAppResponse(NULL)
oResp.Status(201, "Created").Header("X-Test", "1")
? oResp.aHeaders[1][1] = "X-Test"
? oResp.aHeaders[1][2] = "1"

# ObjectToJson: primitives
? oResp.ObjectToJson("hi") = '"hi"'
? oResp.ObjectToJson(42) = "42"
? oResp.ObjectToJson([1, 2, 3]) = "[1,2,3]"
? oResp.ObjectToJson([ "k", "v", "n", 1 ]) = '{"k":"v","n":1}'

# Send marks bSent so a second Send is a no-op
oResp2 = new stzAppResponse(NULL)
oResp2.Send("body")
? oResp2.bSent = TRUE

? "DONE 14"

pf()
