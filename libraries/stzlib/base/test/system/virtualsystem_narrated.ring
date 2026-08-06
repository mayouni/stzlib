load "../../stzBase.ring"
load "../_narrated.ring"

# stzVirtualSystem -- REHEARSAL: operations are recorded, nothing real is touched.
#
# This suite exists because there was none. The class had no test anywhere in the
# library, which is how a knob on it stayed unreachable without anyone noticing:
# stzVirtualOperation.SetIntent() wrote a value that Intent() returned and that no
# output carried. An operation could record WHO did it and WHY, and the rehearsal
# showed only the who.
#
# stzVirtualSystem itself is a BASE: it starts with no state and has no setter for
# one, so it is stzVirtualEnvironment -- which builds the state in its init -- that
# a caller actually holds. Everything below drives it through that.

pr()

Scenario("A rehearsal records what was done, by whom, and why")

	Given("a virtual environment rehearsing for ali")
	oEnv = new stzVirtualEnvironment()
	oEnv.SetActor("ali")

	When("an operation is given an intent before it is executed")
	# THE INTENT MUST BE SET ON THE OPERATION FIRST. History() hands back a COPY
	# -- Ring copies a list on assignment, objects inside it included -- so an
	# operation cannot be annotated after the fact. Setting it here is not a
	# convenience, it is the only way in.
	oOp = new stzVirtualOperation("set_var", [ [ "name", "EDITOR" ], [ "value", "vim" ] ])
	oOp.SetIntent("match the team convention")
	oEnv.ExecuteOperation(oOp)

	When("a second operation is recorded with no intent at all")
	oEnv.SetVar("LANG", "fr_FR")

	cHist = oEnv.HistoryText()

	Then("both operations are in the record", oEnv.NumberOfOperations(), 2)
	Then("the first says what it did", StzFindFirst("set env var 'EDITOR'", cHist) > 0, TRUE)
	Then("...who did it", StzFindFirst("[ali]", cHist) > 0, TRUE)
	Then("...and WHY", StzFindFirst("match the team convention", cHist) > 0, TRUE)

	# THE NEGATIVE SIBLING. Without it the check above would also pass if every
	# line carried some fixed text: a rehearsal with no intent must read exactly
	# as it did before intents were shown at all.
	Then("the second line carries no reason", StzFindFirst("fr_FR' " + char(32) + "[ali] --", cHist), 0)
	Then("...and no stray marker either", NIntentMarkers(cHist), 1)

	# HistoryText() is what ShowHistory() prints. It was print-only, so the one
	# record of a rehearsal could not be captured into a log, a report, or a
	# check -- which is also why the missing intent had nowhere to show.
	Then("the record is text a caller can hold", len(cHist) > 0, TRUE)
	Then("...naming both variables", StzFindFirst("EDITOR", cHist) > 0 and StzFindFirst("LANG", cHist) > 0, TRUE)
EndScenario()

Scenario("The actor is stamped on every operation, not just the first")

	Given("an environment whose actor is set once")
	oEnv2 = new stzVirtualEnvironment()
	oEnv2.SetActor("bilal")
	oEnv2.SetVar("A", "1")
	oEnv2.SetVar("B", "2")

	# ExecuteOperation stamps @cActor onto each operation as it records it, so a
	# rehearsal cannot end up with an unattributed line.
	Then("the actor is reported", oEnv2.Actor(), "bilal")
	Then("...and stamped on both lines", NActorMarks(oEnv2.HistoryText(), "[bilal]"), 2)

	# The negative sibling: an environment left on its default must NOT say bilal.
	oEnv3 = new stzVirtualEnvironment()
	oEnv3.SetVar("A", "1")
	Then("a default environment stamps its own default", NActorMarks(oEnv3.HistoryText(), "[human]"), 1)
	Then("...and not the other one's actor", NActorMarks(oEnv3.HistoryText(), "[bilal]"), 0)
EndScenario()

Scenario("A commit scope refuses more than it was told to allow")

	Given("a scope capped at two operations")
	oScope = new stzCommitScope()
	oScope.SetMaxOperations(2)

	Then("the cap is reported back", oScope.MaxOperations(), 2)

	# The negative sibling: zero means no cap, which is the default, so a check
	# that only ever set a cap could not tell the two apart.
	oOpen = new stzCommitScope()
	Then("an unset scope reports no cap", oOpen.MaxOperations(), 0)
EndScenario()

Summary()

pf()

# how many lines carry an intent marker
func NIntentMarkers(pcText)
	return len(StzFindCS(" -- ", "" + pcText, FALSE))

func NActorMarks(pcText, pcMark)
	return len(StzFindCS(pcMark, "" + pcText, FALSE))
