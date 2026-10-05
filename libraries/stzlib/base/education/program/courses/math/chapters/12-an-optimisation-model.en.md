# An optimisation model

*Mathematics · Chapter 12 · Skill FO-04: "Can I say what I want and let the engine decide how?"*

A decision has three parts: the numbers you may choose, what you want most of, and what you must keep
under. Written down together they are a model, and a model is solved, not computed: an engine finds the best
choice and says how it found it. This chapter writes the same model twice, as an object and as a sentence,
checks that both are one model, reads the best plan and checks it by hand, and meets the two refusals a
model makes.

## 1. The model as an object

Two numbers to choose, x up to forty and y a whole number; maximise three x plus two y; keep two sums under
their limits. Ask the engine to solve it.

```ring
oM = new stzOptimModel()
oM.Vars([ :x = [ 0, 40 ], :y = [ 0, :integer ] ])
oM.Maximize("3*x + 2*y")
oM.SubjectTo([ "x + y <= 50", "2*x + y <= 80" ])
oM.SolveWith(:auto)
? oM.StatusWord()
#--> optimal
? oM.Objective()
#--> 130
? @@( oM.Solution() )
#--> [ [ "x", 30 ], [ "y", 20 ] ]
```

## 2. The engine names itself

The model says which engine ran and what it found. There is one engine built today, and the sentence says
so instead of pretending there were two.

```ring
? oM.Why()
#--> Objective 130 at x = 30, y = 20
? oM.Engine()
#--> engine floor (Zig simplex + branch-and-bound)
```

## 3. The best plan, checked by hand

A solution is a claim. The model checks every constraint against it and reports the violations, and you can
check the two sums and the objective yourself.

```ring
? @@( oM.Violations() )
#--> [ ]
? 30 + 20 <= 50
#--> 1
? 2 * 30 + 20 <= 80
#--> 1
? 3 * 30 + 2 * 20
#--> 130
```

## 4. The same model as a sentence

Say the model in words and the library builds the same object, through the same three calls. Two surfaces,
one model: the signatures of their abstract syntax are equal, which is checked rather than assumed, because
two wrong models can agree on a number.

```ring
oS = StzOptimNaturally("
        maximize 3*x + 2*y
        where x is between 0 and 40
        and y is a whole number at least 0
        keeping x + y under 50
        and keeping 2*x + y under 80
     ")
? oS.ASTSignature() = oM.ASTSignature()
#--> 1
oS.Solve()
? oS.Objective()
#--> 130
```

## 5. The model, said back

Ask the model to describe itself and it says the objective, the constraints and the bounds it holds.

```ring
? oM.Describe()
#--> max 3*x + 2*y
```

## 6. A production plan

Chairs earn thirty and take two hours; tables earn forty-five and take five; two hundred and fifty hours and
at most sixty of each. The best plan is sixty chairs and twenty-six tables, and asking for whole numbers
makes the engine branch once.

```ring
oN = new stzOptimModel()
oN.Vars([ :chairs = [ 0, :integer ], :tables = [ 0, :integer ] ])
oN.Maximize("30*chairs + 45*tables")
oN.SubjectTo([ "2*chairs + 5*tables <= 250", "chairs <= 60", "tables <= 60" ])
oN.Solve()
? @@( oN.Solution() )
#--> [ [ "chairs", 60 ], [ "tables", 26 ] ]
? oN.Objective()
#--> 2970
? oN.Branched()
#--> 1
```

## 7. What cannot be done

Ask for x at least twenty while x may not pass ten, and the engine says the model is infeasible. That is an
answer, and the honest one.

```ring
oF = new stzOptimModel()
oF.Vars([ :x = [ 0, 10 ] ])
oF.Maximize("x")
oF.SubjectTo([ "x >= 20" ])
oF.Solve()
? oF.StatusWord()
#--> infeasible
```

## 8. Two refusals

An engine tier that is not built is refused by name rather than replaced quietly, and a sentence the library
cannot read without guessing is refused rather than guessed.

```ring
try
	oM.SolveWith(:highs)
catch
	? "refused"
done
#--> refused
try
	StzOptimNaturally("maximize x where x is roughly 5")
catch
	? "refused"
done
#--> refused
```

## 9. On your world

Two clerks share this week's requests at your school: each may take at most the whole week, and the office
wants the most requests handled. What it prints depends on the world this course runs over, so the page
shows no result: run it.

```ring
aReq = EduWorldObjects("requested")
nR = len(aReq)
oW = new stzOptimModel()
oW.Vars([ :a = [ 0, :integer ], :b = [ 0, :integer ] ])
oW.Maximize("a + b")
oW.SubjectTo([ "a + b <= " + nR, "a <= " + nR, "b <= " + nR ])
oW.Solve()
? EduWorldName()
? oW.Objective()
```

{{exercise:math-12-01}}

## Recap

- **Achieved:** you wrote a decision as a model, solved it, read the engine's own account, checked the best
  plan by hand, wrote the same model as a sentence and saw the two agree as one abstract syntax, planned a
  production, met an infeasible model and two refusals.
- **Why it matters:** a decision written as a model says what it wants and what it must keep, and nothing
  about how. The engine finds the best plan, names itself, and the plan is a claim you can check.
- **Coming next:** Tukey's first look at data, once the Tukey tier is built. After it, the derivative that
  checks a formula.
