load "../../stzBase.ring"
load "../_narrated.ring"

# TESTOOR P1b -- REFINEMENT, VERIFIED. Refinement-oriented programming admits a
# change as a typed proposal through a gate: the point must exist, the value must
# respect its bounds, governance and trust must allow it, and the derivation
# rules must hold. That is ADMISSION, not proof: nothing runs the program after
# the change. Testoor supplies the evidence, through a seam that already exists:
# a derivation rule is a predicate over the post-change code, and a rejection
# rolls the change back. The predicate here renders the proposal to a rehearsal
# path, hands that path to the tours as their SUBJECT, walks them, and admits the
# change only if the runner exits 0.
#
# THE EXPERIMENT. A pricing program with one refinement point, vat, bounded
# [0, 0.9]. Three tours state what the program promises whatever the knob says:
# gross is net plus vat; the vat of nothing is nothing; the vat never exceeds a
# quarter of the net. The bounds let 0.50 through, because 0.50 is inside them.
# The third tour does not.
#
#   control   the bounds alone ADMIT 0.50: bounds are necessary, not sufficient
#   0.22      inside the bounds, the tours agree: admitted, and walked once
#   0.50      inside the bounds, the tours refuse: rolled back, refused at the
#             DERIVATION stage with the diverged claim on record
#   0.95      outside the bounds: refused at the CONSTRAINT stage, and the tours
#             were never run (evidence is spent only on proposals that pass the
#             cheaper stages)
#   Revert    the typed inverse still works; the real source is never rewritten
#
# WHAT THIS IS NOT. It does not change the refinement library; it uses a seam
# the library already has. A tour is evidence and not proof, and a refinement
# whose effect a person must perceive needs a named perceiver, which this does
# not provide. Running tours inside the gate costs a child process each.

? "TESTOOR P1b -- refinement, verified"
nRfStart = clock()
cRfHere = currentdir()
cRfRoot = cRfHere + "/_planted_refine"
$cRfSubject = cRfRoot + "/pricing.ring"
$cRfRehearsal = cRfRoot + "/_rehearsal.ring"
$cRfTour = cRfRoot + "/price_tour.ring"
$nRfWalks = 0
$oRfLast = ""
_RfPlantAll(cRfRoot)
cRfSource = read($cRfSubject)

#============================================================================
Scenario("The runner hands a tour its subject, and a refined subject becomes a program")
	nRfSec = clock()
	Given("a source carrying a refinement point")
	cTagged = '$nVat = <R:PARAM name="vat" value="0.22" min="0" max="0.9">'
	Then("its tag is replaced by the value it carries", TestoorResolveRefinements(cTagged), '$nVat = 0.22')
	Then("two tags in one source are both replaced",
		TestoorResolveRefinements('a = <R:PARAM name="x" value="1">' + char(10) + 'b = <R:PARAM name="y" value="2">'),
		'a = 1' + char(10) + 'b = 2')
	Then("a source with no tag is left alone", TestoorResolveRefinements("x = 1"), "x = 1")
	Then("a tag that never closes is left as it was", TestoorResolveRefinements('a = <R:PARAM name="x"'), 'a = <R:PARAM name="x"')
	Then("this process was handed no subject", TestoorSubject(), "")
	Given("the pricing tour walked with no subject")
	oNo = TravellerQ().Silent().Timeout(30000).Seed(5).Walk($cRfTour)
	Then("it does not pretend: the runner exits 1", oNo.ExitCode(), 1)
	Then("and its claim says why", StzFindFirst("no subject", oNo.Records()[1][:run][:stops][1][:claims][1][:claim]) > 0, TRUE)
	Given("the same tour walked with the unrefined source as its subject, 0.20")
	write($cRfRehearsal, TestoorResolveRefinements(cRfSource))
	oOk = TravellerQ().Silent().Timeout(30000).Seed(5).Subject($cRfRehearsal).Walk($cRfTour)
	Then("all three promises are kept", oOk.Records()[1][:run][:kept], 3)
	Then("the runner exits 0", oOk.ExitCode(), 0)
	Then("and the logbook names the subject", StzFindFirst("_rehearsal.ring", oOk.Json()) > 0 and StzFindFirst('"subject":""', oOk.Json()) = 0, TRUE)
