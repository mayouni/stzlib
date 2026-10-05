# Keeps only one of the two limits: the plan is better than the real one allows.
oM = new stzOptimModel()
oM.Vars([ :x = [ 0, 20 ], :y = [ 0, 20 ] ])
oM.Maximize("5*x + 4*y")
oM.SubjectTo([ "x + 2*y <= 30" ])
oM.Solve()
? oM.StatusWord()
? oM.Objective()
