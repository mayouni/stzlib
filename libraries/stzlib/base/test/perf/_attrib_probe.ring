load "../../stzBase.ring"

$CRLF = char(13) + char(10)

oSrv = new stzAppServer()
oSrv.Get_("/x", func oReq, oResp { oResp.Text("ok") })
oSrv.Start(0, "127.0.0.1")
oClient = new stzReactor()

cReq = "GET /x HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF

# warm-up trip (connect pools, code paths jitted into caches)
nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
oSrv.ServeOne(3000)
oClient.AwaitTcp(nJob, 5000)

N = 20
nSubCpu = 0
nSrvCpu = 0
nAwtCpu = 0
nSubWall = 0
nSrvWall = 0
nAwtWall = 0

for i = 1 to N
	c0 = StzEnginePerfCpuNs()
	w0 = StzEngineWatchTimestampNs()
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	c1 = StzEnginePerfCpuNs()
	w1 = StzEngineWatchTimestampNs()
	oSrv.ServeOne(3000)
	c2 = StzEnginePerfCpuNs()
	w2 = StzEngineWatchTimestampNs()
	oClient.AwaitTcp(nJob, 5000)
	c3 = StzEnginePerfCpuNs()
	w3 = StzEngineWatchTimestampNs()
	nSubCpu += (c1-c0)
	nSrvCpu += (c2-c1)
	nAwtCpu += (c3-c2)
	nSubWall += (w1-w0)
	nSrvWall += (w2-w1)
	nAwtWall += (w3-w2)
next

? "per round trip, over " + N + " trips:"
? "  submit : cpu " + nSubCpu/N/1000000 + " ms / wall " + nSubWall/N/1000000 + " ms"
? "  serve  : cpu " + nSrvCpu/N/1000000 + " ms / wall " + nSrvWall/N/1000000 + " ms"
? "  await  : cpu " + nAwtCpu/N/1000000 + " ms / wall " + nAwtWall/N/1000000 + " ms"
? "  TOTAL  : cpu " + (nSubCpu+nSrvCpu+nAwtCpu)/N/1000000 + " ms / wall " + (nSubWall+nSrvWall+nAwtWall)/N/1000000 + " ms"

oSrv.Stop()