EndScenario()
? "        [section took " + ((clock() - nRfSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("CONTROL: the bounds alone admit a value that breaks a promise")
	nRfSec = clock()
	Given("the refinable pricing code with its bounds and no tours")
	oCtl = new stzRefinableCode(cRfSource)
	Then("it has one refinement point", oCtl.NumberOfPoints(), 1)
	rCtl = oCtl.Refine("vat").To("0.50")
	Then("0.50 is inside [0, 0.9] and the gate ADMITS it", rCtl[:admitted], 1)
	write($cRfRehearsal, TestoorResolveRefinements(oCtl.Rendered()))
	oBad = TravellerQ().Silent().Timeout(30000).Seed(5).Subject($cRfRehearsal).Walk($cRfTour)
	Then("but the tours, walked against that very state, diverge", oBad.Records()[1][:run][:diverged], 1)
	Then("on the promise the bounds could not express", oBad.Records()[1][:run][:stops][1][:claims][3][:claim], "vat never exceeds a quarter of the net")
	Then("and the runner exits 1", oBad.ExitCode(), 1)
EndScenario()
? "        [section took " + ((clock() - nRfSec) / clockspersecond()) + "s]"

#============================================================================
Scenario("The tours plugged in as the derivation rule: admitted, refused by evidence, refused by bounds, reverted")
	nRfSec = clock()
	Given("the same code with the tours declared as a derivation rule")
	oGate = new stzRefinableCode(cRfSource)
	oGate.DeclareDerivation("tours-keep-their-promises",
		func oCode {
			$nRfWalks++
			write($cRfRehearsal, TestoorResolveRefinements(oCode.Rendered()))
			oRf = TravellerQ().Silent().Timeout(30000).Seed(5).Subject($cRfRehearsal).Walk($cRfTour)
			$oRfLast = oRf
			return oRf.ExitCode() = 0
		},
		"the tours that walk this refinement diverge")
	Then("the rule is registered", oGate.NumberOfDerivations(), 1)
	When("a proposal both the bounds and the tours accept: 0.22")
	r1 = oGate.Refine("vat").To("0.22")
	Then("it is admitted", r1[:admitted], 1)
	Then("the tours were walked once", $nRfWalks, 1)
	Then("and were kept", $oRfLast.ExitCode(), 0)
	Then("the evidence names the rehearsal copy as the subject", StzFindFirst("_rehearsal.ring", $oRfLast.Json()) > 0, TRUE)
	Then("and the seed, so the run can be walked again", StzFindFirst('"seed":5', $oRfLast.Json()) > 0, TRUE)
	When("a proposal the bounds accept and the tours do not: 0.50")
	r2 = oGate.Refine("vat").To("0.50")
	Then("it is REFUSED", r2[:admitted], 0)
	Then("at the derivation stage", StzFindFirst("derivation", r2[:why]) > 0, TRUE)
	Then("saying which rule", StzFindFirst("tours-keep-their-promises", r2[:why]) > 0 or StzFindFirst("tours that walk", r2[:why]) > 0, TRUE)
	Then("the tours were walked a second time", $nRfWalks, 2)
	Then("the diverged claim is on record", $oRfLast.Records()[1][:run][:diverged], 1)
	Then("the source rolled back to the last good value", oGate.ValueOf("vat"), "0.22")
	When("a proposal outside the bounds: 0.95")
	r3 = oGate.Refine("vat").To("0.95")
	Then("it is refused", r3[:admitted], 0)
	Then("at the constraint stage, before any tour", StzFindFirst("constraint", r3[:why]) > 0, TRUE)
	Then("so the tours were NOT walked again", $nRfWalks, 2)
	Then("the value is unchanged", oGate.ValueOf("vat"), "0.22")
	When("the admitted change is reverted")
	oGate.Revert()
	Then("the typed inverse restores the old value", oGate.ValueOf("vat"), "0.20")
	Then("the real source file was never rewritten", read($cRfSubject), cRfSource)
EndScenario()
? "        [section took " + ((clock() - nRfSec) / clockspersecond()) + "s]"

_RfUnplantAll(cRfRoot)
? ""
? "[P1b took " + ((clock() - nRfStart) / clockspersecond()) + "s]"
Summary()

#============================================================================
# HELPERS AFTER THE TOP-LEVEL CODE

func _RfPlantAll(cRoot)
	_RfUnplantAll(cRoot)
	StzMakeDir(cRoot)
	_n_ = char(10)
	_t_ = char(9)
	write(cRoot + "/pricing.ring",
		'$nVat = <R:PARAM name="vat" value="0.20" min="0" max="0.9">' + _n_ +
		"func VatOf(nNet)" + _n_ + _t_ + "return nNet * $nVat" + _n_ +
		"func GrossOf(nNet)" + _n_ + _t_ + "return nNet + VatOf(nNet)" + _n_)
	# the tour takes its subject from the runner and prints protocol lines
	write(cRoot + "/price_tour.ring",
		'cSub = ""' + _n_ +
		"nA = len(sysargv)" + _n_ +
		"for i = 1 to nA - 1" + _n_ +
		_t_ + 'if sysargv[i] = "--testoor-subject"  cSub = sysargv[i + 1]  ok' + _n_ +
		"next" + _n_ +
		'? "[testoor stop pricing]"' + _n_ +
		'if cSub = ""' + _n_ +
		_t_ + '? "[testoor fail no subject was handed to this tour]"' + _n_ +
		"else" + _n_ +
		_t_ + "eval(read(cSub))" + _n_ +
		_t_ + "nDiff = GrossOf(100) - (100 + VatOf(100))" + _n_ +
		_t_ + "if nDiff < 0.000001 and nDiff > -0.000001" + _n_ +
		_t_ + _t_ + '? "[testoor ok gross is net plus vat]"' + _n_ +
		_t_ + "else" + _n_ +
		_t_ + _t_ + '? "[testoor fail gross is net plus vat]"' + _n_ +
		_t_ + "ok" + _n_ +
		_t_ + "if VatOf(0) = 0" + _n_ +
		_t_ + _t_ + '? "[testoor ok vat of nothing is nothing]"' + _n_ +
		_t_ + "else" + _n_ +
		_t_ + _t_ + '? "[testoor fail vat of nothing is nothing]"' + _n_ +
		_t_ + "ok" + _n_ +
		_t_ + "if VatOf(100) <= 25" + _n_ +
		_t_ + _t_ + '? "[testoor ok vat never exceeds a quarter of the net]"' + _n_ +
		_t_ + "else" + _n_ +
		_t_ + _t_ + '? "[testoor fail vat never exceeds a quarter of the net]"' + _n_ +
		_t_ + "ok" + _n_ +
		"ok" + _n_)

func _RfUnplantAll(cRoot)
	if fexists(cRoot + "/pricing.ring")
		StzDirDeleteAll(cRoot)
	ok
