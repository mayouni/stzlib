load "../../stzBase.ring"

$CRLF = char(13) + char(10)

? "== block 1 =="
oMon = StzPerfMonitor("restolean")
oMon.WatchMemory().WatchCpu().Every(100)
oSrv = new stzAppServer()
oSrv.Observe(oMon)
oSrv.Get_("/menu", func oReq, oResp { oResp.Json([ "dish", "Couscous", "price", 12 ]) })
oSrv.Start(0, "127.0.0.1")
oClient = new stzReactor()
for i = 1 to 30
	cReq = "GET /menu HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	oClient.AwaitTcp(nJob, 5000)
next
? "R p95 (exact)  : " + oMon.MetricQ("http.request.ms").ExactPercentile(95) + " ms"
? "R mean (exact) : " + oMon.MetricQ("http.request.ms").MeanMs() + " ms"
? "X measured     : " + oMon.MetricQ("http.requests").RatePerSecond() + " req/s"

? "== block 2 =="
cReq = "GET /health HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
oSrv.ServeOne(3000)
cH = oClient.AwaitTcp(nJob, 5000)
aParts = StzSplit(cH, $CRLF + $CRLF)
? aParts[2]

? "== block 3 =="
cReq = "GET /metrics HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
oSrv.ServeOne(3000)
cM = oClient.AwaitTcp(nJob, 5000)
aParts = StzSplit(cM, $CRLF + $CRLF)
see aParts[2]
oSrv.Stop()

? "== block 4 =="
oT = new stzAppTopology("restolean")
oT.AddDatasetQ("orders", [ [ "Tajine", 1 ] ])
oT.SetDatasetColumnsQ("orders", [ "dish", "qty" ])
oT.SetPartRoleQ(:phone, "menu", "orders")
oT.SetPartRoleQ(:admin, "dashboard", "orders")
oB = new stzAppBackend("restolean", oT)
oB.Start(0)
oB.Create(:phone, "orders", [ [ "dish", "Couscous" ], [ "qty", 2 ] ])
oB.Rows(:admin, "orders")
oB.RowCount(:admin, "orders")
oB.Show()
? "mean crossing  : " + oB.MeanCrossingMs() + " ms"
oB.Stop()

? "== block 5 =="
oPipe = new stzComputePipeline("doc-intake")
oPipe.Stage(:vision, "ocr", func x { return StzReplace(x, "scan:", "") })
oPipe.Stage(:nlp, "entities", func x {
	_s_ = ""
	for _k_ = 1 to 150000
		_s_ += "x"
	next
	return x + " [entities]"
})
oPipe.Stage(:search, "index", func x { return x + " [indexed]" })
oPipe.Run("scan:acme invoice")
aD = oPipe.StageDurations()
for i = 1 to len(aD)
	? aD[i][1] + " : " + aD[i][2] + " ms"
next
? "total : " + oPipe.TotalMs() + " ms"
