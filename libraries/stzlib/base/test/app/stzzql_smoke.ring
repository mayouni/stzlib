# stzZql smoke test -- deliberately BARE RING (no stzBase, no narrated
# harness): this exact file must also run inside ringscript.wasm in a
# browser, which is the point of the module's purity. Run from this dir:
#   ring stzzql_smoke.ring
load "../../app/stzZql.ring"

cSrc = '
DEFINE ENTITY :deposit (
  id: uuid,
  member: text,
  amount: currency,
  round: int,
  status: enum("STAGED", "AUDITED", "ACTIVE")
) RATIONALE "One member contribution to one round of the circle"

DEFINE NORM :positive_deposit AS (
  RULE: :amount > 0,
  MESSAGE: "A deposit must bring something to the circle"
)

DEFINE FLOW :collect (
  STEP 1: RECORD -> {
    ACTOR: :collector,
    VALIDATE: :member != "",
    ON_FAIL: REJECT "NO_MEMBER"
  },
  STEP 2: AUDIT -> {
    ACTOR: :treasurer,
    ENFORCING: :positive_deposit,
    ON_SUCCESS: COMMIT_TO_BEDROCK
  }
) RATIONALE "The collector records; the treasurer audits"
'

nPass = 0
nFail = 0

o = StzZqlQ(cSrc)

Check("1 entity, 1 norm, 1 flow parsed",
	o.CountEntities() = 1 and o.CountNorms() = 1 and o.CountFlows() = 1)
Check("entity rationale kept",
	substr(o.EntityRationale("deposit"), "circle") > 0)
Check("norm message kept",
	o.NormMessage("positive_deposit") = "A deposit must bring something to the circle")
aD1 = [ :amount = 5000 ]
Check("norm holds for 5000", o.EvalNorm("positive_deposit", aD1))
aD2 = [ :amount = 0 ]
Check("norm violated for 0", not o.EvalNorm("positive_deposit", aD2))

aDataOk = [ :member = "Aminata", :amount = 5000, :round = 1 ]
aR1 = o.RunFlow("collect", aDataOk)
Check("happy path completes and commits",
	aR1[:status] = "complete" and aR1[:committed] = 1)

aDataNoName = [ :member = "", :amount = 5000 ]
aR2 = o.RunFlow("collect", aDataNoName)
Check("nameless deposit rejected at RECORD with NO_MEMBER",
	aR2[:status] = "failed" and aR2[:failedstep] = "RECORD" and aR2[:actionarg] = "NO_MEMBER")

aDataZero = [ :member = "Sanda", :amount = 0 ]
aR3 = o.RunFlow("collect", aDataZero)
Check("empty-handed deposit halted at AUDIT by the norm",
	aR3[:status] = "failed" and aR3[:failedstep] = "AUDIT")
aOut = aR3[:outcomes]
Check("the norm speaks its message in the outcome",
	substr(aOut[len(aOut)][4], "bring something") > 0)

bClosed = 0
try
	StzZqlQ("DROP TABLE :users")
catch
	bClosed = substr(cCatchError, "closed") > 0
done
Check("DROP is unparseable -- the verb set is closed", bClosed)

see nl + "  " + nPass + " passed, " + nFail + " failed." + nl
if nFail > 0
	raise("SMOKE FAILED")
ok

func Check(cName, bOk)
	if bOk
		see "  [ok] " + cName + nl
		nPass = nPass + 1
	else
		see "  [!!] " + cName + nl
		nFail = nFail + 1
	ok
