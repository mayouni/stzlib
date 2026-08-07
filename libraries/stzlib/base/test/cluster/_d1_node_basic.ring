# D1 basic node -- spawned by d1_node_mailbox_narrated.ring:
#   ring _d1_node_basic.ring <port>
# Handlers cover the guard's lifecycle: ask/reply, FIFO accumulation,
# echo (for the dispatch-overhead measurement), loud death, clean stop.

load "../../stzBase.ring"

nPort = 0 + sysargv[len(sysargv)]

$aSeq = []

oNode = new stzNode("basic", nPort)

oNode.On("ping", func aMsg { return [ "pong", aMsg[2] ] })

oNode.On("seq", func aMsg {
	$aSeq + aMsg[2]
	return 0
})

oNode.On("drain", func aMsg { return $aSeq })

oNode.On("echo", func aMsg { return aMsg })

# A raising handler: the node must die LOUDLY (observable exit), never wedge.
oNode.On("boom", func aMsg {
	raise("node handler exploded on purpose")
})

oNode.Run(30000)
? "node-basic: done"
