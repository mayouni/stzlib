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

Scenario("Per-object constraints -- the archived design, generalized (author's ask)")
	Given("the archive's stzString machinery (AddConstraint / VerifyConstraint(s) / the structured cancel) now lives on stzObject, so ANY Softanza object can be constrained; rules are descriptor symbols or the archived placeholder conditions")

	oC = new stzString("hello")
	oC.AddConstraint("always-lowercase", :Lowercase)
	oC.AddConstraint("stay-small", '{ len(@string) < 10 }')
	Then("the constraints are inspectable, named",
		@@( oC.Constraints() ),
		'[ [ "always-lowercase", "lowercase" ], [ "stay-small", "{ len(@string) < 10 }" ] ]')
	Then("a clean object verifies them all", oC.VerifyConstraints(), TRUE)

	oC.Uppercase()
	Then("a violation is caught and NAMED",
		oC.VerifyConstraint("always-lowercase"), FALSE)
	Then("...", Why(),
		'no: constraint ' + "'always-lowercase'" + ' is violated by "HELLO"')

	bStop = FALSE
	try
		oC.ApplyConstraints()
	catch
		bStop = TRUE
	done
	Then("ApplyConstraints CANCELS execution on violation (the archived semantics)",
		bStop, TRUE)

	oC.Lowercase()
	Then("...and chains when the object is clean again",
		classname( oC.ApplyConstraints().SpacifyQ() ), "stzstring")

	oN = Q(42)
	oN.AddConstraint("positive", :Positive)
	oN.AddConstraint("under-100", '{ @number < 100 }')
	Then("numbers constrain too -- ANY object (typed values)",
		oN.VerifyConstraints(), TRUE)
EndScenario()

Scenario("Enforcement-on-update -- the constrained object protects itself")
	Given("EnforceConstraint() arms a guard at the SINGLE UPDATE POINT (stzString/stzNumber Update(), stzList _SetContent() -- the very site the author's archived TODO in stzNumber.Update reserved); a violating update is refused BEFORE it lands")

	oE = new stzString("hello")
	oE.EnforceConstraint("keep-lowercase", :Lowercase)
	bRefused = FALSE
	try
		oE.UpdateWith("HELLO")
	catch
		bRefused = TRUE
	done
	Then("the violating update is REFUSED", bRefused, TRUE)
	Then("...and the object stands untouched", oE.Content(), "hello")

	oE.UpdateWith("world")
	Then("a lawful update passes", oE.Content(), "world")

	bRefused = FALSE
	try
		oE.Uppercase()
	catch
		bRefused = TRUE
	done
	Then("even a MUTATING METHOD is stopped -- it routes through Update",
		bRefused, TRUE)

	oE.RelaxConstraints()
	oE.Uppercase()
	Then("RelaxConstraints() disarms; the method passes again",
		oE.Content(), "WORLD")
	Then("...while on-demand verification stays available",
		oE.VerifyConstraint("keep-lowercase"), FALSE)

	oL = Q([1, 2, 3])
	oL.EnforceConstraint("numbers-only", :ListOfNumbers)
	bRefused = FALSE
	try
		oL.UpdateWith([1, 2, "x"])
	catch
		bRefused = TRUE
	done
	Then("lists refuse too (guarded at _SetContent, THEIR single point)",
		bRefused, TRUE)
	Then("...", @@( oL.Content() ), "[ 1, 2, 3 ]")

	oN = Q(42)
	oN.EnforceConstraint("under-100", '{ @number < 100 }')
	bRefused = FALSE
	try
		oN.UpdateWith(150)
	catch
		bRefused = TRUE
	done
	Then("numbers refuse too -- at the author's own TODO site",
		bRefused, TRUE)
	Then("...", oN.NumericValue(), 42)

	oP = new stzString("abc")
	oP.AddConstraint("lc", :Lowercase)
	oP.Uppercase()
	Then("plain AddConstraint stays PASSIVE (declaring is not enforcing)",
		oP.Content(), "ABC")
	Then("...", oP.ConstraintsAreEnforced(), FALSE)
EndScenario()

Scenario("Temporal guards -- obligation has SCOPE IN TIME")
	Given("EnforceConstraintWhile: in force only while the condition holds; EnforceConstraintUntil: in force until the condition is met, then the constraint RETIRES itself")

	oTw = new stzString("HI")
	oTw.EnforceConstraintWhile("shout-while-short", :Uppercase, '{ StzLen(@string) < 6 }')
	bRefused = FALSE
	try
		oTw.UpdateWith("hi")
	catch
		bRefused = TRUE
	done
	Then("while SHORT, lowercase is refused", bRefused, TRUE)
	oTw.UpdateWith("HELLO WORLD")
	oTw.UpdateWith("hello world")
	Then("once LONG, the while-condition releases the guard",
		oTw.Content(), "hello world")
	Then("...and verification explains the dormancy",
		oTw.VerifyConstraint("shout-while-short"), TRUE)
	Then("...", Why(),
		"yes: constraint 'shout-while-short' is not in force right now (its while-condition is false)")

	oTu = Q(5)
	oTu.EnforceConstraintUntil("stay-positive", :Positive, '{ @number >= 100 }')
	bRefused = FALSE
	try
		oTu.UpdateWith(-3)
	catch
		bRefused = TRUE
	done
	Then("until the target, negative is refused", bRefused, TRUE)
	oTu.UpdateWith(150)
	oTu.UpdateWith(-7)
	Then("after the until-condition was met, the guard is gone",
		oTu.NumericValue(), -7)
	Then("...the constraint RETIRED itself", len(oTu.Constraints()), 0)
EndScenario()

Summary()
