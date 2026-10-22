load "../../stzBase.ring"

# RX4 -- the app server half of the render benchmark. See BENCH_METHOD.md.
#
#   ring bench_appserver.ring [requests]      default 300
#
# Prints, one fact per line:
#   RSS  <label> <bytes>
#   LOAD closed-loop <requests> <seconds> <req_per_s> <p50_ms> <p95_ms> <worst_ms>
#
# WHAT THIS IS, STATED PLAINLY. A CLOSED-LOOP run with ONE client: the next
# request is sent only after the previous answer has arrived, so the offered
# load adjusts to the server and queueing is never exercised. The client (a
# second stzReactor) and the server share this one process and this one
# machine, so a request's time includes the client's own cost. It is the
# round trip of one request at a time, not a capacity. An OPEN-LOOP run, which
# fires at a fixed rate whatever the answers do, is not made here and is not
# implied. The route answers a short text, so the figure is the framing, the
# route dispatch and the loopback, not a workload.
#
# IDLE MEMORY: the resident set of this process after the library is loaded
# and BEFORE the listener starts (the baseline), then after Start() and before
# any request (the idle server), so the server's own share is the difference.

nReq = 300
if len(sysargv) > 0
	nReqArg = 0 + sysargv[len(sysargv)]
	if nReqArg >= 10
		nReq = nReqArg
	ok
ok

$CRLF = char(13) + char(10)
BenchAppMain()

func BenchAppMain()
	? "RSS baseline " + StzEnginePerfMemRss()
	oSrv = new stzAppServer()
	oClient = new stzReactor()
	oSrv.Start(0, "127.0.0.1")
	oSrv.Get_("/greet", func oReq, oResp {
		oResp.Text("hello " + oReq.Query("name"))
	})
	? "RSS idle-server " + StzEnginePerfMemRss()
	cReq = "GET /greet?name=softanza HTTP/1.1" + $CRLF + "Host: local" + $CRLF +
	       "Connection: close" + $CRLF + $CRLF

	# a few requests first, so the listener and the route are warm; not counted
	for i = 1 to 5
		nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
		oSrv.ServeOne(3000)
		oClient.AwaitTcp(nJob, 5000)
	next

	aMs = []
	nBad = 0
	nT0 = StzEngineWatchTimestampNs()
	for i = 1 to nReq
		nS = StzEngineWatchTimestampNs()
		nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
		oSrv.ServeOne(3000)
		cBody = oClient.AwaitTcp(nJob, 5000)
		aMs + ((StzEngineWatchTimestampNs() - nS) / 1000000)
		if StzFindFirst("hello softanza", cBody) = 0
			nBad++
		ok
	next
	nTotalS = (StzEngineWatchTimestampNs() - nT0) / 1000000000
	if nBad > 0
		? "ERR " + nBad + " of " + nReq + " answers were not the expected body"
		shutdown(1)
	ok
	? "RSS after-load " + StzEnginePerfMemRss()
	aS = sort(aMs)
	n = len(aS)
	? "LOAD closed-loop " + n + " " + BenchFmt(nTotalS) + " " + BenchFmt(n / nTotalS) + " " +
	  BenchFmt(aS[ceil(n * 0.50)]) + " " + BenchFmt(aS[ceil(n * 0.95)]) + " " + BenchFmt(aS[n])
	oSrv.Stop()
	oClient.Destroy()

func BenchFmt(nV)
	return "" + (floor(nV * 100 + 0.5) / 100)
