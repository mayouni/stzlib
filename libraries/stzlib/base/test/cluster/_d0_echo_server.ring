# D0 echo peer -- the OTHER OS process of the message-plane spike.
# Spawned by d0_message_plane_narrated.ring as: ring _d0_echo_server.ring <port>
#
# Listens in STZM mode on loopback and echoes every complete frame back
# verbatim on the connection it arrived on. Exits when a connection that
# actually served traffic closes (the guard hanging up ends the process),
# or on a 60 s TTL so a crashed guard never leaks an orphan.

load "../../stzBase.ring"

nPort = 0 + sysargv[len(sysargv)]

oRct = new stzReactor()
nSrv = oRct.ListenStzm("127.0.0.1", nPort)
if nSrv < 1
	? "echo-server: listen failed on port " + nPort
	bye
ok

nDeadline = StzEngineWatchTimestampMs() + 60000
bServed = FALSE

while StzEngineWatchTimestampMs() < nDeadline
	aEv = oRct.ServerAwait(nSrv, 250)
	if len(aEv) = 3
		if aEv[1] = :data
			oRct.ServerWrite(nSrv, aEv[2], aEv[3], FALSE)
			bServed = TRUE
		but aEv[1] = :closed
			if bServed
				exit
			ok
		ok
	ok
end

oRct.ServerStop(nSrv)
oRct.Destroy()
? "echo-server: done"
