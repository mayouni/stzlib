# stzSecurityPosture -- the security doctrine, made RUNNABLE.
#
# Like stzGovernanceChecks runs invariants over an agent graph, this runs
# invariants over a PROJECT's security surface (store + sites + actors) and
# reports structured findings CI can gate on. It turns "expression is free,
# admission is governed" from a principle into a check.
#
# Ring traps avoided: no oR/nL locals; main before the first func; no inline
# new X().M(); StzFindFirst not StzFind; try/catch/done for raises.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

# a shared store with one key.
oStore = new stzSecretStore("restolean")
oKey = new stzDeployKey("deploy-key")
oKey.FromLiteralQ("ssh-ed25519-LIVE")
oStore.Register(oKey)

? "-- Scene 1: a well-configured project is SOUND (nothing flagged) --"
oGood = new stzDeploymentSite("api")
oGood.SetKindQ(:Server)
oGood.SetAuthFromStoreQ(oStore, "deploy-key")     # store-backed, audited
oClean = new stzSecurityPosture("restolean")
oClean.SetStore(oStore)
oClean.AddSite(oGood)
oClean.AddActor(LLMActor("planner"))              # inference-only, sandboxed -- fine
oClean.AddActor(HumanActor("ops"))                # effectful, trusted -- fine
chk("a clean project is sound", oClean.IsSound())
chk("...and clean (nothing flagged at all)", oClean.IsClean() and oClean.NumberOfFindings() = 0)

? ""
? "-- Scene 2: an LLM/sandboxed actor holding 'effectful' is an ERROR --"
oRogue = SystemActor("rogue", [ "effectful", "inference" ])
oRogue.SetPosture("sandboxed")                    # sandboxed YET effectful
oP2 = new stzSecurityPosture("restolean")
oP2.SetStore(oStore)
oP2.AddActor(oRogue)
oP2.AddActor(LLMActor("planner"))                 # a proper LLM -- not flagged
aF2 = oP2.Findings()
chk("the sandboxed-effectful actor is flagged", oP2.NumberOf(:error) = 1)
chk("...it is an ERROR (the load-bearing rule)", aF2[1][:severity] = :error and aF2[1][:invariant] = "no-sandboxed-effectful")
chk("...the project is UNSOUND", NOT oP2.IsSound())
chk("...a proper LLM actor is NOT flagged", oP2.NumberOfFindings() = 1)

? ""
? "-- Scene 3: an inline secret (not in the store) is a WARNING --"
oInline = new stzDeploymentSite("legacy")
oInline.SetKindQ(:Server)
oInline.SetAuthRefQ(oKey)                         # a directly-held secret
oP3 = new stzSecurityPosture("restolean")
oP3.SetStore(oStore)                              # store IS set -> only inline-key fires
oP3.AddSite(oInline)
chk("the inline key is flagged", oP3.NumberOf(:warn) = 1)
aF3 = oP3.Findings()
chk("...as a WARNING named 'inline-key'", aF3[1][:severity] = :warn and aF3[1][:invariant] = "inline-key")
chk("...naming the site it lives on", aF3[1][:where] = "legacy")
chk("...a warning alone leaves the project SOUND (advisory, not blocking)", oP3.IsSound())

? ""
? "-- Scene 4: secret-bearing sites but NO central store is a WARNING --"
oStoreless = new stzSecurityPosture("restolean")
oStoreless.AddSite(oGood)                          # store-backed site, but the posture has no store set
chk("no central store is flagged", oStoreless.NumberOf(:warn) = 1)
aF4 = oStoreless.Findings()
chk("...named 'no-central-store'", aF4[1][:invariant] = "no-central-store")

? ""
? "-- Scene 5: a store that logged REFUSED reveals is a WARNING (misuse signal) --"
oL = LLMActor("intruder")
try
	oStore.Reveal("deploy-key", oL)               # an LLM tries -> refused + logged
catch
done
oP5 = new stzSecurityPosture("restolean")
oP5.SetStore(oStore)
oP5.AddSite(oGood)                                 # store-backed -> no inline-key, store set -> no no-store
chk("the store's refused access is surfaced", oP5.NumberOf(:warn) = 1)
aF5 = oP5.Findings()
chk("...named 'refused-accesses' (misuse is visible)", aF5[1][:invariant] = "refused-accesses")

? ""
? "-- Scene 6: severity discipline -- warnings advise, errors block --"
chk("a posture with only warnings is SOUND", oP3.IsSound() and oP3.NumberOf(:warn) > 0)
chk("...a posture with an error is UNSOUND", NOT oP2.IsSound() and oP2.NumberOf(:error) > 0)

? ""
? "-- Scene 7: the CI-style entry points (parity with StzCheckAgentGraph) --"
chk("StzCheckSecurityPosture returns the findings", len(StzCheckSecurityPosture(oP2)) = 1)
chk("StzSecurityPostureIsSound gives the verdict", NOT StzSecurityPostureIsSound(oP2) and StzSecurityPostureIsSound(oClean))
chk("the invariant names are enumerable", StzFindFirst("no-sandboxed-effectful", StzSecurityInvariantNames()) > 0 and len(StzSecurityInvariantNames()) = 4)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
