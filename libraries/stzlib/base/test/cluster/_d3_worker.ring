# D3 worker node -- spawned by d3_supervision_narrated.ring (directly or
# BY THE SUPERVISOR under test): ring _d3_worker.ring <port>
# Carries the failure modes supervision must handle: a raising handler
# (boom -> loud death) and a WEDGING handler (alive but unresponsive,
# only heartbeats can tell). Doubles as the monitor's watcher node via
# the node.down accumulator.

load "../../stzBase.ring"

nPort = 0 + sysargv[len(sysargv)]

$aSeq = []
$aDown = []

oNode = new stzNode("d3worker", nPort)

oNode.On("ping", func aMsg { return [ "pong", aMsg[2] ] })

oNode.On("seq", func aMsg {
	$aSeq + aMsg[2]
	return 0
})

oNode.On("drain", func aMsg { return $aSeq })

oNode.On("boom", func aMsg {
	raise("d3 worker exploded on purpose")
})

# alive but UNRESPONSIVE: the process stays up, the dispatch loop never
# returns -- only heartbeat tolerance can call this dead
oNode.On("wedge", func aMsg {
	while TRUE
	end
})

# the watcher role: death notices from the supervisor accumulate here
oNode.On("node.down", func aMsg {
	$aDown + [ aMsg[2], aMsg[3] ]
	return 0
})

oNode.On("downs", func aMsg { return $aDown })

oNode.Run(60000)
? "d3-worker: done"
