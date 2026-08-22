# THE MODELLING DSL -- R4 step 5, narrated
#
# SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.5: three coexisting surfaces
# onto ONE model AST, and two execution tiers of which Why() names the
# one that ran. The gap this closes was never the SOLVING -- the engine
# has run a real simplex since the numeric foundation's phase 5. It was
# that a caller had to hand-build coefficient arrays.
#
#   Scene 1  the entry object solves the design's own example
#   Scene 2  the expression compiler -- EXACT coefficients, no eval()
#   Scene 3  integer variables, and the tree that earns them
#   Scene 4  the sentence surface reaches THE SAME AST (compared as
#            ASTs, never as answers)
#   Scene 5  .zopt: an indexed family, and the round trip
#   Scene 6  the two tiers, honestly -- and the refusals
#   Scene 7  the honesty guard: the exact solver never loses to the
#            heuristic, and both tiers print
#
# PER PX: this suite prints per-section wall time. It is seconds, not
# minutes, so there is no scoped mode and nothing is skipped -- a scope
# that can drop coverage is a cost with no benefit at this size.
#
# THE HELPERS LIVE AFTER pf() -- Ring runs a file's top-level code only
# up to the first `func`.

load "../../stzBase.ring"

nPass = 0
nFail = 0
nT0 = clock()
nSec = clock()

