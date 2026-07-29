load "../../stzBase.ring"

$CRLF = char(13) + char(10)

? "== block 1 =="
oMon = StzPerfMonitor("restolean")
oMon.WatchMemory().WatchCpu().Every(30)
oSrv = new stzAppServer()
oSrv.Observe(oMon)
oSrv.Get_("/order", func oReq, oResp {
	_s_ = ""
	for _k_ = 1 to 30000
		_s_ += "x"
	next
	oResp.Text("placed")
})
oSrv.Start(0, "127.0.0.1")
oClient = new stzReactor()
oP = StzPerfProfile(oMon)
for i = 1 to 25
	cReq = "GET /order HTTP/1.1" + $CRLF + "Host: local" + $CRLF + "Connection: close" + $CRLF + $CRLF
	nJob = oClient.SubmitTcp("127.0.0.1", oSrv.Port(), cReq)
	oSrv.ServeOne(3000)
	oClient.AwaitTcp(nJob, 5000)
next
oSrv.Stop()
? "measured load (X/Xmax) : " + oP.LoadRatio()

oCluster = new stzAppCluster()
oSup = new stzClusterSupervisor(oCluster)
oSup.Policy(:nlp, 1, 4).SetWaterMarks(0.25, 0.75)
oSup.FeedLoadFrom(:nlp, oP)
aM = [ [ :tag = "nlp", :total = 3, :ready = 3, :draining = 0, :dead = 0 ] ]
aActs = oSup.Decide(aM)
? "supervisor decides     : " + aActs[1][1] + " (measured load " + oSup.LoadOf(:nlp) + " < low-water 0.25)"

? "== block 2 =="
# SelfCost prices the face that DRIVES the sampling (Ring-side state:
# the server's copy drove during serving) -- so drive this face:
for i = 1 to 20
	oMon.Sample()
next
aCost = oMon.SelfCost()
? "observation priced itself: " + aCost[:samples] + " sample(s), " + aCost[:perSampleMs] + " ms each"

? "== block 3 =="
gL = oMon.NewGauge("queue.depth")
gL.Set(12)
oSla = StzSla("restolean-sla")
oSla.ExpectValue("queue.depth").AtMost(100)
oSent = StzPerfSentinel(oSla, oMon)
oSent.Check()
gL.Set(900)
oSent.Check()
aBox = oSent.LastBlackBox()
? "breach: " + aBox[:rule]
? "black box, written AT breach time:"
? "  rss " + aBox[:rssBytes]/1024/1024 + " MB ; peak " + aBox[:peakBytes]/1024/1024 + " MB ; cpu " + aBox[:cpuMs] + " ms"
? "  metrics photographed: " + len(aBox[:metrics])

? "== block 4 =="
aF = oSla.CheckAgainst(oMon)
oPlan = StzPerfPlan("relieve-queue")
oPlan.Propose(:ScaleUp, "nlp", aF[1][:message])
oLlm = LLMActor("advisor")
oHuman = HumanActor("mansour")
oFake = new FakeFleet
? "LLM may commit?   " + oPlan.MayCommit(oLlm)
? "human may commit? " + oPlan.MayCommit(oHuman)
? "LLM executes   -> " + oPlan.ExecuteOn(oFake, oLlm) + " committed (fleet calls: " + oFake.CallCount() + ")"
? "human executes -> " + oPlan.ExecuteOn(oFake, oHuman) + " committed (fleet calls: " + oFake.CallCount() + ")"
? ""
oPlan.Show()

class FakeFleet
	aFleetCalls = []
	def ScaleUp(pcTag)
		aFleetCalls + [ "scaleup", pcTag ]
	def ScaleDown(pcTag)
		aFleetCalls + [ "scaledown", pcTag ]
	def RestartDead()
		aFleetCalls + [ "restartdead", "" ]
	def CallCount()
		return ring_len(aFleetCalls)
