# Labels and dimensions -- perf system P8 (SOFTANZA_PERF_SYSTEM.md).
#
# The comparison doc named flat metric names as the system's most
# consequential gap; P8 closes it the Softanza way: a FAMILY is one
# name + declared label names, each label-value set a CHILD with its
# own engine stores. The child REGISTRY lives ENGINE-side -- children
# created through one Ring face are visible to every other (the same
# copy law as all perf state). Cardinality is BOUNDED at birth with a
# RESERVED overflow child: a full family routes new label sets there
# instead of exploding or silently dropping.
#
# Ring traps avoided: main code before the first func; helper temps
# underscored; no local oR / nL / Try / Show.

load "../../stzBase.ring"

nPass = 0
nFail = 0

$CRLF = char(13) + char(10)

pr()

? "-- Scene 1: one name, many children, separate truths --"
oF = StzMetricFamily("checkout.ms", :Timer, [ "route", "method" ])
oF.Child([ "/menu", "GET" ]).Record(10)
oF.Child([ "/menu", "GET" ]).Record(20)
oF.Child([ "/pay", "POST" ]).Record(500)
chk("two label sets -> two children (+ the reserved overflow)", oF.ChildCount() = 3)
chk("the same values resolve to the SAME child (2 samples)", oF.Child([ "/menu", "GET" ]).Count() = 2)
chk("children keep separate stats", oF.Child([ "/menu", "GET" ]).ExactPercentile(100) = 20 and oF.Child([ "/pay", "POST" ]).ExactPercentile(100) = 500)
chk("child sum is exact per child", fabs(oF.Child([ "/menu", "GET" ]).SumMs() - 30) < 0.000001)

? ""
? "-- Scene 2: THE P8 point -- a child born through a COPY is visible everywhere --"
oF2 = oF
oF2.Child([ "/refund", "POST" ]).Record(77)
chk("the ORIGINAL face sees the copy's new child (engine registry)", oF.ChildCount() = 4)
chk("...and reads its data", oF.Child([ "/refund", "POST" ]).Count() = 1)
chk("Keys() agree across faces", len(oF.Keys()) = len(oF2.Keys()))

? ""
? "-- Scene 3: the grammar protects itself --"
bRaised = FALSE
try
	oF.Child([ "/menu" ])
catch
	bRaised = TRUE
done
chk("wrong label count refuses with the label names", bRaised)
bRaised = FALSE
try
	oF.Value()
catch
	bRaised = TRUE
done
chk("a family refuses to impersonate one metric (pick a Child)", bRaised)
bRaised = FALSE
try
	oX = StzMetricFamily("x", :Timer, [])
catch
	bRaised = TRUE
done
chk("a family without labels refuses (that is a plain stzMetric)", bRaised)

? ""
? "-- Scene 4: cardinality is bounded -- the overflow child absorbs, visibly --"
oB = StzMetricFamilyXT("api.calls", :Counter, [ "user" ], 64, 4)
oB.Child([ "alice" ]).Increment()
oB.Child([ "bob" ]).Increment()
oB.Child([ "carol" ]).Increment()
chk("3 users + reserved overflow fill the family of 4", oB.ChildCount() = 4)
oB.Child([ "dave" ]).Increment()
oB.Child([ "erin" ]).Increment()
chk("no 5th child was created", oB.ChildCount() = 4)
chk("...the family knows it overflowed", oB.HasOverflowed())
chk("...and the overflow child COUNTED both strays (no silent drop)", oB.Child([ "_overflow" ]).Value() = 2)

? ""
? "-- Scene 5: Prometheus exposition with label blocks --"
cProm = oF.PromText()
see cProm
chk("ONE TYPE header for the family", len(StzFind("# TYPE checkout_ms summary", cProm)) = 1)
chk("child labels render in braces, quantile merged", StzFindFirst('checkout_ms{route="/menu",method="GET",quantile="0.95"}', cProm) > 0)
chk("sum/count carry the labels too", StzFindFirst('checkout_ms_sum{route="/pay",method="POST"} 500', cProm) > 0)
cPromC = oB.PromText()
chk("counter children render name_total{labels} value", StzFindFirst('api_calls_total{user="alice"} 1', cPromC) > 0)
chk("the overflow bucket is VISIBLE in the exposition", StzFindFirst('user="_overflow"} 2', cPromC) > 0)

? ""
? "-- Scene 6: one OTLP metric, one data point per child, labels as attributes --"
cOtel = oF.OtelMetricJson()
chk("one metric object", len(StzFind('"name":"checkout.ms"', cOtel)) = 1)
chk("attributes carry the labels", StzFindFirst('{"key":"route","value":{"stringValue":"/menu"}}', cOtel) > 0)
chk("summary data points per child", len(StzFind('"quantileValues"', cOtel)) = 4)
oF.Destroy()
oB.Destroy()

? ""
? "-- Scene 7: ObserveRoutes -- per-route percentiles from real traffic --"
oMon = StzPerfMonitor("shop")
oSrv = new stzAppServer()
oSrv.ObserveRoutes(oMon)
chk("ObserveRoutes registered the route family", oMon.HasMetric("http.route.ms"))
oSrv.Get_("/menu", func oReq, oResp { oResp.Text("couscous") })
oSrv.Get_("/boom", func oReq, oResp { stzraise("deliberate failure") })
oSrv.Start(0, "127.0.0.1")
oClient = new stzReactor()
for i = 1 to 4
	cReq = "GET /menu HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	oClient.AwaitTcp(nJob, 5000)
next
cReq = "GET /boom HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
oSrv.ServeOne(3000)
oClient.AwaitTcp(nJob, 5000)
oSrv.Stop()

oFam = oMon.MetricQ("http.route.ms")
chk("the USER's face sees the routes the SERVER's face discovered", ring_find(oFam.Keys(), "GET|/menu|2xx") > 0)
chk("...including the failing one, classed 5xx", ring_find(oFam.Keys(), "GET|/boom|5xx") > 0)
chk("per-route counts are right", oFam.Child([ "GET", "/menu", "2xx" ]).Count() = 4)
nP95 = oFam.Child([ "GET", "/menu", "2xx" ]).ExactPercentile(95)
? "  /menu per-route p95 = " + nP95 + " ms"
chk("per-route percentiles answer (> 0)", nP95 > 0)

? ""
? "-- Scene 8: the monitor's exposition carries the family --"
cExpo = ""
cExpo = oMon.Prometheus()
chk("the /metrics text includes labeled route lines", StzFindFirst('http_route_ms{method="GET",route="/menu",class="2xx",quantile="0.5"}', cExpo) > 0)
chk("...and the flat request instruments still render flat", StzFindFirst("http_requests_total ", cExpo) > 0)
oMon.Destroy()

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func fabs n
	if n < 0 return -n ok
	return n
