# Narrative
# --------
# THE MODALITY FRONTIER on a constraints substrate: what a value CAN be
# and what a kind MUST be, decided by declared constraints -- deterministic
# (@is<X> descriptor dispatch), accountable (every verdict explains), and
# honest about ignorance (an unknown kind never silently allows).
# The historical seed -- the author's per-object EnforceConstraint design
# in common/stzConstraint.ring -- is honored untouched; this is the
# KIND-level registry the modal verbs needed.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Declaring a kind: 'Constrain score to be a number, positive, even'")
	ConstrainQ("score").ToBeQ(:Number).AndQ().ToBeQ(:Positive).AndQ().ToBeQ(:Even)
	Then("the constraints are inspectable",
		@@( ConstraintsOn("score") ), '[ "number", "positive", "even" ]')
EndScenario()

Scenario("CAN -- possibility against the constraints")
	Then("'Can 42 be a score?'", CanQ(42).BeA("score"), TRUE)
	Then("'Can -4 be a score?' -- the failing constraint is NAMED",
		CanQ(-4).BeA("score"), FALSE)
	Then("...", Why(), "no: -4 is not positive (constraint 2 of 'score')")
	Then("'Can 7 be a score?'", CanQ(7).BeA("score"), FALSE)
	Then("...", Why(), "no: 7 is not even (constraint 3 of 'score')")
	Then("'Can x be a score?' -- wrong type refused first",
		CanQ("x").BeA("score"), FALSE)
	Then("an UNKNOWN kind never silently allows",
		CanQ(1).BeA("ghostkind"), FALSE)
	Then("...", Why(),
		"no: nothing is known about being a 'ghostkind' (no constraints were declared)")
EndScenario()

Scenario("MUST -- necessity is entailment from the declarations")
	Then("'Must a score be a number?'", MustQ("score").BeA(:Number), TRUE)
	Then("'Must a score be uppercase?' -- honestly no",
		MustQ("score").BeA(:Uppercase), FALSE)
	Then("...", Why(), "no: nothing constrains a 'score' to be uppercase")
EndScenario()

Scenario("The chain gate: 'the value QUALIFIES AS a score'")
	Then("a qualifying value stays live and chainable",
		classname( Q(42).QualifiesAsQ("score") ), "stznumber")
	oG = Q(7).QualifiesAsQ("score")
	Then("a failing one is a false premise that knows why",
		oG.WhyStopped(), "no: 7 is not even (constraint 3 of 'score')")
	Then("...and absorbs what follows",
		oG.QualifiesAs("score"), FALSE)
EndScenario()

Scenario("Modal verdicts join the session ask-record")
	ClearAnswers()
	CanQ(42).BeA("score")
	MustQ("score").BeA(:Number)
	Then("two yes verdicts on record", @@( AnswersSoFar() ), "[ 1, 1 ]")
	Then("the gate holds", AllYesSoFar(), TRUE)
	CanQ(7).BeA("score")
	Then("one no breaks it", AllYesSoFar(), FALSE)
	ClearAnswers()

	DropConstraints("score")
	Then("dropped constraints leave the kind unknown again",
		@@( ConstraintsOn("score") ), "[ ]")
EndScenario()

Summary()
