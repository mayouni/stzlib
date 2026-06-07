# Smoke regression for stzAppServer family: AppServer + AppRequest +
# AppResponse + AppRouter. Tests construction + structural API only
# (no actual network listening).
#
# Run from base/appserver/test/.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzAppServer family integration regression ==="

# ------------------------------------------------------------
# stzAppRequest
# ------------------------------------------------------------
? ""
? "--- stzAppRequest ---"

oReq = new stzAppRequest("GET", "/api/users", [], "")
chk("Request constructs",            isObject(oReq))
chk("Method() = 'GET'",              oReq.Method() = "GET")
chk("Path() = '/api/users'",         oReq.Path() = "/api/users")
chk("Headers() is list",             isList(oReq.Headers()))
chk("Body() is string",              isString(oReq.Body()))

# ------------------------------------------------------------
# stzAppResponse
# ------------------------------------------------------------
? ""
? "--- stzAppResponse ---"

# Pass dummy client ref (test won't actually send)
oRes = new stzAppResponse(NULL)
chk("Response constructs", isObject(oRes))

# Status / Header chain
ret = oRes.Status(200, "OK")
chk("Status returns object", isObject(ret))

# ------------------------------------------------------------
# stzAppRouter
# ------------------------------------------------------------
? ""
? "--- stzAppRouter ---"

oRouter = new stzAppRouter
chk("Router constructs", isObject(oRouter))

# Add route
oRouter.AddRoute("GET", "/test", func r, s { })
chk("HasRoute after Add", oRouter.HasRoute("GET", "/test") = 1 or oRouter.HasRoute("GET", "/test") = TRUE)
chk("Missing route returns false", oRouter.HasRoute("GET", "/missing") = 0 or oRouter.HasRoute("GET", "/missing") = FALSE)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL appserver CHECKS PASSED!"
else
	? "SOME appserver CHECKS FAILED!"
ok

pf()
# Executed in almost 0 second(s) in Ring 1.26

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
