load "../../stzBase.ring"

$CRLF = char(13) + char(10)

? "== block 1 =="
oF = StzMetricFamily("checkout.ms", :Timer, [ "route", "method" ])
oF.Child([ "/menu", "GET" ]).Record(12)
oF.Child([ "/menu", "GET" ]).Record(18)
oF.Child([ "/pay", "POST" ]).Record(220)
? "children     : " + oF.ChildCount() + " (incl. the reserved overflow)"
? "/menu p95    : " + oF.Child([ "/menu", "GET" ]).ExactPercentile(95) + " ms"
? "/pay  p95    : " + oF.Child([ "/pay", "POST" ]).ExactPercentile(95) + " ms"

? "== block 2 =="
oF2 = oF
oF2.Child([ "/refund", "POST" ]).Record(77)
? "born through the copy, seen by the original: " + oF.Child([ "/refund", "POST" ]).Count() + " sample(s)"
oF.Destroy()

? "== block 3 =="
oB = StzMetricFamilyXT("api.calls", :Counter, [ "user" ], 64, 4)
oB.Child([ "alice" ]).Increment()
oB.Child([ "bob" ]).Increment()
oB.Child([ "carol" ]).Increment()
oB.Child([ "dave" ]).Increment()
oB.Child([ "erin" ]).Increment()
see oB.PromText()
oB.Destroy()

? "== block 4 =="
oMon = StzPerfMonitor("restolean")
oSrv = new stzAppServer()
oSrv.ObserveRoutes(oMon)
oSrv.Get_("/menu", func oReq, oResp { oResp.Text("couscous") })
oSrv.Get_("/order", func oReq, oResp {
	_s_ = ""
	for _k_ = 1 to 40000
		_s_ += "x"
	next
	oResp.Text("placed")
})
oSrv.Start(0, "127.0.0.1")
oClient = new stzReactor()
aPaths = [ "/menu", "/order", "/menu", "/order", "/order", "/menu" ]
for i = 1 to len(aPaths)
	cReq = "GET " + aPaths[i] + " HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	oClient.AwaitTcp(nJob, 5000)
next
oSrv.Stop()
oFam = oMon.MetricQ("http.route.ms")
? "/menu  p95 : " + oFam.Child([ "GET", "/menu", "2xx" ]).ExactPercentile(95) + " ms (" + oFam.Child([ "GET", "/menu", "2xx" ]).Count() + " reqs)"
? "/order p95 : " + oFam.Child([ "GET", "/order", "2xx" ]).ExactPercentile(95) + " ms (" + oFam.Child([ "GET", "/order", "2xx" ]).Count() + " reqs)"
oMon.Destroy()
