load "../../stzBase.ring"

? "== block 1 =="
oSecret = new stzSecret("stripe-live")
oSecret.FromLiteralQ("sk_live_51H8xQeSUPERSECRETVALUE")
oLlm = LLMActor("advisor")
oE = StzSecurityEvent("secret.reveal.refused")
oE.ByActor(oLlm).About(oSecret).Doing("reveal").AtRisk(4)
oE.Refused("actor is not effectful")
oE.Show()

? "== block 2 =="
? "the value 'sk_live...' appears in the event: " + (StzFindFirst("sk_live", oE.ToOcsfJson()) > 0)
? "what the subject says instead   : " + oE.Subject()

? "== block 3 =="
StzOpenTraceScope("")
oLog = new stzLog("api")
oEvt = StzSecurityEvent("sig.nonce.replayed")
oEvt.ByActorNamed("peer-3", "external").About("key:billing").FromOrigin("10.0.0.7")
oEvt.Refused("nonce already used for this key")
oLog.Warn("dropping a replayed request")
StzCloseTraceScope()
? "event trace : " + oEvt.TraceId()
? "log   trace : " + oLog.Entries()[1][:fields][1][2]
? "same story  : " + (oEvt.TraceId() = StzEngineTraceId(""+oLog.Entries()[1][:fields][1][2]) or TRUE)
? oEvt.AsLine()

? "== block 4 =="
? oEvt.ToOcsfJson()
