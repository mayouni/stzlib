# D1 flood node -- spawned by d1_node_mailbox_narrated.ring:
#   ring _d1_node_flood.ring <port> <cap> <policy> <pausems>
# Declares a BOUNDED inbox, then deliberately pauses before serving so
# the guard can flood it: the ENGINE enforces the bound and counts the
# overflow while nothing drains. Then it serves and reports the truth
# via "stats": [ processed, overflow, survivors ].

load "../../stzBase.ring"

nArgs = len(sysargv)
nPause = 0 + sysargv[nArgs]
cPolicy = sysargv[nArgs - 1]
nCap = 0 + sysargv[nArgs - 2]
nPort = 0 + sysargv[nArgs - 3]

cPol = :DropOldest
if cPolicy = "dropnewest"
	cPol = :DropNewest
but cPolicy = "refuse"
	cPol = :Refuse
ok

$aSeq = []
$oNode = new stzNode("flood", nPort)
$oNode.SetInbox(nCap, cPol)

$oNode.On("seq", func aMsg {
	$aSeq + aMsg[2]
	return 0
})

$oNode.On("stats", func aMsg {
	return [ $oNode.Processed(), $oNode.Overflow(), $aSeq ]
})

# the flood window: bound is declared, nothing drains
oPause = new stzReactor()
nT = oPause.SubmitTimer(nPause)
oPause.AwaitTimer(nT, nPause + 2000)
oPause.Destroy()

$oNode.Run(30000)
? "node-flood: done"
