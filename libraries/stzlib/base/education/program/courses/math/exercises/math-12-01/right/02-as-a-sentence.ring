# The same model as a sentence: one AST, one answer.
oS = StzOptimNaturally("
    maximize 5*x + 4*y
    where x is between 0 and 20
    and y is between 0 and 20
    keeping x + 2*y under 30
    and keeping 3*x + y under 45
")
oS.Solve()
? oS.StatusWord()
? oS.Objective()
