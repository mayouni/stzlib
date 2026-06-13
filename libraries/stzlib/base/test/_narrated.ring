# Narrated test helper -- GIVEN / WHEN / THEN markers for Softanza
# regression suites. Each Scenario block emits structured output and
# tallies pass/fail; call Summary() at the end for the total.
#
# Why: previous suites use bare `? expr = expected` (boolean 0/1
# output) which is hard to read and doesn't distinguish "ran but
# failed" from "didn't run". Narrated style names the precondition,
# the operation, and the assertion separately. This makes test
# output a readable spec; failures cite the difference clearly.
#
# Load AFTER stzBase.ring. Globals use $_zst_ prefix to avoid
# colliding with caller variables.

$_zst_total       = 0
$_zst_pass        = 0
$_zst_fail        = 0
$_zst_scen_pass   = 0
$_zst_scen_fail   = 0
$_zst_scen_title  = ""

func Scenario(cTitle)
    $_zst_scen_title = cTitle
    $_zst_scen_pass  = 0
    $_zst_scen_fail  = 0
    ? char(10) + "SCENARIO: " + cTitle

func Given(cText)
    ? "  GIVEN " + cText

func When(cText)
    ? "  WHEN  " + cText

func Then(cText, xActual, xExpected)
    if xActual = xExpected
        ? "  THEN  " + cText + "  [PASS]"
        $_zst_scen_pass++
        $_zst_pass++
    else
        ? "  THEN  " + cText + "  [FAIL]"
        ? "    expected: " + @@(xExpected)
        ? "    got:      " + @@(xActual)
        $_zst_scen_fail++
        $_zst_fail++
    ok
    $_zst_total++

func EndScenario()
    ? "  -> " + $_zst_scen_pass + " pass, " + $_zst_scen_fail + " fail"

func Summary()
    cSep = "================================================"
    ? char(10) + cSep
    ? "TOTAL: " + $_zst_total + " assertions, " +
      $_zst_pass + " pass, " + $_zst_fail + " fail"
    ? cSep
    if $_zst_fail > 0
        ? "STATUS: FAILED"
    else
        ? "STATUS: OK"
    ok
