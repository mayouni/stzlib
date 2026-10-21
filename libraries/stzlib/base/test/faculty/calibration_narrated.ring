# Narrative
# ---------
# THE CALIBRATION LEDGER (base/faculty/stzCalibration.ring; COMPASS-JEV-CALIBRATION-01; design section 9.3).
# Evidentiality -- certain / probable / apparent -- was a DECLARED vocabulary. This ledger makes it a MEASURED property:
# for every answer whose truth is known it keeps the band, the probability and whether the answer was RIGHT, and a
# guard FAILS when a higher band is not right at least as often as a lower one.
#
#   1  the guard, on synthetic ledgers whose answer is known: a calibrated ledger is silent, an inverted one is a finding,
#      a thin band is a warning (a verdict on three answers is noise)
#   2  the real thing: a model's choice-by-probability on the 36 held-out tickets feeds the ledger during RunGoldens,
#      and the reliability table is PRINTED -- whatever it says (that is the measurement, not an assertion)
#
# Scenario 2 SKIPS, saying so, without the Qwen2.5-Coder-0.5B GGUF. Run from this directory.

load "../../stzBase.ring"
load "../_narrated.ring"
load "_ticket_app.ring"

Scenario("The guard is silent on a calibrated ledger and fails on an inverted one")
	StzClearCalibration()
	# certain: 9 of 10 right; probable: 7 of 10; apparent: 3 of 10 -> a higher band IS right more often
	for i = 1 to 10 StzRecordCalibration("f", "good", "certain",  0.97, (i <= 9)) next
	for i = 1 to 10 StzRecordCalibration("f", "good", "probable", 0.80, (i <= 7)) next
	for i = 1 to 10 StzRecordCalibration("f", "good", "apparent", 0.50, (i <= 3)) next
	Then("a calibrated ledger raises no finding", len(StzCalibrationFindings("f", "good", 5)), 0)
	aRel = StzReliability("f", "good")
	Then("certain answers were right 90 percent of the time", aRel[1][3], 0.9)
	Then("probable 70 percent", aRel[2][3], 0.7)
	Then("apparent 30 percent", aRel[3][3], 0.3)

	# inverted: 'certain' is right only 4 of 10, 'apparent' 8 of 10
	for i = 1 to 10 StzRecordCalibration("f", "overconfident", "certain",  0.97, (i <= 4)) next
	for i = 1 to 10 StzRecordCalibration("f", "overconfident", "probable", 0.80, (i <= 6)) next
	for i = 1 to 10 StzRecordCalibration("f", "overconfident", "apparent", 0.50, (i <= 8)) next
	aF = StzCalibrationFindings("f", "overconfident", 5)
	Then("an inverted ledger is a FINDING", len(aF) >= 1, TRUE)
	Then("...named calibration-inverted", aF[1][:rule], "calibration-inverted")
	Then("...in the house shape, an error, subject model-flow", aF[1][:severity] = :error and aF[1][:subject] = "model-flow", TRUE)
	Then("...saying which bands disagree", StzFindFirst("the HIGHER band", aF[1][:message]) > 0, TRUE)

	# thin bands are not judged
	for i = 1 to 3 StzRecordCalibration("f", "thin", "certain",  0.97, 0) next
	for i = 1 to 3 StzRecordCalibration("f", "thin", "apparent", 0.50, 1) next
	aT = StzCalibrationFindings("f", "thin", 5)
	Then("a band with fewer answers than the minimum is a WARNING, not a verdict", aT[1][:rule] + "/" + aT[1][:severity], "calibration-thin/warning")
	Then("the guard never fails on noise", StzFindingsAreSound(aT), TRUE)

	Then("a band is derived from a probability the same way everywhere",
		StzBandOfProbability(0.99) + "/" + StzBandOfProbability(0.8) + "/" + StzBandOfProbability(0.4), "certain/probable/apparent")
EndScenario()

if StzModelFileFor("qwen2.5-coder-0.5b") = ""
	Scenario("A real model's calibration -- SKIPPED (no Qwen2.5-Coder-0.5B GGUF)")
		Given("drop the file in to measure a real ledger; see models/MODELS.md")
	EndScenario()
else
	StzClearCalibration()
	StzTicketAppDeclare()
	Scenario("A real ledger: Qwen2.5-Coder-0.5B reading the ticket kind by probability, scored on 36 held-out tickets")
		aRows = StzRunGoldensFor("kind", [ "qwen25c-0.5b-choice" ], [])
		aRel = StzReliability("kind", "qwen25c-0.5b-choice")
		nAll = aRel[1][2] + aRel[2][2] + aRel[3][2]
		Then("every one of the 36 answers carried a probability and entered the ledger", nAll, 36)
		? StzReliabilityText("kind", "qwen25c-0.5b-choice")
		aF = StzCalibrationFindings("kind", "qwen25c-0.5b-choice", 5)
		Then("the guard returns its findings as a list (what it says is the measurement)", isList(aF), TRUE)
		for i = 1 to len(aF) ? "  finding: " + aF[i][:rule] + " -- " + aF[i][:message] next
		Then("the reliability rows are consistent: mean p of a band lies inside its band's range",
			(aRel[1][2] = 0 or aRel[1][4] >= 0.95) and (aRel[3][2] = 0 or aRel[3][4] < 0.75), TRUE)
	EndScenario()
ok

Summary()
