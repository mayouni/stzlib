load "../../stzBase.ring"

cPath = "_tmp_demo_seal.txt"

? "== block 1 =="
oLed = StzSecurityLedger(256)
oLed.Record(StzSecurityRefusal("auth.login.failed", HumanActor("admin"), "user:admin", "bad password"))
oLed.Record(StzSecurityRefusal("sig.nonce.replayed", HumanActor("peer-3"), "key:billing", "nonce already used for this key"))
oLed.Record(StzSecurityRefusal("secret.reveal.refused", LLMActor("advisor"), "secret:stripe-live", "actor is not effectful"))
oLed.Show()

? "== block 2 =="
? "head digest : " + oLed.Digest()
aV = oLed.Verify()
? "verify      : " + aV[:message]

? "== block 3 =="
? "refusals            : " + len(oLed.Refusals())
? "about that secret   : " + len(oLed.OfSubject("secret:stripe-live"))
? "by the sandboxed llm: " + len(oLed.OfActor("advisor"))

? "== block 4 =="
oLed.SealTo(cPath, "the-evidence-key")
aOk = StzVerifySealedLedger(cPath, "the-evidence-key")
? "fresh export  : ok=" + aOk[:ok] + " -- " + aOk[:why]

cRaw = read(cPath)
write(cPath, StzReplace(cRaw, "actor is not effectful", "routine maintenance"))
aBad = StzVerifySealedLedger(cPath, "the-evidence-key")
? "after an edit : ok=" + aBad[:ok] + " -- " + aBad[:why]
remove(cPath)
oLed.Destroy()