cFx = StzReplace(WorkingDirectory(), "\", "/") + "/_optim-fixture"
if StzDirExists(cFx)
	StzDirDeleteAll(cFx)
ok
StzDirCreatePath(cFx)

pr()

#=====================================================================#
? "-- Scene 1: the entry object, and the design's own example --"
#=====================================================================#
# oM.Vars(...) / Maximize / SubjectTo / SolveWith(:auto) -- verbatim
# from 5.5. The answer is checkable by hand: the two constraints meet
# at x=30, y=20.

oM = new stzOptimModel()
oM.Vars([ :x = [0, 40], :y = [0, :integer] ])
oM.Maximize("3*x + 2*y")
oM.SubjectTo([ "x + y <= 50", "2*x + y <= 80" ])
oM.SolveWith(:auto)

chk("the model solved to optimality", oM.IsOptimal() = 1)
chk("...x = 30", fabs(oM.ValueOf("x") - 30) < 0.000001)
chk("...y = 20", fabs(oM.ValueOf("y") - 20) < 0.000001)
chk("...objective 130", fabs(oM.Objective() - 130) < 0.000001)

# THE ANSWER CHECKS ITSELF against the model it came from -- a solver
# that returns a confident wrong point is what this catches
chk("every constraint and bound the model states is satisfied",
	oM.IsFeasibleAnswer() = 1)
chk("...and nothing is reported as violated", len(oM.Violations()) = 0)

# LAW 3: the verdict names the engine that produced it
chk("Why() names the tier that ran",
	len(StzFind("engine floor", oM.Why())) > 0)
chk("...and says the upgrade tier is absent rather than implying it ran",
	len(StzFind("not vendored", oM.Why())) > 0)

sec("scene 1")

#=====================================================================#
? "-- Scene 2: an expression becomes coefficients, EXACTLY --"
#=====================================================================#
# The design said expressions compile through expr.zig. They do not and
# they cannot: expr.zig has <= but no named variables. The engine that
# CAN do it is autodiff -- a linear form's gradient IS its coefficient
# vector, so one tape pass returns the constant and every coefficient
# with no step size and no eval(). See stzOptimExpr's header.

aF = StzLinearFormOf("4*x - 2*y + 7", [ "x", "y" ])
chk("a linear form compiles", aF[:ok] = 1)
chk("...its constant term is exact", fabs(aF[:const] - 7) < 0.000001)
chk("...and so are its coefficients",
	fabs(aF[:coeffs][1] - 4) < 0.000001 and
	fabs(aF[:coeffs][2] + 2) < 0.000001)

# a variable the expression never mentions gets a ZERO, not an absence
aG = StzLinearFormOf("5*a", [ "a", "b" ])
chk("a variable the expression does not mention has coefficient 0",
	fabs(aG[:coeffs][2]) < 0.000001)

# a relation is split HERE and each side compiled -- so terms on the
# right are read correctly rather than shuffled by string surgery
aC = StzLinearConstraintOf("2*x + 3 <= y + 10", [ "x", "y" ])
chk("a relation splits into coefficients, an operator and a bound",
	aC[:ok] = 1 and aC[:op] = -1)
chk("...with terms from BOTH sides folded in: 2x - y <= 7",
	fabs(aC[:coeffs][1] - 2) < 0.000001 and
	fabs(aC[:coeffs][2] + 1) < 0.000001 and
	fabs(aC[:rhs] - 7) < 0.000001)

# >= and = are read too, and "<=" is tried before "=" -- otherwise
# "x + y <= 50" would split at the "=" and both halves be nonsense
chk(">= is read as >=", StzLinearConstraintOf("x >= 4", ["x"])[:op] = 1)
chk("= is read as =", StzLinearConstraintOf("x = 4", ["x"])[:op] = 0)
chk("...and <= is not mistaken for =",
	StzLinearConstraintOf("x <= 4", ["x"])[:op] = -1)

# THE NEGATIVE SIBLING: an expression the engine cannot compile is
# REFUSED with a reason, never silently read as zero
aBad = StzLinearFormOf("3 * ", [ "x" ])
chk("an expression that does not compile is refused, with a reason",
	aBad[:ok] = 0 and aBad[:why] != "")
aNoRel = StzLinearConstraintOf("x + y", [ "x", "y" ])
chk("a constraint with no relation is refused", aNoRel[:ok] = 0)

sec("scene 2")

#=====================================================================#
? "-- Scene 3: integer variables, and the tree that earns them --"
#=====================================================================#
# max x+y subject to 2x+2y <= 5. The relaxation reaches 2.5 and no
# integer point does -- so the answer is 2, and it must come back whole.

oI = new stzOptimModel()
oI.Vars([ :a = [0, :integer], :b = [0, :integer] ])
oI.Maximize("a + b")
oI.SubjectTo("2*a + 2*b <= 5")
oI.SolveWith(:auto)

chk("the integer model solved", oI.IsOptimal() = 1)
chk("...to 2, not to the relaxation's 2.5",
	fabs(oI.Objective() - 2) < 0.000001)
chk("...and the values really are whole numbers",
	fabs(oI.ValueOf("a") - floor(oI.ValueOf("a") + 0.5)) < 0.000001 and
	fabs(oI.ValueOf("b") - floor(oI.ValueOf("b") + 0.5)) < 0.000001)
chk("...the search branched, and says so", oI.Branched() = 1)
chk("...and Why() names branch-and-bound",
	len(StzFind("branch-and-bound", oI.Why())) > 0)

# the CONTINUOUS sibling of the same model reaches 2.5 -- which is what
# makes the integer answer above a result rather than a coincidence
oRelax = new stzOptimModel()
oRelax.Vars([ :a = [0], :b = [0] ])
oRelax.Maximize("a + b")
oRelax.SubjectTo("2*a + 2*b <= 5")
oRelax.SolveWith(:auto)
chk("the SAME model without integrality reaches 2.5",
	fabs(oRelax.Objective() - 2.5) < 0.000001)
chk("...and did not branch", oRelax.Branched() = 0)

# :binary is :integer with an upper bound of one
oB = new stzOptimModel()
oB.Vars([ :p = [0, :binary] ])
oB.Maximize("p")
oB.SubjectTo("p <= 5")
oB.SolveWith(:auto)
chk("a binary variable cannot exceed one",
	fabs(oB.Objective() - 1) < 0.000001)

sec("scene 3")

#=====================================================================#
? "-- Scene 4: the sentence reaches THE SAME AST --"
#=====================================================================#
# Surface 2. The claim is not that the answers agree -- two different
# wrong models can agree on a number. The claim is that the MODELS are
# the same, so the ASTs are compared.

oS = StzOptimNaturally("
maximize 3*x + 2*y
where x is between 0 and 40
and y is a whole number at least 0
keeping x + y under 50
and keeping 2*x + y under 80
")

chk("the sentence built a model", oS.NumberOfVars() = 2)
chk("...with both constraints", oS.NumberOfConstraints() = 2)
chk("...and it is THE SAME AST the entry object built",
	oS.ASTSignature() = oM.ASTSignature())

# said differently, the signature is diagnosable rather than a bare bit
? "    AST: " + oS.ASTSignature()

oS.SolveWith(:auto)
chk("...so of course it reaches the same answer",
	fabs(oS.Objective() - 130) < 0.000001)

# THE NEGATIVE SIBLING: a DIFFERENT model must NOT match the signature,
# or the comparison above proves nothing
oD = StzOptimNaturally("
maximize 3*x + 2*y
where x is between 0 and 40
and y is a whole number at least 0
keeping x + y under 49
and keeping 2*x + y under 80
")
chk("a model differing by ONE bound has a different AST",
	oD.ASTSignature() != oM.ASTSignature())

# a clause the surface does not understand is REFUSED, never guessed
oBadS = StzOptimSentenceQ("maximize x
where x is between 0 and 5
and keeping x somewhere near 3")
chk("an ambiguous clause is refused rather than guessed",
	oBadS.IsValid() = 0)

sec("scene 4")

#=====================================================================#
? "-- Scene 5: .zopt -- an indexed family, and the round trip --"
#=====================================================================#
# Surface 3, and the capability the longhand solver lacks: ONE line
# declares one variable per product, and adding a product is editing
# one list rather than writing another constraint.

cZ = "zopt: 1
model: production
set Products: chairs, tables
param profit[Products]: 30, 45
param hours[Products]: 2, 5
var make[Products]: 0 .. 100 integer
maximize: sum profit[p] * make[p] for p in Products
subject to:
  capacity: sum hours[p] * make[p] for p in Products <= 250
  forall p in Products: make[p] <= 60
"

oF = new stzOptimFile("")
oF.SetText(cZ)
chk("the .zopt file is accepted", oF.IsValid() = 1)
chk("...its set has two members", len(oF.MembersOf("products")) = 2)
chk("...and an indexed param reads by member",
	oF.ParamValue("profit", "tables") = 45)

oZ = oF.ToModel()
chk("ONE var line became one variable per member", oZ.NumberOfVars() = 2)
chk("...named for the member they belong to",
	oZ.VarNames()[1] = "make_chairs" and oZ.VarNames()[2] = "make_tables")
chk("...and the forall became one constraint per member, beside capacity",
	oZ.NumberOfConstraints() = 3)

oZ.SolveWith(:auto)
chk("the expanded model solves", oZ.IsOptimal() = 1)
chk("...to 2970 -- 30*60 + 45*26, checkable by hand",
	fabs(oZ.Objective() - 2970) < 0.000001)
chk("...with the capacity constraint binding at 250",
	fabs(2 * oZ.ValueOf("make_chairs") + 5 * oZ.ValueOf("make_tables") - 250) < 0.000001)
chk("...and the answer satisfies every row it came from",
	oZ.IsFeasibleAnswer() = 1)

# THE ROUND TRIP: written out, read back, and the AST is the same. The
# text is NOT compared -- writing the expanded model is the point, and
# a text diff would only prove the writer echoes the reader.
cPath = oF.Save(cFx + "/production")
chk("the model writes to a .zopt file", StzFileExists(cPath) = 1)

oBack = StzOptimModelFromFile(cPath)
chk("...reads back", oBack.NumberOfVars() = 2)
chk("...and the round trip preserves the AST EXACTLY",
	oBack.ASTSignature() = oZ.ASTSignature())

oBack.SolveWith(:auto)
chk("...so the reloaded model answers identically",
	fabs(oBack.Objective() - 2970) < 0.000001)

# a family whose parameter list does not match its set is REFUSED at
# load -- the shape of error an indexed format exists to catch
oShort = new stzOptimFile("")
oShort.SetText("zopt: 1
set Products: chairs, tables, desks
param profit[Products]: 30, 45
var make[Products]: 0 .. 10
maximize: sum profit[p] * make[p] for p in Products
")
chk("a param with fewer values than its set has members is refused",
	oShort.IsValid() = 0)

oNoVer = new stzOptimFile("")
oNoVer.SetText("set S: a" + char(10) + "var x: 0 .. 1" + char(10) + "maximize: x")
chk("a file with no version header is refused", oNoVer.IsValid() = 0)

sec("scene 5")

#=====================================================================#
? "-- Scene 6: two tiers, and the one that is absent says so --"
#=====================================================================#
# LAW 2 is graceful degradation, not silent substitution. The floor is
# built; HiGHS is not vendored. Asking for it is REFUSED, because
# answering with the floor would make the two-tier claim untrue.

chk("the floor can be asked for by name",
	StzOptimModelQ().NumberOfVars() = 0)

oT = new stzOptimModel()
oT.Vars([ :x = [0, 10] ])
oT.Maximize("x")
oT.SubjectTo("x <= 7")
oT.SolveWith(:floor)
chk("SolveWith(:floor) runs the floor", fabs(oT.Objective() - 7) < 0.000001)
chk("...and Why() says which was ASKED for",
	len(StzFind("SolveWith(:floor)", oT.Why())) > 0)

bRefused = 0
try
	oT.SolveWith(:highs)
catch
	bRefused = 1
done
chk("SolveWith(:highs) is REFUSED while HiGHS is not vendored",
	bRefused = 1)

bRefused2 = 0
try
	oT.SolveWith(:quantum)
catch
	bRefused2 = 1
done
chk("...and a tier that was never designed is refused too", bRefused2 = 1)

# an infeasible model is REPORTED as infeasible, not answered
oInf = new stzOptimModel()
oInf.Vars([ :x = [0] ])
oInf.Maximize("x")
oInf.SubjectTo([ "x >= 5", "x <= 2" ])
oInf.SolveWith(:auto)
chk("an infeasible model is reported, not answered",
	oInf.IsOptimal() = 0 and oInf.StatusWord() = "infeasible")

# ...and so is an unbounded one
oUnb = new stzOptimModel()
oUnb.Vars([ :x = [0], :y = [0] ])
oUnb.Maximize("x")
oUnb.SubjectTo("x - y <= 1")
oUnb.SolveWith(:auto)
chk("an unbounded model is reported as unbounded",
	oUnb.StatusWord() = "unbounded")

sec("scene 6")

#=====================================================================#
? "-- Scene 7: the honesty guard -- the exact solver never loses --"
#=====================================================================#
# The test whose RETIREMENT let a zeros-returning stub survive for
# months. It does not retire again, and it now runs across the two
# things this step actually has: the modelling object over the engine
# floor, and the older stzLinearSolver's heuristic backend on the SAME
# model. Both print.

oG = new stzOptimModel()
oG.Vars([ :x = [0, 40], :y = [0, 30] ])
oG.Maximize("3*x + 2*y")
oG.SubjectTo([ "x + y <= 50", "2*x + y <= 80" ])
oG.SolveWith(:auto)
nModel = oG.Objective()

nGreedy = OldSolve("greedy")
nSimplex = OldSolve("simplex")

? "    stzOptimModel (engine floor) : " + nModel
? "    stzLinearSolver simplex      : " + nSimplex
? "    stzLinearSolver greedy       : " + nGreedy

chk("the modelling object is never beaten by the heuristic",
	nModel >= nGreedy - 0.001)
chk("...and agrees with the older exact backend on the same model",
	fabs(nModel - nSimplex) < 0.001)
chk("...and the answer is feasible", oG.IsFeasibleAnswer() = 1)

sec("scene 7")

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "WALL:  " + ((clock() - nT0) / clockspersecond()) + "s"
? "=========================================="

StzDirDeleteAll(cFx)

pf()

func chk(cWhat, bCond)
	if bCond = 1
		nPass++
		? "  [OK] " + cWhat
	else
		nFail++
		? "  [FAIL] " + cWhat
	ok

# the SAME model through the older stzLinearSolver, on its own surface
func OldSolve(cBackend)
	o = new stzLinearSolver()
	o {
		AddVariable("x", 0, 40)
		AddVariable("y", 0, 30)
		AddConstraint("x + y", "<=", 50)
		AddConstraint("2*x + y", "<=", 80)
		Maximize("3*x + 2*y")
		Solve(cBackend)
	}
	return o.ObjectiveValue()

# PX rule 2: a long suite prints per-section wall time, so every gate
# run is also the profile that says which section earns a diet.
func sec(cName)
	? "    ~ " + cName + ": " + ((clock() - nSec) / clockspersecond()) + "s"
	? ""
	nSec = clock()
