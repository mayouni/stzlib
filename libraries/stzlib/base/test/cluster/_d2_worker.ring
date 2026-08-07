# D2 worker node -- spawned by d2_location_transparency_narrated.ring:
#   ring _d2_worker.ring <port>
# The SAME script serves as the "local child" and as the "remote host"
# (simulated on another port) -- location must change nothing.

load "../../stzBase.ring"

nPort = 0 + sysargv[len(sysargv)]

$aSeq = []

oNode = new stzNode("worker", nPort)

oNode.On("ping", func aMsg { return [ "pong", aMsg[2] ] })

oNode.On("seq", func aMsg {
	$aSeq + aMsg[2]
	return 0
})

oNode.On("drain", func aMsg {
	aOut = $aSeq
	$aSeq = []
	return aOut
})

oNode.On("echo", func aMsg { return aMsg })

# deliberately slower than a short Ask timeout: the at-most-once probe
oNode.On("slow", func aMsg {
	nUntil = StzEngineWatchTimestampMs() + 800
	while StzEngineWatchTimestampMs() < nUntil
	end
	return [ "slow-reply", aMsg[2] ]
})

oNode.Run(40000)
? "d2-worker: done"
