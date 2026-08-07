# D5 secured worker -- spawned by d5_security_narrated.ring:
#   ring _d5_worker.ring <port> <webSecret> <botSecret>
# ONE security vocabulary, nothing minted: stzRequestSigner
# authenticates (HMAC-SHA256 + freshness + nonce replay cache);
# the stzSystemActor lattice authorizes ("work" demands :effectful --
# which the LLM actor, by the load-bearing rule, can never hold).

load "../../stzBase.ring"

nArgs = len(sysargv)
cBotSecret = sysargv[nArgs]
cWebSecret = sysargv[nArgs - 1]
nPort = 0 + sysargv[nArgs - 2]

oSigner = new stzRequestSigner("d5-worker")
oSigner.AddKey("web", cWebSecret)
oSigner.AddKey("bot", cBotSecret)

oNode = new stzNode("worker", nPort)
oNode.SecureWith(oSigner)
oNode.RequireSigned(TRUE)
oNode.AddActor(HumanActor("web"))
oNode.AddActor(LLMActor("bot"))
oNode.Admit("work", "effectful")

oNode.On("ping", func aMsg { return [ "pong", aMsg[2] ] })
oNode.On("work", func aMsg { return "did:" + aMsg[2] })

oNode.Run(60000)
? "d5-worker: done"
